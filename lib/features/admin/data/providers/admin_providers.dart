import 'dart:async';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/supabase_config.dart';
import '../../../../core/errors/app_exception.dart';

// ── Live fleet (Realtime) ─────────────────────────────────────────────────

class BusLocationSnapshot {
  const BusLocationSnapshot({
    required this.busId,
    required this.plateNumber,
    required this.routeName,
    required this.driverName,
    required this.latitude,
    required this.longitude,
    required this.speedMph,
    required this.updatedAt,
  });

  final String   busId;
  final String   plateNumber;
  final String   routeName;
  final String   driverName;
  final double   latitude;
  final double   longitude;
  final double   speedMph;
  final DateTime updatedAt;

  factory BusLocationSnapshot.fromMap(Map<String, dynamic> m) {
    final bus    = m['buses']      as Map<String, dynamic>? ?? {};
    final driver = bus['profiles'] as Map<String, dynamic>? ?? {};
    final trips  = bus['trips']    as List?;
    final route  = (trips?.isNotEmpty == true
            ? (trips!.first as Map<String, dynamic>)['routes']
            : null)
        as Map<String, dynamic>?;

    return BusLocationSnapshot(
      busId:       m['bus_id']           as String,
      plateNumber: bus['plate_number']   as String? ?? '—',
      routeName:   route?['name']        as String? ?? '—',
      driverName:  driver['full_name']   as String? ?? '—',
      latitude:    double.tryParse(m['latitude'].toString())  ?? 0,
      longitude:   double.tryParse(m['longitude'].toString()) ?? 0,
      speedMph:    double.tryParse(m['speed_mph'].toString()) ?? 0,
      updatedAt:   DateTime.tryParse(m['updated_at'] as String? ?? '') ??
                   DateTime.now(),
    );
  }
}

Future<List<BusLocationSnapshot>> _fetchFleet(SupabaseClient client) async {
  final rows = await client.from('bus_locations').select('''
    bus_id, latitude, longitude, speed_mph, updated_at,
    buses (
      plate_number,
      profiles ( full_name ),
      trips ( status, routes ( name ) )
    )
  ''');
  return (rows as List)
      .map((r) => BusLocationSnapshot.fromMap(r as Map<String, dynamic>))
      .toList();
}

final liveFleetProvider =
    StreamProvider.autoDispose<List<BusLocationSnapshot>>((ref) {
  final client     = SupabaseConfig.client;
  final controller = StreamController<List<BusLocationSnapshot>>();

  _fetchFleet(client).then(controller.add).catchError(controller.addError);

  final channel = client
      .channel('admin_fleet_channel')
      .onPostgresChanges(
        event:    PostgresChangeEvent.all,
        schema:   'public',
        table:    'bus_locations',
        callback: (_) => _fetchFleet(client)
            .then(controller.add)
            .catchError(controller.addError),
      )
      .subscribe();

  ref.onDispose(() {
    client.removeChannel(channel);
    controller.close();
  });

  return controller.stream;
});

// ── Drivers list ──────────────────────────────────────────────────────────

class DriverProfile {
  const DriverProfile({
    required this.id,
    required this.fullName,
    required this.status,
    this.phone,
    this.routeName,
    this.applicationId,
  });

  final String  id;
  final String  fullName;
  final String? phone;
  final String  status;
  final String? routeName;
  final String? applicationId;

  factory DriverProfile.fromMap(Map<String, dynamic> m) {
    final trips = m['trips'] as List?;
    final route = trips?.isNotEmpty == true
        ? (trips!.first as Map<String, dynamic>)['routes']
            as Map<String, dynamic>?
        : null;
    final apps = m['driver_applications'] as List?;
    return DriverProfile(
      id:            m['id']        as String,
      fullName:      m['full_name'] as String? ?? '—',
      phone:         m['phone']     as String?,
      status:        m['status']    as String? ?? 'active',
      routeName:     route?['name'] as String?,
      applicationId: apps?.isNotEmpty == true
          ? (apps!.first as Map<String, dynamic>)['id'] as String?
          : null,
    );
  }
}

final driversProvider =
    FutureProvider.autoDispose<List<DriverProfile>>((ref) async {
  try {
    final rows = await SupabaseConfig.client
        .from('profiles')
        .select('''
          id, full_name, phone, status,
          trips ( status, routes ( name ) ),
          driver_applications ( id, status )
        ''')
        .eq('role', 'driver')
        .order('full_name');
    return (rows as List)
        .map((r) => DriverProfile.fromMap(r as Map<String, dynamic>))
        .toList();
  } catch (e) {
    throw mapException(e);
  }
});

