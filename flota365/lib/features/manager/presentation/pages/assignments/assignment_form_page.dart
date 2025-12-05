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

  // ==========================
  // ✅ DECORACIÓN "WHITE TEXT"
  // ==========================
  InputDecoration _whiteInput(String label) {
    const borderColor = Colors.black54;

    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black54),
      hintStyle: const TextStyle(color: Colors.black45),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: borderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.black54, width: 1.6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const blackStyle = TextStyle(color: Colors.black);

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
                    Theme(
                      // esto asegura que el overlay del dropdown herede buen color
                      data: Theme.of(context).copyWith(
                        canvasColor: const Color(0xFF1F2937), // fondo del menú
                      ),
                      child: DropdownButtonFormField<int>(
                        decoration: _whiteInput("Vehículo"),
                        value: selectedVehicle,
                        dropdownColor: const Color.fromARGB(255, 105, 131, 167), // menú oscuro
                        iconEnabledColor: Colors.black,
                        style: blackStyle, // texto seleccionado (blanco)
                        items: vehicles
                            .map(
                              (v) => DropdownMenuItem<int>(
                                value: v.id,
                                child: Text(
                                  v.licensePlate,
                                  style: blackStyle, // texto del item (blanco)
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => selectedVehicle = v),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ==========================
                    // CONDUCTOR
                    // ==========================
                    Theme(
                      data: Theme.of(context).copyWith(
                        canvasColor: const Color(0xFF1F2937),
                      ),
                      child: DropdownButtonFormField<int>(
                        decoration: _whiteInput("Conductor"),
                        value: selectedDriver,
                        dropdownColor: const Color.fromARGB(255, 105, 131, 167),
                        iconEnabledColor: Colors.black,
                        style: blackStyle,
                        items: drivers
                            .map(
                              (d) => DropdownMenuItem<int>(
                                value: d.id,
                                child: Text(
                                  d.fullName,
                                  style: blackStyle,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => selectedDriver = v),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ==========================
                    // RUTA
                    // ==========================
                    TextFormField(
                      controller: routeCtrl,
                      style: blackStyle,       // ✅ texto escrito blanco
                      cursorColor: Colors.black, // ✅ cursor blanco
                      decoration: _whiteInput("Ruta (Ej: Lima → Callao)"),
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
                                content: Text("Completa todos los campos requeridos"),
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
