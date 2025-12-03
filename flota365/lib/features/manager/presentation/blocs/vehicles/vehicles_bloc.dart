import 'package:flutter_bloc/flutter_bloc.dart';

import 'vehicles_event.dart';
import 'vehicles_state.dart';
import '../../../data/manager_repository.dart';

class VehiclesBloc extends Bloc<VehiclesEvent, VehiclesState> {
  final ManagerRepository repository;

  VehiclesBloc(this.repository) : super(const VehiclesState()) {
    on<LoadVehicles>(_onLoadVehicles);
    on<LoadVehiclesForFleet>(_onLoadVehiclesForFleet);
    on<CreateVehicleRequested>(_onCreateVehicle);
    on<UpdateVehicleRequested>(_onUpdateVehicle);
    on<DeleteVehicleRequested>(_onDeleteVehicle);
  }

  Future<void> _onLoadVehicles(
      LoadVehicles event, Emitter<VehiclesState> emit) async {
    emit(state.copyWith(loading: true, error: null, actionSuccess: false));

    try {
      final list = await repository.getVehicles();
      emit(state.copyWith(loading: false, vehicles: list));
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onLoadVehiclesForFleet(
    LoadVehiclesForFleet event,
    Emitter<VehiclesState> emit,
  ) async {
    emit(state.copyWith(loading: true, error: null, actionSuccess: false));

    try {
      final allVehicles = await repository.getVehicles();

      // Filtrar SOLO vehículos de esta flota
      final filtered = allVehicles.where((v) => v.fleetId == event.fleetId).toList();

      emit(state.copyWith(
        loading: false,
        vehicles: filtered,
      ));
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        error: e.toString(),
      ));
    }
  }


  Future<void> _onCreateVehicle(
      CreateVehicleRequested event, Emitter<VehiclesState> emit) async {
    emit(state.copyWith(loading: true, error: null, actionSuccess: false));

    try {
      final body = {
        "licensePlate": event.licensePlate,
        "brand": event.brand,
        "model": event.model,
        "year": event.year,
        "mileage": event.mileage,
        "fleetId": event.fleetId,
        "fleetName": event.fleetName,
      };

      await repository.createVehicle(body);
      // Recargar lista
      final list = await repository.getVehicles();

      emit(state.copyWith(
        loading: false,
        vehicles: list,
        actionSuccess: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateVehicle(
      UpdateVehicleRequested event, Emitter<VehiclesState> emit) async {
    emit(state.copyWith(loading: true, error: null, actionSuccess: false));

    try {
      final Map<String, dynamic> body = {};
      if (event.mileage != null) body['mileage'] = event.mileage;
      if (event.status != null) body['status'] = event.status;
      if (event.driverName != null) body['driverName'] = event.driverName;

      await repository.updateVehicle(event.id, body);
      final list = await repository.getVehicles();

      emit(state.copyWith(
        loading: false,
        vehicles: list,
        actionSuccess: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onDeleteVehicle(
      DeleteVehicleRequested event, Emitter<VehiclesState> emit) async {
    emit(state.copyWith(loading: true, error: null, actionSuccess: false));

    try {
      await repository.deleteVehicle(event.id);
      final list = await repository.getVehicles();

      emit(state.copyWith(
        loading: false,
        vehicles: list,
        actionSuccess: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        error: e.toString(),
      ));
    }
  }
}

