import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geofence_service/geofence_service.dart';

final geofencingServiceProvider = Provider((ref) => GeofencingService());

class GeofencingService {
  final GeofenceService _geofenceService = GeofenceService.instance.setup(
    interval: 5000,
    accuracy: 100,
    loiteringDelayMs: 60000,
    statusChangeDelayMs: 10000,
    useActivityRecognition: true,
    allowMockLocations: false,
    printDevLog: true,
    geofenceRadiusSortType: GeofenceRadiusSortType.DESC,
  );

  final List<Geofence> _geofenceList = [];

  Future<bool> checkPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  Future<Position?> getCurrentLocation() async {
    if (!await checkPermissions()) {
      return null;
    }

    return await Geolocator.getCurrentPosition();
  }

  void addGeofence({
    required String id,
    required double latitude,
    required double longitude,
    required double radius,
  }) {
    _geofenceList.add(
      Geofence(
        id: id,
        latitude: latitude,
        longitude: longitude,
        radius: [
          GeofenceRadius(id: 'radius_$radius', length: radius),
        ],
      ),
    );
  }

  Future<void> startGeofencing({
    required Function(Geofence, GeofenceRadius, GeofenceStatus) onGeofenceStatusChanged,
  }) async {
    await _geofenceService.addGeofenceStatusChangeListener(onGeofenceStatusChanged);
    await _geofenceService.start(_geofenceList).catchError((error) {
      return null;
    });
  }

  Future<void> stopGeofencing() async {
    await _geofenceService.stop();
  }

  Stream<Position> get positionStream {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  }
}
