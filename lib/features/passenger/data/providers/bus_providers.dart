import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/supabase_config.dart';
import '../../../../core/errors/app_exception.dart';

/// A nearby bus entry composed from buses + active trips + bus_locations.
class NearbyBus {
  const NearbyBus({
    required this.busId,
    required this.plateNumber,
    required this.routeName,
    required this.routeId,
    required this.via,
    required this.latitude,
    required this.longitude,
    required this.speedMph,
    this.etaMinutes,
  });

  final String  busId;
  final String  plateNumber;
  final String  routeName;
  final String  routeId;
  final String  via;       // "via <first stop name>"
  final double  latitude;
  final double  longitude;
  final double  speedMph;
  final int?    etaMinutes; // null = not calculable yet

  factory NearbyBus.fromMap(Map<String, dynamic> m) {
    final loc = m['bus_locations'] as Map<String, dynamic>? ?? {};
    final trip = m['trips'] as Map<String, dynamic>? ?? {};
    final route = trip['routes'] as Map<String, dynamic>? ?? {};

    return NearbyBus(
      busId:       m['id']          as String,
      plateNumber: m['plate_number'] as String,
      routeName:   route['name']    as String? ?? 'Unknown Route',
      routeId:     (trip['route_id'] as String?) ?? '',
      via:         route['name']    as String? ?? '',
      latitude:    double.tryParse(loc['latitude']?.toString()  ?? '0') ?? 0,
      longitude:   double.tryParse(loc['longitude']?.toString() ?? '0') ?? 0,
      speedMph:    double.tryParse(loc['speed_mph']?.toString() ?? '0') ?? 0,
    );
  }
}

/// Fetches all buses with an active trip and a known GPS location.
/// Returns an empty list (not an error) when no buses are active.
final nearbyBusesProvider =
    FutureProvider.autoDispose<List<NearbyBus>>((ref) async {
  try {
    final rows = await SupabaseConfig.client
        .from('buses')
        .select('''
          id,
          plate_number,
          bus_locations ( latitude, longitude, speed_mph, updated_at ),
          trips!inner (
            id, route_id, status,
            routes ( name )
          )
        ''')
        .eq('status', 'active')
        .eq('trips.status', 'active')
        .not('bus_locations', 'is', null);

    return (rows as List)
        .map((r) => NearbyBus.fromMap(r as Map<String, dynamic>))
        .toList();
  } catch (e) {
    throw mapException(e);
  }
});

/// All active (is_active = true) routes — used in BuyTicketScreen dropdown.
final activeRoutesProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  try {
    final rows = await SupabaseConfig.client
        .from('routes')
        .select('id, name')
        .eq('is_active', true)
        .order('name');
    return List<Map<String, dynamic>>.from(rows as List);
  } catch (e) {
    throw mapException(e);
  }
});
