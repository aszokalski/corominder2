import 'package:corominder2/models/user_location.dart';
import 'package:corominder2/models/place_model.dart';
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

  List<Place> _places;
  
  ApiService(this._densityThreshold);

  //calculate distance between 2 coordinates
  double calculateDistance(lat1, lon1, lat2, lon2){
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p)/2 +
        c(lat1 * p) * c(lat2 * p) *
            (1 - c((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a));
  }

  void updateLocation(_newLocation){
      //calculate the distance between last update location and current location
      double _distanceDelta = 1;
      if(this._lastUpdateLocation != null){
        _distanceDelta = calculateDistance(_lastUpdateLocation.lat, _lastUpdateLocation.lng,
            _newLocation.lat, _newLocation.lng);
      }

      //if the distance is grater or equal 200m trigger api update
      if(_distanceDelta >= 0.2){
        print(_newLocation.lat);
        print(_newLocation.lng);
        print(_distanceDelta);
        _lastUpdateLocation = _newLocation;
        updatePlaces();
      }

      amISafe();
  }

  void updatePlaces() async{
    print('update places begin');
    this._places = await fetchPlaces(http.Client(), this._lastUpdateLocation);
    print('places updated');
  }

  void amISafe() {
    print('amisafe');

    //TODO
  }

  Future<List<Place>> fetchPlaces(http.Client client, UserLocation location) async {
    final http.Response response = await http.post(
      'http://35.239.36.121/api/get_crowded_places',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'lat': location.lat,
        'lng' : location.lng,
        'threshold' : this._densityThreshold,
      }),
    );
    print(response.body);
    return parsePlaces(response.body);
  }

  List<Place> parsePlaces(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();

    return parsed.map<Place>((json) => Place.fromJson(json)).toList();
  }

}