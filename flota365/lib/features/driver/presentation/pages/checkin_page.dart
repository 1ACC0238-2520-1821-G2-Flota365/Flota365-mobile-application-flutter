import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/enums/status.dart';
import '../../data/driver_repository.dart';
import '../../data/driver_service.dart';

import '../blocs/checkin/checkin_bloc.dart';
import '../blocs/checkin/checkin_event.dart';
import '../blocs/checkin/checkin_state.dart';

class CheckInPage extends StatelessWidget {
  final int assignmentId;
  const CheckInPage({super.key, required this.assignmentId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CheckInBloc(DriverRepository(DriverService()))
        ..add(CheckInInit(assignmentId as int)),
      child: const _CheckInView(),
    );
  }
}

class _CheckInView extends StatefulWidget {
  const _CheckInView();

  @override
  State<_CheckInView> createState() => _CheckInViewState();
}

class _CheckInViewState extends State<_CheckInView> {
  @override
  void initState() {
    super.initState();
    _loadGPS();
  }

  Future<void> _loadGPS() async {
    final bloc = context.read<CheckInBloc>();

    final perm = await Geolocator.requestPermission();
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) return;

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final gps = "${pos.latitude}, ${pos.longitude}";

    // Enviar ubicación automática al Bloc
    bloc.add(CheckInLocationChanged(gps));
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<CheckInBloc>();

    return Scaffold(
      appBar: AppBar(title: const Text('Check-In')),
      body: BlocConsumer<CheckInBloc, CheckInState>(
        listener: (context, state) {
          if (state.status == Status.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Check-In realizado con éxito')),
            );
            Navigator.pop(context);
          }
          if (state.status == Status.failure && state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!)),
            );
          }
        },
        builder: (context, state) {
          final loading = state.status == Status.loading;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text("Assignment: ${state.assignmentId}"),
              const SizedBox(height: 12),

              TextFormField(
                readOnly: true,
                initialValue: state.time.toString(),
                decoration: const InputDecoration(labelText: 'Hora'),
              ),
              const SizedBox(height: 12),

              TextFormField(
                readOnly: true, // AUTOMÁTICO
                initialValue: state.location,
                decoration: const InputDecoration(labelText: 'Ubicación (GPS)'),
              ),
              const SizedBox(height: 12),

              TextFormField(
                decoration: const InputDecoration(labelText: 'Combustible (%)'),
                keyboardType: TextInputType.number,
                onChanged: (v) => bloc.add(
                  CheckInFuelChanged(double.tryParse(v.trim()) ?? 0),
                ),
              ),
              const SizedBox(height: 12),

              TextFormField(
                decoration: const InputDecoration(labelText: 'Carga (kg)'),
                keyboardType: TextInputType.number,
                onChanged: (v) => bloc.add(
                  CheckInCargoChanged(double.tryParse(v.trim()) ?? 0),
                ),
              ),
              const SizedBox(height: 12),

              const Text("Checklist"),
              CheckboxListTile(
                title: const Text("Luces"),
                value: state.checklist["luces"] ?? false,
                onChanged: (v) =>
                    bloc.add(CheckInChecklistToggled("luces", v ?? false)),
              ),
              CheckboxListTile(
                title: const Text("Frenos"),
                value: state.checklist["frenos"] ?? false,
                onChanged: (v) =>
                    bloc.add(CheckInChecklistToggled("frenos", v ?? false)),
              ),
              CheckboxListTile(
                title: const Text("Neumáticos"),
                value: state.checklist["neumaticos"] ?? false,
                onChanged: (v) =>
                    bloc.add(CheckInChecklistToggled("neumaticos", v ?? false)),
              ),
              CheckboxListTile(
                title: const Text("Otros"),
                value: state.checklist["otros"] ?? false,
                onChanged: (v) =>
                    bloc.add(CheckInChecklistToggled("otros", v ?? false)),
              ),

              const SizedBox(height: 12),

              TextFormField(
                decoration: const InputDecoration(labelText: "Observaciones"),
                maxLines: 3,
                onChanged: (v) => bloc.add(CheckInNotesChanged(v.trim())),
              ),

              const SizedBox(height: 16),

              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: (!state.enabled || loading)
                      ? null
                      : () => bloc.add(CheckInSubmitted()),
                  child: loading
                      ? const CircularProgressIndicator(strokeWidth: 2)
                      : const Text("Confirmar Check-In"),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
