import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/vehicles/vehicles_bloc.dart';
import '../blocs/vehicles/vehicles_event.dart';
import '../../domain/entities/vehicle_entity.dart';

class VehicleFormPage extends StatefulWidget {
  final VehicleEntity? vehicle;
  final int? fleetId;
  final String? fleetName;

  const VehicleFormPage({
    super.key,
    this.vehicle,
    this.fleetId,
    this.fleetName,
  });

  @override
  State<VehicleFormPage> createState() => _VehicleFormPageState();
}

class _VehicleFormPageState extends State<VehicleFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _plateCtrl = TextEditingController();
  final _brandCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _mileageCtrl = TextEditingController();
  final _fleetIdCtrl = TextEditingController();
  final _fleetNameCtrl = TextEditingController();

  // Para edición (mileage, status, driverName)
  final _editMileageCtrl = TextEditingController();
  final _statusCtrl = TextEditingController();
  final _driverNameCtrl = TextEditingController();

  bool get isEdit => widget.vehicle != null;

  // ✅ SOLO UI: asegura texto negro al escribir
  TextStyle get _inputTextStyle => const TextStyle(color: Colors.black);

  InputDecoration _inputDeco(
    String label, {
    String? helper,
    IconData? icon,
  }) =>
      InputDecoration(
        labelText: label,
        helperText: helper,
        prefixIcon: icon != null ? Icon(icon) : null,
        labelStyle: const TextStyle(color: Colors.black87),
        hintStyle: const TextStyle(color: Colors.black45),
        filled: true,
        fillColor: Colors.black.withOpacity(.03),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.black.withOpacity(.10)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.black.withOpacity(.10)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.black.withOpacity(.35), width: 1.2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      );

  @override
  void initState() {
    super.initState();

    if (isEdit) {
      final v = widget.vehicle!;
      _editMileageCtrl.text = v.mileage.toString();
      _statusCtrl.text = v.status;
      _driverNameCtrl.text = v.driverName;
    } else {
      _yearCtrl.text = DateTime.now().year.toString();
      _mileageCtrl.text = '0';

      // 👇 Si viene desde una flota, autocompletamos:
      if (widget.fleetId != null) {
        _fleetIdCtrl.text = widget.fleetId.toString();
        _fleetNameCtrl.text = widget.fleetName ?? '';
      } else {
        _fleetIdCtrl.text = '0';
      }
    }
  }

  @override
  void dispose() {
    _plateCtrl.dispose();
    _brandCtrl.dispose();
    _modelCtrl.dispose();
    _yearCtrl.dispose();
    _mileageCtrl.dispose();
    _fleetIdCtrl.dispose();
    _fleetNameCtrl.dispose();

    _editMileageCtrl.dispose();
    _statusCtrl.dispose();
    _driverNameCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final bloc = context.read<VehiclesBloc>();

    if (isEdit) {
      final v = widget.vehicle!;
      final mileage = int.tryParse(_editMileageCtrl.text);

      bloc.add(
        UpdateVehicleRequested(
          id: v.id,
          mileage: mileage,
          status: _statusCtrl.text.isNotEmpty ? _statusCtrl.text : null,
          driverName: _driverNameCtrl.text.isNotEmpty ? _driverNameCtrl.text : null,
        ),
      );

      Navigator.pop(context, true);
    } else {
      final fleetId = widget.fleetId ?? int.parse(_fleetIdCtrl.text);
      final fleetName = widget.fleetName ?? _fleetNameCtrl.text.trim();

      bloc.add(
        CreateVehicleRequested(
          licensePlate: _plateCtrl.text.trim(),
          brand: _brandCtrl.text.trim(),
          model: _modelCtrl.text.trim(),
          year: int.parse(_yearCtrl.text),
          mileage: int.parse(_mileageCtrl.text),
          fleetId: fleetId,
          fleetName: fleetName,
        ),
      );

      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = isEdit ? 'Editar vehículo' : 'Nuevo vehículo';
    final cta = isEdit ? 'Guardar cambios' : 'Crear vehículo';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _HeaderCard(
                          title: title,
                          subtitle: isEdit
                              ? "Actualiza información del vehículo."
                              : "Registra un nuevo vehículo en tu flota.",
                          icon: isEdit ? Icons.edit_rounded : Icons.directions_car_rounded,
                        ),
                        const SizedBox(height: 14),

                        Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(color: Colors.black.withOpacity(.06)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: isEdit ? _buildEditForm() : _buildCreateForm(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: SizedBox(
            height: 52,
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _submit,
              icon: Icon(isEdit ? Icons.save_rounded : Icons.add_rounded),
              label: Text(cta),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------- CREATE ----------
  Widget _buildCreateForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(
          title: "Datos del vehículo",
          subtitle: "Completa placa, marca, modelo y métricas.",
        ),
        const SizedBox(height: 12),

        _Field(
          child: TextFormField(
            controller: _plateCtrl,
            style: _inputTextStyle,
            cursorColor: Colors.black,
            textInputAction: TextInputAction.next,
            decoration: _inputDeco('Placa', icon: Icons.confirmation_number_rounded),
            validator: (v) => (v == null || v.isEmpty) ? 'Ingresa la placa' : null,
          ),
        ),
        _Field(
          child: TextFormField(
            controller: _brandCtrl,
            style: _inputTextStyle,
            cursorColor: Colors.black,
            textInputAction: TextInputAction.next,
            decoration: _inputDeco('Marca', icon: Icons.branding_watermark_rounded),
            validator: (v) => (v == null || v.isEmpty) ? 'Ingresa la marca' : null,
          ),
        ),
        _Field(
          child: TextFormField(
            controller: _modelCtrl,
            style: _inputTextStyle,
            cursorColor: Colors.black,
            textInputAction: TextInputAction.next,
            decoration: _inputDeco('Modelo', icon: Icons.directions_car_filled_rounded),
            validator: (v) => (v == null || v.isEmpty) ? 'Ingresa el modelo' : null,
          ),
        ),

        Row(
          children: [
            Expanded(
              child: _Field(
                child: TextFormField(
                  controller: _yearCtrl,
                  style: _inputTextStyle,
                  cursorColor: Colors.black,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  decoration: _inputDeco('Año', icon: Icons.calendar_month_rounded),
                  validator: (v) =>
                      (v == null || int.tryParse(v) == null) ? 'Año inválido' : null,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _Field(
                child: TextFormField(
                  controller: _mileageCtrl,
                  style: _inputTextStyle,
                  cursorColor: Colors.black,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  decoration: _inputDeco('Kilometraje', icon: Icons.speed_rounded),
                  validator: (v) => (v == null || int.tryParse(v) == null)
                      ? 'Kilometraje inválido'
                      : null,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),
        const Divider(height: 26),

        const _SectionTitle(
          title: "Flota",
          subtitle: "Asocia el vehículo a una flota.",
        ),
        const SizedBox(height: 12),

        _Field(
          child: TextFormField(
            controller: _fleetIdCtrl,
            readOnly: widget.fleetId != null, // 👈 importante
            style: _inputTextStyle,
            cursorColor: Colors.black,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            decoration: _inputDeco(
              'ID de Flota',
              icon: Icons.groups_rounded,
              helper: widget.fleetId != null ? "Asignado automáticamente" : null,
            ),
            validator: (v) {
              if (widget.fleetId != null) return null; // ya viene fijo
              if (v == null || int.tryParse(v) == null) {
                return 'ID de flota inválido';
              }
              return null;
            },
          ),
        ),
        _Field(
          child: TextFormField(
            controller: _fleetNameCtrl,
            readOnly: widget.fleetName != null, // 👈 importante
            style: _inputTextStyle,
            cursorColor: Colors.black,
            textInputAction: TextInputAction.done,
            decoration: _inputDeco(
              'Nombre de flota',
              icon: Icons.badge_rounded,
              helper: widget.fleetName != null ? "Asignado automáticamente" : null,
            ),
            validator: (v) {
              if (widget.fleetName != null) return null; // ya viene fija
              if (v == null || v.isEmpty) {
                return 'Ingresa el nombre de flota';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  // ---------- EDIT ----------
  Widget _buildEditForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(
          title: "Actualizar vehículo",
          subtitle: "Edita kilometraje, estado y conductor.",
        ),
        const SizedBox(height: 12),

        _Field(
          child: TextFormField(
            controller: _editMileageCtrl,
            style: _inputTextStyle,
            cursorColor: Colors.black,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            decoration: _inputDeco('Kilometraje', icon: Icons.speed_rounded),
            validator: (v) =>
                (v == null || int.tryParse(v) == null) ? 'Kilometraje inválido' : null,
          ),
        ),
        _Field(
          child: TextFormField(
            controller: _statusCtrl,
            style: _inputTextStyle,
            cursorColor: Colors.black,
            textInputAction: TextInputAction.next,
            decoration: _inputDeco('Estado', icon: Icons.tune_rounded),
          ),
        ),
        _Field(
          child: TextFormField(
            controller: _driverNameCtrl,
            style: _inputTextStyle,
            cursorColor: Colors.black,
            textInputAction: TextInputAction.done,
            decoration: _inputDeco('Nombre del conductor', icon: Icons.person_rounded),
          ),
        ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  final Widget child;
  const _Field({required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  const _SectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(color: Colors.black.withOpacity(.65), height: 1.2),
        ),
      ],
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _HeaderCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        border: Border.all(color: Colors.black.withOpacity(.06)),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 10),
            color: Colors.black.withOpacity(.06),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue.withOpacity(.12),
            ),
            child: Icon(icon, color: Colors.blue.shade700),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.black.withOpacity(.65)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
