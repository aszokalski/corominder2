import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:corominder2/models/user_location.dart';
import 'package:corominder2/services/location_service.dart';
import 'package:corominder2/services/api_service.dart';
import 'package:corominder2/services/notification_service.dart';

void main() => runApp(MyApp());



class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();

}

class _MyAppState extends State<MyApp> {

  //creating location service with home location
  static UserLocation _homeLocation = UserLocation(lat: 52.32297, lng: 20.95187);
  static NotificationService _notificationService = NotificationService();
  static ApiService _apiService = ApiService(30);
  static Stream _locationStream = LocationService(_homeLocation, _notificationService, _apiService).locationStream;

  //subscribe to locationStream

  @override
  Widget build(BuildContext context) {
    _locationStream.listen((location){

    });
    return MaterialApp(
      home: Scaffold(

      ),
    );
  }
}