// Search query for driver management screen
class _SearchNotifier extends Notifier<String> {
  @override
  String build() => '';
  void update(String q) => state = q;
}

final driverSearchQueryProvider =
    NotifierProvider<_SearchNotifier, String>(_SearchNotifier.new);

final filteredDriversProvider =
    Provider.autoDispose<AsyncValue<List<DriverProfile>>>((ref) {
  final query   = ref.watch(driverSearchQueryProvider).toLowerCase();
  final drivers = ref.watch(driversProvider);
  return drivers.whenData((list) {
    if (query.isEmpty) return list;
    return list
        .where((d) =>
            d.fullName.toLowerCase().contains(query) ||
            (d.phone?.contains(query) ?? false))
        .toList();
  });
});

// ── Driver status notifier (Riverpod v3) ─────────────────────────────────

class DriverStatusNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> updateStatus(String driverId, String newStatus) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await SupabaseConfig.client.rpc(
        'admin_update_driver_status',
        params: {'p_driver_id': driverId, 'p_status': newStatus},
      );
    });
  }
}

final driverStatusProvider =
    NotifierProvider.autoDispose<DriverStatusNotifier, AsyncValue<void>>(
  DriverStatusNotifier.new,
);

// ── Dashboard KPIs ────────────────────────────────────────────────────────

class DashboardKpis {
  const DashboardKpis({
    required this.totalBuses,
    required this.activeDrivers,
    required this.totalPassengers,
    required this.totalRevenue,
    required this.recentAlerts,
    required this.revenueByDay,
  });

  final int                        totalBuses;
  final int                        activeDrivers;
  final int                        totalPassengers;
  final double                     totalRevenue;
  final List<Map<String, dynamic>> recentAlerts;
  final List<double>               revenueByDay; // 7 slots, oldest→newest
}

/// Helper: count rows matching the given equality filters.
Future<int> _countRows(
  SupabaseClient client,
  String table,
  Map<String, String> eqFilters,
) async {
  var q = client.from(table).select('id');
  for (final entry in eqFilters.entries) {
    q = q.eq(entry.key, entry.value);
  }
  final res = await q;
  return (res as List).length;
}

final dashboardKpisProvider =
    FutureProvider.autoDispose<DashboardKpis>((ref) async {
  final client = SupabaseConfig.client;

  try {
    // Sequential queries — avoids Future.wait type inference issues
    final totalBuses      = await _countRows(client, 'buses', {'status': 'active'});
    final activeDrivers   = await _countRows(client, 'profiles', {'role': 'driver', 'status': 'active'});
    final totalPassengers = await _countRows(client, 'profiles', {'role': 'passenger'});

    final revRows = await client
        .from('wallet_transactions')
        .select('amount')
        .eq('type', 'ticket_purchase');

    final alertRows = await client
        .from('driver_alerts')
        .select('type, created_at, profiles(full_name), buses(plate_number)')
        .eq('resolved', false)
        .order('created_at', ascending: false)
        .limit(5);

    final txRows = await client
        .from('wallet_transactions')
        .select('amount, created_at')
        .eq('type', 'ticket_purchase')
        .gte('created_at',
            DateTime.now().subtract(const Duration(days: 7)).toIso8601String());

    final totalRevenue = (revRows as List).fold<double>(
      0,
      (sum, r) =>
          sum + (double.tryParse((r as Map)['amount'].toString()) ?? 0),
    );

    final recentAlerts = (alertRows as List)
        .map((r) => r as Map<String, dynamic>)
        .toList();

    final now   = DateTime.now();
    final byDay = List<double>.filled(7, 0);
    for (final r in txRows as List) {
      final dt =
          DateTime.tryParse((r as Map)['created_at'] as String? ?? '');
      if (dt == null) continue;
      final idx = now.difference(dt).inDays;
      if (idx >= 0 && idx < 7) {
        byDay[6 - idx] += double.tryParse(r['amount'].toString()) ?? 0;
      }
    }

    return DashboardKpis(
      totalBuses:      totalBuses,
      activeDrivers:   activeDrivers,
      totalPassengers: totalPassengers,
      totalRevenue:    totalRevenue,
      recentAlerts:    recentAlerts,
      revenueByDay:    byDay,
    );
  } catch (e) {
    throw mapException(e);
  }
});
