class UserLocation{
  //this object is used for storing user's location
  final double lat;
  final double lng;

  UserLocation({this.lat, this.lng});
}

enum LocationState {
  HOME,
  AWAY,
}