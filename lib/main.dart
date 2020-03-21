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
  static Preferences _preferences = Preferences(); //klasa preferencji. Z niej można ustawiać i czytać dane z pamięci telefonu  (home location)
  static UserLocation _homeLocation = UserLocation(lat: 52.32297, lng: 20.95187); //to startowa pozycja domu. Użytkownik musi ją ustawić tylko przy pierwzym uruchomieniu aplikacji a potem czytamy ją z Preferences
  static NotificationService _notificationService = NotificationService(); //serwis powiadomien
  static ApiService _apiService = ApiService(30, _notificationService); //Serwis api
  static LocationService _locationService = LocationService(_homeLocation, _notificationService, _apiService); //Serwis lokalizacji
  static Stream _locationStream = _locationService.locationStream; //To stream zwracający nową lokalizacje użytkownika kiedy się zmieni o 10m. Zasubskrybowanie powoduje ze wykonuje się to niezależnie od reszty kodu.
  static Stream _placesStream = _apiService.placesStream; //To samo ale z miejscami


  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  //Center to koordynaty na ktorych wyswietli się mapa. Musisz aktualizować to z _locationStream, który zwraca obiekt UserLocation (zobacz sobie w models/user_location.dart)
  static const LatLng _center = const LatLng(45.521563, -122.677433);


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
          title: Text('Maps Sample App'),
          backgroundColor: Colors.green[700],
        ),
        body: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _center,
            zoom: 11.0,
          ),

            //to lista kółek, którą musisz updatować przez stream _placesStream. Zwraca on liste obiektów Place (zobacz sobie w models/place_model.dart). Musisz dla każdego miejsca zrobić kółko.
            circles: Set.from([Circle(
            circleId: CircleId("a"), //to moze byc cokolwiek
            center: _center, //lokalizacja miejsca (tu jest center ale zmien na tą z obiektu)
            radius: 4000, //radius z place
              //zrób im czerwony kolor
          )])

        ),
      ),
    );
  }
}