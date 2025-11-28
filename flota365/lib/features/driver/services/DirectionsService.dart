import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DirectionsService {

  static const String apiKey = "TU_API_KEY";

  static Future<DirectionsResult?> getRoute(
      LatLng origin, LatLng destination) async {

    final url = Uri.parse(
      "https://maps.googleapis.com/maps/api/directions/json"
      "?origin=${origin.latitude},${origin.longitude}"
      "&destination=${destination.latitude},${destination.longitude}"
      "&mode=driving"
      "&key=$apiKey",
    );

    final response = await http.get(url);

    if (response.statusCode != 200) return null;

    final data = jsonDecode(response.body);

    if (data["routes"].isEmpty) return null;

    final route = data["routes"][0];
    final leg = route["legs"][0];

    return DirectionsResult(
      polyline: route["overview_polyline"]["points"],
      distanceText: leg["distance"]["text"],
      durationText: leg["duration"]["text"],
    );
  }
}

class DirectionsResult {
  final String polyline;
  final String distanceText;
  final String durationText;

  DirectionsResult({
    required this.polyline,
    required this.distanceText,
    required this.durationText,
  });
}
