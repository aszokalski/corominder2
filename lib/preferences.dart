import 'package:shared_preferences/shared_preferences.dart';
import 'package:corominder2/models/user_location.dart';

class Preferences{

Preferences();

Future<UserLocation> getHomeLocation() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  final lat = prefs.getDouble("lat");
  final lng = prefs.getDouble("lng");

  if(lat == null){
    return UserLocation();
  }

  return UserLocation(lat: lat, lng: lng);
}

Future<bool> setHomeLocation(UserLocation value) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  final a = await prefs.setDouble("lat", value.lat);
  final b = await prefs.setDouble("lng", value.lng);

  return (a && b);
}

}