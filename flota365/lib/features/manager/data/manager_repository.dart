import 'package:dio/dio.dart';
import 'package:flota365/features/driver/data/driver_service.dart';
import 'package:flota365/features/driver/domain/entities/driver_info.dart';
import 'package:flota365/features/manager/data/dto/dashboard_active_vehicle_dto.dart';
import 'package:flota365/features/manager/domain/entities/dashboard_active_vehicle.dart';

import 'manager_service.dart';

// DTOs
import 'dto/vehicle_dto.dart';
import 'dto/assignment_dto.dart';
import 'dto/report_dto.dart';
import 'dto/fleet_dto.dart';
import 'dto/dashboard_stats_dto.dart';

// ENTITIES
import '../domain/entities/vehicle_entity.dart';
import '../domain/entities/assignment_entity.dart';
import '../domain/entities/fleet_entity.dart';
import '../domain/entities/dashboard_stats.dart';
import '../domain/entities/report_entity.dart';

class ManagerRepository {
  final ManagerService service;

  ManagerRepository(this.service);

  // ============================================================
  // VEHICLES
  // ============================================================

  Future<List<VehicleEntity>> getVehicles() async {
    final Response res = await service.getVehicles();
    final List list = res.data;

    return list.map((e) => VehicleDto.fromJson(e).toEntity()).toList();
  }

  Future<VehicleEntity> createVehicle(Map<String, dynamic> data) async {
    final res = await service.createVehicle(data);
    return VehicleDto.fromJson(res.data).toEntity();
  }

  Future<VehicleEntity> updateVehicle(int id, Map<String, dynamic> data) async {
    final res = await service.updateVehicle(id, data);
    return VehicleDto.fromJson(res.data).toEntity();
  }

  Future<void> deleteVehicle(int id) async {
    await service.deleteVehicle(id);
  }

  // ============================================================
  // ASSIGNMENTS (RUTAS)
  // ============================================================

  Future<List<AssignmentEntity>> getAssignments() async {
    final res = await service.getAssignments();
    final List list = res.data;

    return list.map((e) => AssignmentDto.fromJson(e).toEntity()).toList();
  }

  Future<void> createAssignment({
    required int driverId,
    required int vehicleId,
    required String route,
  }) async {
    await service.createAssignment(
      driverId: driverId,
      vehicleId: vehicleId,
      route: route,
    );
  }


  Future<AssignmentEntity> getAssignmentById(int id) async {
    final res = await service.getAssignmentById(id);
    return AssignmentDto.fromJson(res.data).toEntity();
  }

  Future<void> startAssignment(int id) async {
    await service.startAssignment(id);
  }

  Future<void> completeAssignment(int id) async {
    await service.completeAssignment(id);
  }

  // FLEETS


  Future<List<FleetEntity>> getFleets() async {
    final res = await service.getFleets();
    final list = (res.data as List)
        .map((j) => FleetDto.fromJson(j).toEntity())
        .toList();
    return list;
  }

  Future<void> createFleet(FleetEntity f) async {
    final body = {
      "name": f.name,
      "description": f.description,
      "type": f.type,
    };
    await service.createFleet(body);
  }

  Future<void> updateFleet(FleetEntity f) async {
    final body = {
      "name": f.name,
      "description": f.description,
      "type": f.type,
      "isActive": f.isActive,
    };
    await service.updateFleet(f.id, body);
  }

  Future<void> deleteFleet(int id) async {
    await service.deleteFleet(id);
  }

  Future<List<DriverInfo>> getDrivers() async {
  final Response res = await service.getDrivers(); // <-- endpoint Driver
  final List list = res.data as List;

  return list
      .map((e) => DriverInfo.fromJson(Map<String, dynamic>.from(e)))
      .toList();
}

Future<DriverInfo> getDriverInfo(int id) async {
  final res = await service.getDriverById(id);
  return DriverInfo.fromJson(res.data as Map<String, dynamic>);
}


// DASHBOARD

  Future<List<DashboardActiveVehicle>> getActiveVehiclesDashboard() async {
  final res = await service.getActiveVehicles();
  final List list = res.data as List;
  return list
      .map((e) => DashboardActiveVehicleDto.fromJson(e).toEntity())
      .toList();
}

Future<DashboardStats> getDashboardStats() async {
  final res = await service.getDashboardStats();
  return DashboardStatsDto.fromJson(res.data).toEntity();
}

Future<dynamic> getFleetSummary() async {
  // Si quieres tiparlo luego a un FleetSummary entity, perfecto.
  // Por ahora lo devolvemos tal cual para que funcione sin romper nada.
  final res = await service.getFleetSummary();
  return res.data;
}




  /*

  
  
  // ============================================================
  // REPORTS
  // ============================================================

  Future<List<ReportEntity>> getReports() async {
    final res = await service.getReports();
    final List list = res.data;

    return list.map((e) => ReportDto.fromJson(e).toEntity()).toList();
  }

  Future<ReportEntity> createReport(Map<String, dynamic> data) async {
    final res = await service.createReport(data);
    return ReportDto.fromJson(res.data).toEntity();
  }
  */

  // ============================================================
  // MANAGERS
  // ============================================================

  Future<List<dynamic>> getManagers() async {
    final res = await service.getManagers();
    return res.data;
  }

  Future<void> createManager(Map<String, dynamic> data) async {
    await service.createManager(data);
  }
}
