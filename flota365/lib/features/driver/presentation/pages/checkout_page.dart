import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/enums/status.dart';
import '../../data/driver_repository.dart';
import '../../data/driver_service.dart';
import '../blocs/checkout/checkout_bloc.dart';
import '../blocs/checkout/checkout_event.dart';
import '../blocs/checkout/checkout_state.dart';

class CheckOutPage extends StatelessWidget {
  final String assignmentId;
  const CheckOutPage({super.key, required this.assignmentId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CheckOutBloc(DriverRepository(DriverService()))
        ..add(CheckOutInit(assignmentId)),
      child: const _CheckOutView(),
    );
  }
}

class _CheckOutView extends StatelessWidget {
  const _CheckOutView();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<CheckOutBloc>();

    return Scaffold(
      appBar: AppBar(title: const Text('Check-Out')),
      body: BlocConsumer<CheckOutBloc, CheckOutState>(
        listener: (context, state) {
          if (state.status == Status.success) {
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Check-Out realizado')));
            Navigator.pop(context);
          }
          if (state.status == Status.failure && state.error != null) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.error!)));
          }
        },
        builder: (context, state) {
          final loading = state.status == Status.loading;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Assignment: ${state.assignmentId}'),
              const SizedBox(height: 12),

              TextFormField(
                readOnly: true,
                initialValue: state.time.toLocal().toString().substring(0, 19),
                decoration: const InputDecoration(labelText: 'Hora fin'),
              ),
              const SizedBox(height: 12),

              TextFormField(
                decoration: const InputDecoration(labelText: 'Ubicación (GPS)'),
                onChanged: (v) => bloc.add(CheckOutLocationChanged(v)),
              ),
              const SizedBox(height: 12),

              TextFormField(
                decoration: const InputDecoration(labelText: 'Combustible final (%)'),
                keyboardType: TextInputType.number,
                onChanged: (v) => bloc.add(CheckOutFuelChanged(double.tryParse(v) ?? 0)),
              ),
              const SizedBox(height: 12),

              const Text('Incidencias'),
              CheckboxListTile(
                title: const Text('Golpes'),
                value: state.issues['golpes'] ?? false,
                onChanged: (v) => bloc.add(CheckOutIssuesToggled('golpes', v ?? false)),
              ),
              CheckboxListTile(
                title: const Text('Fugas'),
                value: state.issues['fugas'] ?? false,
                onChanged: (v) => bloc.add(CheckOutIssuesToggled('fugas', v ?? false)),
              ),
              CheckboxListTile(
                title: const Text('Ruidos'),
                value: state.issues['ruidos'] ?? false,
                onChanged: (v) => bloc.add(CheckOutIssuesToggled('ruidos', v ?? false)),
              ),
              CheckboxListTile(
                title: const Text('Otros'),
                value: state.issues['otros'] ?? false,
                onChanged: (v) => bloc.add(CheckOutIssuesToggled('otros', v ?? false)),
              ),
              const SizedBox(height: 12),

              TextFormField(
                decoration: const InputDecoration(labelText: 'Observaciones'),
                maxLines: 3,
                onChanged: (v) => bloc.add(CheckOutNotesChanged(v)),
              ),
              const SizedBox(height: 16),

              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: (!state.enabled || loading)
                      ? null
                      : () => bloc.add(CheckOutSubmitted()),
                  child: loading
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Confirmar Check-Out'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
