import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';

import '../../data/driver_repository.dart';
import '../../data/driver_service.dart';
import '../blocs/route_detail/route_detail_bloc.dart';
import '../blocs/route_detail/route_detail_event.dart';
import '../blocs/route_detail/route_detail_state.dart';
import '../../domain/entities/assignmentEntity.dart';

import 'checkin_page.dart';
import 'checkout_page.dart';

class RouteDetailPage extends StatelessWidget {
  final int routeId;

  const RouteDetailPage({super.key, required this.routeId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RouteDetailBloc(DriverRepository(DriverService()))
        ..add(RouteDetailRequested(routeId)),
      child: const _RouteDetailView(),
    );
  }
}

class _RouteDetailView extends StatefulWidget {
  const _RouteDetailView();

  @override
  State<_RouteDetailView> createState() => _RouteDetailViewState();
}

class _RouteDetailViewState extends State<_RouteDetailView> {
  GoogleMapController? _controller;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  String estimatedTime = "-";
  String estimatedDistance = "-";

  AssignmentEntity? _currentAssignment;
  Timer? _trackingTimer;

  
  bool userIsInteracting = false;
  Timer? _userInteractionTimer;

  final String gMapsKey = "AIzaSyCA5tM33mMWhs2x811-qPbEvvJoENu_b1o";

