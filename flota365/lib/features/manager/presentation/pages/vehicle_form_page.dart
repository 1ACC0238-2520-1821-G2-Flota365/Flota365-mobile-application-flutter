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
  InputDecoration _inputDeco(String label) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black87),
        hintStyle: const TextStyle(color: Colors.black45),
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
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Editar vehículo' : 'Nuevo vehículo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: isEdit ? _buildEditForm() : _buildCreateForm(),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _submit,
          child: Text(isEdit ? 'Guardar cambios' : 'Crear vehículo'),
        ),
      ),
    );
  }

  Widget _buildCreateForm() {
    return SingleChildScrollView(
      child: Column(
        children: [
          TextFormField(
            controller: _plateCtrl,
            style: _inputTextStyle,
            cursorColor: Colors.black,
            decoration: _inputDeco('Placa'),
            validator: (v) => (v == null || v.isEmpty) ? 'Ingresa la placa' : null,
          ),
          TextFormField(
            controller: _brandCtrl,
            style: _inputTextStyle,
            cursorColor: Colors.black,
            decoration: _inputDeco('Marca'),
            validator: (v) => (v == null || v.isEmpty) ? 'Ingresa la marca' : null,
          ),
          TextFormField(
            controller: _modelCtrl,
            style: _inputTextStyle,
            cursorColor: Colors.black,
            decoration: _inputDeco('Modelo'),
            validator: (v) => (v == null || v.isEmpty) ? 'Ingresa el modelo' : null,
          ),
          TextFormField(
            controller: _yearCtrl,
            style: _inputTextStyle,
            cursorColor: Colors.black,
            decoration: _inputDeco('Año'),
            keyboardType: TextInputType.number,
            validator: (v) => (v == null || int.tryParse(v) == null) ? 'Año inválido' : null,
          ),
          TextFormField(
            controller: _mileageCtrl,
            style: _inputTextStyle,
            cursorColor: Colors.black,
            decoration: _inputDeco('Kilometraje'),
            keyboardType: TextInputType.number,
            validator: (v) => (v == null || int.tryParse(v) == null) ? 'Kilometraje inválido' : null,
          ),
          TextFormField(
            controller: _fleetIdCtrl,
            readOnly: widget.fleetId != null, // 👈 importante
            style: _inputTextStyle,
            cursorColor: Colors.black,
            decoration: _inputDeco('ID de Flota'),
            keyboardType: TextInputType.number,
            validator: (v) {
              if (widget.fleetId != null) return null; // ya viene fijo
              if (v == null || int.tryParse(v) == null) {
                return 'ID de flota inválido';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _fleetNameCtrl,
            readOnly: widget.fleetName != null, // 👈 importante
            style: _inputTextStyle,
            cursorColor: Colors.black,
            decoration: _inputDeco('Nombre de flota'),
            validator: (v) {
              if (widget.fleetName != null) return null; // ya viene fija
              if (v == null || v.isEmpty) {
                return 'Ingresa el nombre de flota';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return SingleChildScrollView(
      child: Column(
        children: [
          TextFormField(
            controller: _editMileageCtrl,
            style: _inputTextStyle,
            cursorColor: Colors.black,
            decoration: _inputDeco('Kilometraje'),
            keyboardType: TextInputType.number,
            validator: (v) =>
                (v == null || int.tryParse(v) == null) ? 'Kilometraje inválido' : null,
          ),
          TextFormField(
            controller: _statusCtrl,
            style: _inputTextStyle,
            cursorColor: Colors.black,
            decoration: _inputDeco('Estado'),
          ),
          TextFormField(
            controller: _driverNameCtrl,
            style: _inputTextStyle,
            cursorColor: Colors.black,
            decoration: _inputDeco('Nombre del conductor'),
          ),
        ],
      ),
    );
  }
}
