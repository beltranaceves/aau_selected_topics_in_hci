import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

void main() {
  runApp(const GeolocalizationApp());
}

class GeolocalizationApp extends StatelessWidget {
  const GeolocalizationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Geolocation App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const LocationScreen(),
    );
  }
}

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  double _latitude = 0.0;
  double _longitude = 0.0;
  String _address = 'No address found';
  bool _isLoading = false;
  late MapController _mapController;
  StreamSubscription<Position>? _positionStreamSubscription;
  bool _isTracking = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      Position position = await _determinePosition();
      await _updateLocation(position.latitude, position.longitude);
    } catch (e) {
      _showErrorSnackBar('Error getting location: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateLocation(double latitude, double longitude) async {
    setState(() {
      _latitude = latitude;
      _longitude = longitude;
    });

    // Move map to new location
    _mapController.move(LatLng(latitude, longitude), 15.0);

    // Get address from coordinates
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _address = '${place.street ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}';
        });
      }
    } catch (e) {
      setState(() {
        _address = 'Address not available';
      });
    }
  }

  void _toggleTracking() {
    if (_isTracking) {
      // Stop tracking
      _positionStreamSubscription?.cancel();
      _positionStreamSubscription = null;
      setState(() {
        _isTracking = false;
      });
    } else {
      // Start tracking
      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10, // Update every 10 meters
        ),
      ).listen((Position position) {
        _updateLocation(position.latitude, position.longitude);
      });
      setState(() {
        _isTracking = true;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Geolocation App'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(_isTracking ? Icons.location_off : Icons.location_on),
            onPressed: _toggleTracking,
            tooltip: _isTracking ? 'Stop Tracking' : 'Start Tracking',
          ),
        ],
      ),
      body: Column(
        children: [
          // Top third - Location information
          Container(
            height: MediaQuery.of(context).size.height * 0.33,
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Current Location',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 16),
                if (_isLoading)
                  const CircularProgressIndicator()
                else ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.location_on, color: Colors.red),
                            const SizedBox(width: 8),
                            Text(
                              'Lat: ${_latitude.toStringAsFixed(6)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Lng: ${_longitude.toStringAsFixed(6)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.home, color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _address,
                            style: const TextStyle(fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Bottom two thirds - Interactive map
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: LatLng(_latitude, _longitude),
                initialZoom: 15.0,
                minZoom: 3.0,
                maxZoom: 18.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.geolocalization_app',
                  maxZoom: 19,
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(_latitude, _longitude),
                      width: 40,
                      height: 40,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person_pin_circle,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentLocation,
        tooltip: 'Get Current Location',
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.my_location),
      ),
    );
  }
}