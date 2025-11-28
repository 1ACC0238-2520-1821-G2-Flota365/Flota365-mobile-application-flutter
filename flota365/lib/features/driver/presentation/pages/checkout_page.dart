import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/enums/status.dart';
import '../../data/driver_repository.dart';
import '../../data/driver_service.dart';

import '../blocs/checkout/checkout_bloc.dart';
import '../blocs/checkout/checkout_event.dart';
import '../blocs/checkout/checkout_state.dart';

class CheckOutPage extends StatelessWidget {
  final int assignmentId;
  const CheckOutPage({super.key, required this.assignmentId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CheckOutBloc(DriverRepository(DriverService()))
        ..add(CheckOutInit(assignmentId as int)),
      child: const _CheckOutView(),
    );
  }
}

class _CheckOutView extends StatefulWidget {
  const _CheckOutView();

  @override
  State<_CheckOutView> createState() => _CheckOutViewState();
}

class _CheckOutViewState extends State<_CheckOutView> {
  @override
  void initState() {
    super.initState();
    _loadGPS();
  }

  Future<void> _loadGPS() async {
    final bloc = context.read<CheckOutBloc>();

    final perm = await Geolocator.requestPermission();
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) return;

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final gps = "${pos.latitude}, ${pos.longitude}";

    // AUTOMÁTICO
    bloc.add(CheckOutLocationChanged(gps));
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<CheckOutBloc>();

    return Scaffold(
      appBar: AppBar(title: const Text('Check-Out')),
      body: BlocConsumer<CheckOutBloc, CheckOutState>(
        listener: (context, state) {
          if (state.status == Status.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Check-Out realizado con éxito')),
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
                decoration: const InputDecoration(labelText: "Hora fin"),
              ),
              const SizedBox(height: 12),

              TextFormField(
                readOnly: true, // AUTOMÁTICO
                initialValue: state.location,
                decoration: const InputDecoration(labelText: "Ubicación (GPS)"),
              ),
              const SizedBox(height: 12),

              TextFormField(
                decoration: const InputDecoration(
                    labelText: "Combustible final (%)"),
                keyboardType: TextInputType.number,
                onChanged: (v) => bloc.add(
                  CheckOutFuelChanged(double.tryParse(v.trim()) ?? 0),
                ),
              ),
              const SizedBox(height: 12),

              const Text("Incidencias"),
              CheckboxListTile(
                title: const Text("Golpes"),
                value: state.issues["golpes"] ?? false,
                onChanged: (v) =>
                    bloc.add(CheckOutIssuesToggled("golpes", v ?? false)),
              ),
              CheckboxListTile(
                title: const Text("Fugas"),
                value: state.issues["fugas"] ?? false,
                onChanged: (v) =>
                    bloc.add(CheckOutIssuesToggled("fugas", v ?? false)),
              ),
              CheckboxListTile(
                title: const Text("Ruidos"),
                value: state.issues["ruidos"] ?? false,
                onChanged: (v) =>
                    bloc.add(CheckOutIssuesToggled("ruidos", v ?? false)),
              ),
              CheckboxListTile(
                title: const Text("Otros"),
                value: state.issues["otros"] ?? false,
                onChanged: (v) =>
                    bloc.add(CheckOutIssuesToggled("otros", v ?? false)),
              ),
              const SizedBox(height: 12),

              TextFormField(
                maxLines: 3,
                decoration:
                    const InputDecoration(labelText: "Observaciones"),
                onChanged: (v) => bloc.add(CheckOutNotesChanged(v.trim())),
              ),

              const SizedBox(height: 16),

              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: (!state.enabled || loading)
                      ? null
                      : () => bloc.add(CheckOutSubmitted()),
                  child: loading
                      ? const CircularProgressIndicator(strokeWidth: 2)
                      : const Text("Confirmar Check-Out"),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
