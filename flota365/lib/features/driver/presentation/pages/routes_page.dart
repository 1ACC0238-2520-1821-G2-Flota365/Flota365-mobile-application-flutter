import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

import '../../data/driver_repository.dart';
import '../../data/driver_service.dart';
import '../blocs/routes/routes_bloc.dart';
import '../blocs/routes/routes_event.dart';
import '../blocs/routes/routes_state.dart';
import '../../domain/entities/assignmentEntity.dart';

class RoutesPage extends StatelessWidget {
  final int driverId;

  const RoutesPage({super.key, required this.driverId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          RoutesBloc(DriverRepository(DriverService()))
            ..add(RoutesLoadRequested(driverId)),
      child: _RoutesView(driverId: driverId),
    );
  }
}

class _RoutesView extends StatefulWidget {
  final int driverId;
  const _RoutesView({required this.driverId});

  @override
  State<_RoutesView> createState() => _RoutesViewState();
}

class _RoutesViewState extends State<_RoutesView> {
  GoogleMapController? mapController;
  LatLng? myLocation;
  bool mapReady = false;

  AssignmentEntity? selectedRoute;

  Set<Marker> markers = {};
  Set<Polyline> polylines = {};

  final String gMapsKey = "API_KEY";

  @override
  void initState() {
    super.initState();
    _loadMyLocation();
  }

 
  //   UBICACIÓN DEL USUARIO
  // ================================
  Future<void> _loadMyLocation() async {
    try {
      bool enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return;

      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }

      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) return;

      final pos = await Geolocator.getCurrentPosition();

      setState(() {
        myLocation = LatLng(pos.latitude, pos.longitude);
      });

      if (mapReady) {
        mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(myLocation!, 15),
        );
      }
    } catch (_) {}
  }


  //     NORMALIZAR DIRECCIÓN
  // ================================
  String normalizeAddress(String address) {
    address = address.trim();
    if (address.isEmpty || address.toLowerCase() == "string") return "";
    if (!address.toLowerCase().contains("lima")) {
      address = "$address, Lima, Peru";
    }
    return address;
  }

 
  //          GEOCODING
  // ================================
  Future<LatLng?> geocode(String query) async {
    final url = Uri.parse(
        "https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(query)}&key=$gMapsKey");

    final res = await http.get(url);
    final data = jsonDecode(res.body);

    if (data["status"] != "OK") return null;

    final loc = data["results"][0]["geometry"]["location"];
    return LatLng(loc["lat"], loc["lng"]);
  }


  //     PINTAR RUTA COMPLETA
  // ================================
  Future<void> loadRouteOnMap(AssignmentEntity r) async {
    if (!r.route.contains("->")) return;

    final parts = r.route.split("->");
    final origin = normalizeAddress(parts[0]);
    final dest = normalizeAddress(parts[1]);

    print("GEOCODING ORIGIN: $origin");
    print("GEOCODING DEST: $dest");

    final o = await geocode(origin);
    final d = await geocode(dest);

    if (o == null || d == null) {
      print("No se pudo geocodificar");
      return;
    }

    // ROUTES API
    final url = Uri.parse(
        "https://routes.googleapis.com/directions/v2:computeRoutes");

    final body = {
      "origin": {
        "location": {
          "latLng": {"latitude": o.latitude, "longitude": o.longitude}
        }
      },
      "destination": {
        "location": {
          "latLng": {"latitude": d.latitude, "longitude": d.longitude}
        }
      },
      "travelMode": "DRIVE"
    };

    final res = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "X-Goog-Api-Key": gMapsKey,
        "X-Goog-FieldMask":
            "routes.duration,routes.distanceMeters,routes.polyline.encodedPolyline",
      },
      body: jsonEncode(body),
    );

    final data = jsonDecode(res.body);

    if (data["routes"] == null || data["routes"].isEmpty) {
      print("No route found");
      return;
    }

    final encoded = data["routes"][0]["polyline"]["encodedPolyline"];
    final decoded = PolylinePoints.decodePolyline(encoded);

    final coords =
        decoded.map((p) => LatLng(p.latitude, p.longitude)).toList();

    setState(() {
      markers = {
        Marker(markerId: MarkerId("start"), position: coords.first),
        Marker(markerId: MarkerId("end"), position: coords.last),
      };

      polylines = {
        Polyline(
          polylineId: PolylineId("route"),
          width: 5,
          color: Colors.blue,
          points: coords,
        )
      };
    });

    fitToPolyline(coords);
  }

  void fitToPolyline(List<LatLng> coords) {
    final swLat = coords.map((c) => c.latitude).reduce((a, b) => a < b ? a : b);
    final swLng =
        coords.map((c) => c.longitude).reduce((a, b) => a < b ? a : b);
    final neLat = coords.map((c) => c.latitude).reduce((a, b) => a > b ? a : b);
    final neLng =
        coords.map((c) => c.longitude).reduce((a, b) => a > b ? a : b);

    mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(swLat, swLng),
          northeast: LatLng(neLat, neLng),
        ),
        40,
      ),
    );
  }


  //              UI
  // ================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mis Rutas")),
      body: BlocBuilder<RoutesBloc, RoutesState>(
        builder: (context, state) {
          return Stack(
            children: [
              Positioned.fill(
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: myLocation ?? LatLng(19.43, -99.13),
                    zoom: 13,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  markers: markers,
                  polylines: polylines,
                  onMapCreated: (c) {
                    mapController = c;
                    mapReady = true;

                    if (myLocation != null) {
                      mapController!.animateCamera(
                        CameraUpdate.newLatLngZoom(myLocation!, 15),
                      );
                    }
                  },
                ),
              ),

              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _bottomCard(state),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _bottomCard(RoutesState state) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(blurRadius: 10, color: Colors.black26),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<AssignmentEntity>(
            value: selectedRoute,
            decoration: InputDecoration(
              labelText: "Selecciona una ruta",
              border: OutlineInputBorder(),
            ),
            items: [
              DropdownMenuItem(
                value: null,
                child: Text("--- Selecciona una ruta ---"),
              ),
              ...state.routes.map((r) {
                return DropdownMenuItem(
                  value: r,
                  child: Text(r.route, overflow: TextOverflow.ellipsis),
                );
              }),
            ],
            onChanged: (r) async {
              selectedRoute = r;
              markers.clear();
              polylines.clear();
              setState(() {});

              if (r != null) {
                await loadRouteOnMap(r);
              }
            },
          ),

          SizedBox(height: 16),

          if (selectedRoute != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                child: Text("Ver detalle de la ruta"),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    "/route-detail",
                    arguments: selectedRoute!.id,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
