import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:corominder2/models/user_location.dart';
import 'package:corominder2/services/location_service.dart';
import 'package:corominder2/services/api_service.dart';
import 'package:corominder2/services/notification_service.dart';
import 'package:corominder2/preferences.dart';

void main() => runApp(MyApp());



class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();

}

class _MyAppState extends State<MyApp> {
  //google maps stuff
  Completer<GoogleMapController> _controller = Completer();

  //set up all services
  static UserLocation _homeLocation = UserLocation(lat: 52.32297, lng: 20.95187);
  static NotificationService _notificationService = NotificationService();
  static ApiService _apiService = ApiService(30, _notificationService);
  static LocationService _locationService = LocationService(_homeLocation, _notificationService, _apiService);
  static Stream _locationStream = _locationService.locationStream;


  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  Set<Circle> circles = Set.from([Circle(
    circleId: CircleId("a"),
    center: _center,
    radius: 4000,
  )]);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      home: Scaffold(
        appBar: AppBar(
          title: Text('Maps Sample App'),
          backgroundColor: Colors.green[700],
        ),
        body: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _center,
            zoom: 11.0,
          ),
          circles: circles,
        ),
      ),
    );
  }
}