  @override
  void dispose() {
    _trackingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ruta a detalle")),
      body: BlocBuilder<RouteDetailBloc, RouteDetailState>(
        builder: (context, state) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.error != null) {
            return Center(child: Text("Error: ${state.error}"));
          }
          if (state.assignment == null) {
            return const Center(child: Text("No se encontró la ruta"));
          }

          _currentAssignment = state.assignment!;

          
          if ((_currentAssignment!.status ?? "").toUpperCase() == "IN_PROGRESS") {
            final parts = _currentAssignment!.route.split("->");
            if (parts.length >= 2) {
              final destination = normalizeAddress(parts[1]);
              _startLiveTracking(destination);
            }
          }

          return _buildUI(state.assignment!);
        },
      ),
    );
  }

  Widget _buildUI(AssignmentEntity a) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: 300,
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(-12.0464, -77.0428),
                zoom: 13,
              ),
              onMapCreated: (controller) {
                _controller = controller;
                _loadRoute(a);
              },
              myLocationEnabled: true,
              markers: _markers,
              polylines: _polylines,
            
              onCameraMoveStarted: () {
                userIsInteracting = true;
                _userInteractionTimer?.cancel();
              },

              onCameraIdle: () {
                
                _userInteractionTimer = Timer(const Duration(seconds: 2), () {
                  userIsInteracting = false;
                });
              },
            ),
          ),
          const SizedBox(height: 20),
          _infoCard(a),
          const SizedBox(height: 16),
          _buildActions(a),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _infoCard(AssignmentEntity a) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Ruta: ${a.route}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _infoItem("Tiempo estimado", estimatedTime),
            _infoItem("Distancia estimada", estimatedDistance),
          ],
        ),
      ),
    );
  }

  Widget _infoItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          Flexible(child: Text(value)),
        ],
      ),
    );
  }


  //  BOTONES CHECK-IN / CHECK-OUT
  // --------------------------
  Widget _buildActions(AssignmentEntity a) {
    final status = (a.status ?? "").toUpperCase();

    // PENDING -> INICIAR
    if (status.isEmpty || status == "PENDING") {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.play_arrow),
            label: const Text("Iniciar ruta (Check-In)"),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CheckInPage(assignmentId: a.id),
                ),
              );

              if (!mounted) return;

             
              if (result == true) {
                final parts = a.route.split("->");
                if (parts.length >= 2) {
                  final destination = normalizeAddress(parts[1]);
                  _startLiveTracking(destination); 
                }
              }

              // Luego refrescamos datos desde el backend
              context.read<RouteDetailBloc>().add(RouteDetailRequested(a.id));
            },
          ),
        ),
      );
    }

    // EN CURSO -> FINALIZAR
    if (status == "IN_PROGRESS") {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.flag),
            label: const Text("Finalizar ruta (Check-Out)"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CheckOutPage(assignmentId: a.id),
                ),
              );

              if (mounted) {
                context.read<RouteDetailBloc>().add(RouteDetailRequested(a.id));
              }
            },
          ),
        ),
      );
    }

    // COMPLETADA
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.check_circle_outline),
          label: const Text("Ruta finalizada"),
          onPressed: null,
        ),
      ),
    );
  }


  //  NORMALIZAR DIRECCIONES
  // --------------------------
  String normalizeAddress(String address) {
    address = address.trim();
    if (address.isEmpty || address.toLowerCase() == "string") return "";

    if (!address.toLowerCase().contains("lima")) {
      address = "$address, Lima, Peru";
    }

    return address;
  }


  //  CARGAR RUTA INICIAL
  // --------------------------
  Future<void> _loadRoute(AssignmentEntity a) async {
    if (!a.route.contains("->")) return;

    final parts = a.route.split("->");

    final origin = normalizeAddress(parts[0]);
    final destination = normalizeAddress(parts[1]);

    await _drawRoute(origin, destination);

    if ((a.status ?? "").toUpperCase() == "IN_PROGRESS") {
      _startLiveTracking(destination);
    }
  }

 
  //  TRACKING EN VIVO
  // --------------------------
  void _startLiveTracking(String destination) {
    // Cancelar timer anterior si existía
    _trackingTimer?.cancel();
    _trackingTimer = null;

    Future<void> doUpdate() async {
      final pos = await _getMyLocation();
      if (pos == null) return;

      final origin = "${pos.latitude},${pos.longitude}";
      await _drawRoute(origin, destination);
    }

    
    doUpdate();

    _trackingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      doUpdate();
    });
  }


  //  OBTENER MI UBICACIÓN REAL
  // --------------------------
  Future<LatLng?> _getMyLocation() async {
    final perm = await Geolocator.requestPermission();
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      return null;
    }

    final pos = await Geolocator.getCurrentPosition();
    return LatLng(pos.latitude, pos.longitude);
  }


  //  API ROUTES GOOGLE
  // --------------------------
  Future<void> _drawRoute(String origin, String destination) async {
    print("ORIGEN: $origin");
    print("DESTINO: $destination");

    final o = await _geocode(origin);
    final d = await _geocode(destination);

    if (o == null || d == null) {
      print("No se pudo geocodificar");
      return;
    }

    final url = Uri.parse(
      "https://routes.googleapis.com/directions/v2:computeRoutes",
    );

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
    if (data["routes"] == null || data["routes"].isEmpty) return;

    final route = data["routes"][0];

    String formatDuration(String raw) {
      final seconds = int.tryParse(raw.replaceAll("s", "")) ?? 0;
      if (seconds < 60) return "$seconds s";
      final mins = (seconds / 60).round();
      return "$mins min";
    }

    String formatDistance(int meters) {
      if (meters < 1000) return "$meters m";
      final km = meters / 1000;
      return "${km.toStringAsFixed(2)} km";
    }

    setState(() {
      estimatedTime = formatDuration(route["duration"] ?? "");
      estimatedDistance = formatDistance(route["distanceMeters"] ?? 0);
    });

    // ------------ POLILÍNEA ---------------
    final encoded = route["polyline"]["encodedPolyline"];
    final decoded = PolylinePoints.decodePolyline(encoded);
    final coords =
        decoded.map((p) => LatLng(p.latitude, p.longitude)).toList();

    setState(() {
      _markers = {
        Marker(markerId: const MarkerId("start"), position: coords.first),
        Marker(markerId: const MarkerId("end"), position: coords.last),
      };

      _polylines = {
        Polyline(
          polylineId: const PolylineId("route"),
          width: 5,
          color: Colors.blue,
          points: coords,
        )
      };
    });

    _fitToPolyline(coords);
  }

  Future<LatLng?> _geocode(String query) async {
    final url = Uri.parse(
      "https://maps.googleapis.com/maps/api/geocode/json"
      "?address=${Uri.encodeComponent(query)}&key=$gMapsKey",
    );

    final res = await http.get(url);
    final data = jsonDecode(res.body);

    if (data["status"] != "OK") return null;

    final loc = data["results"][0]["geometry"]["location"];
    return LatLng(loc["lat"], loc["lng"]);
  }

    void _fitToPolyline(List<LatLng> coords) {
    if (userIsInteracting) return;

    if (_userInteractionTimer != null && _userInteractionTimer!.isActive) return;

 
    double minLat =
        coords.map((e) => e.latitude).reduce((a, b) => a < b ? a : b);
    double maxLat =
        coords.map((e) => e.latitude).reduce((a, b) => a > b ? a : b);
    double minLng =
        coords.map((e) => e.longitude).reduce((a, b) => a < b ? a : b);
    double maxLng =
        coords.map((e) => e.longitude).reduce((a, b) => a > b ? a : b);

    _controller?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        40,
      ),
    );
  }

}
