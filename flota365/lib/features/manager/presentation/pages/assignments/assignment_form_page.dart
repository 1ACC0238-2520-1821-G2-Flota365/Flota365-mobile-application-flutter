import 'package:flota365/features/manager/presentation/blocs/assigment/assignment_bloc.dart';
import 'package:flota365/features/manager/presentation/blocs/assigment/assignment_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/manager_repository.dart';
import '../../../data/manager_service.dart';
import '../../../domain/entities/vehicle_entity.dart';

// ✅ usa tu entidad ya existente
import 'package:flota365/features/driver/domain/entities/driver_info.dart';

class AssignmentFormPage extends StatefulWidget {
  const AssignmentFormPage({super.key});

  @override
  State<AssignmentFormPage> createState() => _AssignmentFormPageState();
}

class _AssignmentFormPageState extends State<AssignmentFormPage> {
  int? selectedVehicle;
  int? selectedDriver;
  final routeCtrl = TextEditingController();

  List<VehicleEntity> vehicles = [];

  // ✅ antes: List<Map<String, dynamic>> drivers = [];
  List<DriverInfo> drivers = [];

  bool loadingData = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void dispose() {
    routeCtrl.dispose();
    super.dispose();
  }

  /// ==============================
  ///  CARGAR VEHÍCULOS Y CONDUCTORES
  /// ==============================
  Future<void> loadData() async {
    final repo = ManagerRepository(ManagerService());

    try {
      final v = await repo.getVehicles();
      final d = await repo.getDrivers(); // ✅ conductores reales

      if (!mounted) return;
      setState(() {
        vehicles = v;
        drivers = d;
        loadingData = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loadingData = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error cargando datos: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Crear Ruta")),
      body: loadingData
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // ==========================
                    // VEHÍCULO
                    // ==========================
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(labelText: "Vehículo"),
                      value: selectedVehicle,
                      items: vehicles
                          .map((v) => DropdownMenuItem<int>(
                                value: v.id,
                                child: Text(v.licensePlate),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => selectedVehicle = v),
                    ),

                    const SizedBox(height: 20),

                    // ==========================
                    // CONDUCTOR
                    // ==========================
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(labelText: "Conductor"),
                      value: selectedDriver,
                      items: drivers
                          .map((d) => DropdownMenuItem<int>(
                                value: d.id,
                                child: Text(d.fullName),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => selectedDriver = v),
                    ),

                    const SizedBox(height: 20),

                    // ==========================
                    // RUTA
                    // ==========================
                    TextFormField(
                      controller: routeCtrl,
                      decoration: const InputDecoration(
                        labelText: "Ruta (Ej: Lima → Callao)",
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ==========================
                    // BOTÓN
                    // ==========================
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (selectedVehicle == null ||
                              selectedDriver == null ||
                              routeCtrl.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text("Completa todos los campos requeridos"),
                              ),
                            );
                            return;
                          }

                          context.read<AssignmentBloc>().add(
                                CreateAssignmentRequested(
                                  vehicleId: selectedVehicle!,
                                  driverId: selectedDriver!,
                                  route: routeCtrl.text.trim(),
                                ),
                              );

                          Navigator.pop(context, true);
                        },
                        child: const Text("Crear Ruta"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
