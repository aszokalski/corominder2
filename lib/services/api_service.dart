import 'dart:async';
import 'package:corominder2/models/user_location.dart';
import 'package:corominder2/models/place_model.dart';
import 'package:corominder2/services/notification_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'dart:math' show cos, sqrt, asin;
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService{

  final api_link = "http://35.239.36.121/api/get_crowded_places/";

  //population density required to consider place crowded
  final int _densityThreshold;

  //location of last api call
  UserLocation _lastUpdateLocation;

  //notification service
  NotificationService _notificationService;

  //indicates if the object is new
  bool fresh = true;

  //list of saved places
  List<Place> places;

  //stream object that stores changes in _currentLocation that updates every 10m
  // ignore: close_sinks
  StreamController<List<Place>> _placesController = StreamController<List<Place>>.broadcast();
  Stream<List<Place>> get placesStream => _placesController.stream;
  
  ApiService(this._densityThreshold, this._notificationService){}

  void updateLocation(_newLocation){
      //calculate the distance between last update location and current location
      double _distanceDelta = 1;
      if(this._lastUpdateLocation != null){
        _distanceDelta = calculateDistance(_lastUpdateLocation.lat, _lastUpdateLocation.lng,
            _newLocation.lat, _newLocation.lng);
      }

      if(fresh) {
        updatePlaces(_newLocation);
        fresh = false;
      }

      //if the distance is grater or equal 200m trigger api update
      if(_distanceDelta >= 0.2){
        print(_newLocation.lat);
        print(_newLocation.lng);
        print(_distanceDelta);
        _lastUpdateLocation = _newLocation;
        updatePlaces(_newLocation);
      }

      amISafe(_newLocation);
  }

  void updatePlaces(location) async{
    print('update places begin');
    this.places = await fetchPlaces(http.Client(), location);
    print('places updated');
    print(places);
    this._placesController.add(this.places);
    this.amISafe(location);
  }

  void amISafe(location) async{
    print('amisafe');
    bool safe = true;
    List<Place> threats = [];

    if(places == null){
      return;
    }

    for(var i = 0; i < this.places.length; i++){
      Place _place = places[i];
      _place.distance = (this.calculateDistance(location.lat, location.lng, _place.lat, _place.lng) * 1000).toInt();
      if(_place.distance <= _place.radius * 3){
        safe = false;
        threats.add(_place);
      }
    }

    if(!safe){
      this._notificationService.pushNotification("⚠️ You are near a crowded area. Avoid touching your face and proceed with caution (" + threats[0].distance.toString() + 'm)');
    }
  }

  Future<List<Place>> fetchPlaces(http.Client client, UserLocation location) async {
    final body = jsonEncode(<String, dynamic>{
      'lat': location.lat,
      'lng' : location.lng,
      'threshold' : this._densityThreshold,
    });

    final http.Response response = await http.post(
      'http://35.239.36.121/api/get_crowded_places',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: body,
    );

    print(response.body);
    return parsePlaces(response.body);
  }

  List<Place> parsePlaces(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();

    return parsed.map<Place>((json) => Place.fromJson(json)).toList();
  }

  //calculate distance between 2 coordinates
  double calculateDistance(lat1, lon1, lat2, lon2){
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p)/2 +
        c(lat1 * p) * c(lat2 * p) *
            (1 - c((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a));
  }
}