import 'dart:async';
import 'dart:math' show cos, sqrt, asin;

import 'package:location/location.dart';
import 'package:corominder2/models/user_location.dart';
import 'package:corominder2/services/notification_service.dart';


class LocationService{

    //our custom object that stores current user's location
    UserLocation _currentLocation;

    //current location state

    LocationState _locationState;

    //object that defines user's home coordinates
    UserLocation _homeLocation;

    //notification service
    NotificationService _notificationService;

    //location service
    Location location = Location();

    //stream object that stores changes in _currentLocation
    // ignore: close_sinks
    StreamController<UserLocation> _locationController = StreamController<UserLocation>.broadcast();
    Stream<UserLocation> get locationStream => _locationController.stream;

    //constructor(takes user's location as an argument)
    LocationService(this._homeLocation, this._notificationService){
        //Request permission
        location.requestPermission().then((granted) {
            if (granted != null) {
                // If granted listen to the onLocationChanged stream and emit over our controller
                location.onLocationChanged().listen((locationData) {
                    if (locationData != null) {
                        //set new location
                        _currentLocation = UserLocation(
                            lat: locationData.latitude,
                            lng: locationData.longitude,
                        );

                        //check if the user was away from home before changing location
                        bool wasAway = isAway();
                        //update location state
                        updateLocationState();
                        //check if the user came back home
                        if(!isAway() && wasAway){
                            //trigger reminder to wash hands
                            _notificationService.pushNotification('Wash your hands!');
                        }
                        _locationController.add(_currentLocation);


                    }
                });
            }
        });
    }

//CORE FUNCTIONS

    //async function that reads location into _currentLocation object
    Future<UserLocation> getLocation() async{
        try{
            var userLocation = await location.getLocation();
            _currentLocation = UserLocation(
                lat: userLocation.latitude,
                lng: userLocation.longitude,
            );
        }catch(e){
            print('Could not get location ${e.toString()}');
        }
    }

//HELPER FUNCTIONS
    void updateLocationState(){
        try{
            final _distanceFromHome = calculateDistance(this._homeLocation.lat, this._homeLocation.lng,
                this._currentLocation.lat, this._currentLocation.lng);

            if(_distanceFromHome >= 0.1){
                _locationState = LocationState.AWAY;
            } else{
                _locationState = LocationState.HOME;
            }
        } catch(e){
            print('Could not update location state ${e.toString()}');
        }
    }

    bool isAway(){
        return (_locationState == LocationState.AWAY);
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