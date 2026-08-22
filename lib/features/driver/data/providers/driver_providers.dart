import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/config/supabase_config.dart';
import '../../../../core/errors/app_exception.dart';

// ── Assignment model ──────────────────────────────────────────────────────

class DriverAssignment {
  const DriverAssignment({
    required this.tripId,
    required this.busId,
    required this.plateNumber,
    required this.model,
    required this.capacity,
    required this.routeName,
    required this.routeId,
    this.safetyScore = 100,
  });

  final String tripId;
  final String busId;
  final String plateNumber;
  final String model;
  final int    capacity;
  final String routeName;
  final String routeId;
  final int    safetyScore;

  factory DriverAssignment.fromMap(Map<String, dynamic> m) {
    final bus   = m['buses']  as Map<String, dynamic>? ?? {};
    final route = m['routes'] as Map<String, dynamic>? ?? {};
    return DriverAssignment(
      tripId:      m['id']             as String,
      busId:       m['bus_id']         as String,
      plateNumber: bus['plate_number'] as String? ?? '—',
      model:       bus['model']        as String? ?? '—',
      capacity:    bus['capacity']     as int?    ?? 0,
      routeName:   route['name']       as String? ?? '—',
      routeId:     m['route_id']       as String,
    );
  }
}

final driverAssignmentProvider =
    FutureProvider.autoDispose<DriverAssignment?>((ref) async {
  final uid = SupabaseConfig.currentUser?.id;
  if (uid == null) throw const NotAuthenticatedException();
  try {
    final rows = await SupabaseConfig.client
        .from('trips')
        .select('*, buses(plate_number, model, capacity), routes(name)')
        .eq('driver_id', uid)
        .eq('status', 'active')
        .limit(1);
    final list = rows as List;
    if (list.isEmpty) return null;
    return DriverAssignment.fromMap(list.first as Map<String, dynamic>);
  } catch (e) {
    throw mapException(e);
  }
});

// ── Trip notifier ─────────────────────────────────────────────────────────

class TripNotifier extends Notifier<AsyncValue<String?>> {
  @override
  AsyncValue<String?> build() => const AsyncValue.data(null);

  Future<void> startTrip({
    required String busId,
    required String routeId,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final uid = SupabaseConfig.currentUser?.id;
      if (uid == null) throw const NotAuthenticatedException();

      final row = await SupabaseConfig.client
          .from('trips')
          .insert({
            'driver_id': uid,
            'bus_id':    busId,
            'route_id':  routeId,
            'status':    'active',
          })
          .select('id')
          .single();

      await SupabaseConfig.client
          .from('buses')
          .update({'current_driver_id': uid})
          .eq('id', busId);

      return row['id'] as String;
    });
  }

  Future<void> endTrip({
    required String tripId,
    required String busId,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await SupabaseConfig.client
          .from('trips')
          .update({
            'status':   'completed',
            'ended_at': DateTime.now().toIso8601String(),
          })
          .eq('id', tripId);

      await SupabaseConfig.client
          .from('bus_locations')
          .delete()
          .eq('bus_id', busId);

      await SupabaseConfig.client
          .from('buses')
          .update({'current_driver_id': null})
          .eq('id', busId);

      return null;
    });
  }
}

final tripNotifierProvider =
    NotifierProvider.autoDispose<TripNotifier, AsyncValue<String?>>(
  TripNotifier.new,
);

// ── GPS location broadcaster ──────────────────────────────────────────────

class LocationBroadcaster extends Notifier<double> {
  StreamSubscription<Position>? _sub;

  @override
  double build() => 0;

  Future<void> start({required String busId, required String tripId}) async {
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.deniedForever) return;

    _sub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy:       LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((pos) async {
      final speedMph = pos.speed * 2.23694;
      state = speedMph;
      try {
        await SupabaseConfig.client.from('bus_locations').upsert(
          {
            'bus_id':     busId,
            'trip_id':    tripId,
            'latitude':   pos.latitude,
            'longitude':  pos.longitude,
            'speed_mph':  speedMph,
            'heading':    pos.heading,
            'updated_at': DateTime.now().toIso8601String(),
          },
          onConflict: 'bus_id',
        );
      } catch (_) {
        // Ignore transient network errors during GPS updates
      }
    });
  }

  void stop() {
    _sub?.cancel();
    _sub = null;
    state = 0;
  }
}

final locationBroadcasterProvider =
    NotifierProvider.autoDispose<LocationBroadcaster, double>(
  LocationBroadcaster.new,
);
