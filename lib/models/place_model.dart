class Place {
  final double lat;
  final double lng;
  final int radius;
  int distance;

  Place({this.lat, this.lng, this.radius});

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      lat: json['coordinates']['lat'] as double,
      lng: json['coordinates']['lng'] as double,
      radius: json['radius'] as int,
    );
  }
}