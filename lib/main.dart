import 'dart:async';

import 'package:flutter/material.dart';
import 'package:corominder2/models/user_location.dart';
import 'package:corominder2/models/place_model.dart';
import 'package:corominder2/services/location_service.dart';
import 'package:corominder2/services/api_service.dart';
import 'package:corominder2/services/notification_service.dart';
import 'package:corominder2/preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() => runApp(MyApp());



class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();

}

class _MyAppState extends State<MyApp> {
  //google maps stuff
  Completer<GoogleMapController> _controller = Completer();

  //set up all services
  static Preferences _preferences = Preferences(); //klasa preferencji. Z niej można ustawiać i czytać dane z pamięci telefonu  (home location)
  static UserLocation _homeLocation = UserLocation(lat: 52.32297, lng: 20.95187); //to startowa pozycja domu. Użytkownik musi ją ustawić tylko przy pierwzym uruchomieniu aplikacji a potem czytamy ją z Preferences
  static NotificationService _notificationService = NotificationService(); //serwis powiadomien
  static ApiService _apiService = ApiService(0, _notificationService); //Serwis api
  static LocationService _locationService = LocationService(_homeLocation, _notificationService, _apiService); //Serwis lokalizacji
  static Stream _locationStream = _locationService.locationStream; //To stream zwracający nową lokalizacje użytkownika kiedy się zmieni o 10m. Zasubskrybowanie powoduje ze wykonuje się to niezależnie od reszty kodu.
  static Stream _placesStream = _apiService.placesStream; //To samo ale z miejscami


  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  @override
  Widget build(BuildContext context) {
    _locationStream.listen((value){
      //to zasubskrybowany stream. Subskrybcja streamu uruchamia cały backend, więc możesz to zostawić (ale i tak użyjesz tego lub czego podobnego).
      //w konsoli będą się wywietlały informacje co do loklizacji i pobierania danych oraz powiadomienia
      //możesz mieniaćlokalizaxcje w emulartorze i symulowac chodzenie.
    });
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Crowded Places'),
          backgroundColor: Colors.green[700],
        ),
        body:Center(
          child: StreamBuilder(
            stream: _locationStream,
            builder: (context, snapshot){
              if(!snapshot.hasData){
                return CircularProgressIndicator();
              }

              UserLocation location = snapshot.data;
              final LatLng _center = LatLng(location.lat, location.lng);

              print(_apiService.places);
              return StreamBuilder(
                  stream: _placesStream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return CircularProgressIndicator();
                    }

                    List<Place> places = snapshot.data;

                    List<Circle> circle_list =[];
                    for(var i = 0; i < places.length; i++){
                      circle_list.add(Circle(
                        strokeWidth: 5,
                        strokeColor: Colors.red[700],
                        circleId: CircleId("a"),
                        center: LatLng(places[i].lat, places[i].lng),
                        radius: places[i].radius.toDouble() * 3,
                      ));
                    }
                    circle_list.add(Circle(
                      strokeWidth: 0,
                      fillColor: Colors.blue[700],
                      circleId: CircleId("you"),
                      center: _center,
                      radius: 100,
                    ));

                    Set<Circle> circles = Set.from(circle_list);


                    return GoogleMap(
                        onMapCreated: _onMapCreated,
                        initialCameraPosition: CameraPosition(
                            target: _center,
                            zoom: 11.0,
                        ),
                        circles: circles,
                        );
                    }
                  );
            },
          )
        ),
      ),
    );
  }
}