import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/fleet_entity.dart';
import '../../blocs/fleet/fleet_bloc.dart';
import '../../blocs/fleet/fleet_event.dart';
import '../../blocs/fleet/fleet_state.dart';

class FleetFormPage extends StatefulWidget {
  final FleetEntity? fleet;
  const FleetFormPage({super.key, this.fleet});

  @override
  State<FleetFormPage> createState() => _FleetFormPageState();
}

class _FleetFormPageState extends State<FleetFormPage> {
  final _formKey = GlobalKey<FormState>();

  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final typeCtrl = TextEditingController();
  bool isActive = true;

  @override
  void initState() {
    super.initState();

    if (widget.fleet != null) {
      final f = widget.fleet!;
      nameCtrl.text = f.name;
      descCtrl.text = f.description;
      typeCtrl.text = f.type.toString();
      isActive = f.isActive;
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    descCtrl.dispose();
    typeCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final bloc = context.read<FleetBloc>();

    final entity = FleetEntity(
      id: widget.fleet?.id ?? 0,
      name: nameCtrl.text.trim(),
      description: descCtrl.text.trim(),
      type: int.tryParse(typeCtrl.text) ?? 0,
      isActive: isActive,
      vehicleCount: widget.fleet?.vehicleCount ?? 0,
      createdAt: widget.fleet?.createdAt,
      updatedAt: widget.fleet?.updatedAt,
    );

    if (widget.fleet == null) {
      bloc.add(CreateFleetRequested(entity));
    } else {
      bloc.add(UpdateFleetRequested(entity));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.fleet != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Editar Flota" : "Nueva Flota"),
      ),
      body: BlocListener<FleetBloc, FleetState>(
        listener: (context, state) {
          if (state.actionSuccess) {
            Navigator.pop(context, true);
          }
          if (state.error != null) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.error!)));
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Campo obligatorio' : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: descCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Descripción'),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: typeCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Tipo (número)'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),

                SwitchListTile(
                  title: const Text("Activo"),
                  value: isActive,
                  onChanged: (v) => setState(() => isActive = v),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: Text(isEditing ? "Guardar cambios" : "Crear flota"),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
