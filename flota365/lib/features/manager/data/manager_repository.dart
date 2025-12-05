import 'package:dio/dio.dart';
import 'package:flota365/features/driver/data/driver_service.dart';
import 'package:flota365/features/driver/domain/entities/driver_info.dart';
import 'package:flota365/features/manager/data/dto/dashboard_active_vehicle_dto.dart';
import 'package:flota365/features/manager/data/dto/maintenance_record_dto.dart';
import 'package:flota365/features/manager/data/dto/maintenance_service_dto.dart';
import 'package:flota365/features/manager/data/dto/manager_profile_dto.dart';
import 'package:flota365/features/manager/domain/entities/dashboard_active_vehicle.dart';
import 'package:flota365/features/manager/domain/entities/maintenance_record_entity.dart';
import 'package:flota365/features/manager/domain/entities/maintenance_service_entity.dart';
import 'package:flota365/features/manager/domain/entities/manager_profile_entity.dart';

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



// ============================================================
// MAINTENANCE
// ============================================================
Future<List<MaintenanceRecordEntity>> getMaintenanceRecords() async {
  final res = await service.getMaintenanceRecords();
  final List list = res.data as List;
  return list.map((e) => MaintenanceRecordDto.fromJson(e).toEntity()).toList();
}

Future<List<MaintenanceRecordEntity>> getMaintenanceOverdue() async {
  final res = await service.getMaintenanceOverdue();
  final List list = res.data as List;
  return list.map((e) => MaintenanceRecordDto.fromJson(e).toEntity()).toList();
}

Future<MaintenanceRecordEntity> createMaintenanceRecord(Map<String, dynamic> body) async {
  final res = await service.createMaintenanceRecord(body);
  return MaintenanceRecordDto.fromJson(res.data).toEntity();
}

Future<MaintenanceRecordEntity> updateMaintenanceRecord(int id, Map<String, dynamic> body) async {
  final res = await service.updateMaintenanceRecord(id, body);
  return MaintenanceRecordDto.fromJson(res.data).toEntity();
}

Future<void> deleteMaintenanceRecord(int id) async {
  await service.deleteMaintenanceRecord(id);
}

// ---- Services ----
Future<List<MaintenanceServiceEntity>> getMaintenanceServices() async {
  final res = await service.getMaintenanceServices();
  final List list = res.data as List;
  return list.map((e) => MaintenanceServiceDto.fromJson(e).toEntity()).toList();
}

Future<MaintenanceServiceEntity> createMaintenanceService(Map<String, dynamic> body) async {
  final res = await service.createMaintenanceService(body);
  return MaintenanceServiceDto.fromJson(res.data).toEntity();
}

Future<void> deleteMaintenanceService(int id) async {
  await service.deleteMaintenanceService(id);
}

// ============================================================
// REPORTS
// ============================================================
Future<List<ReportEntity>> getReports() async {
  final res = await service.getReports();
  final List list = res.data as List;
  return list.map((e) => ReportDto.fromJson(e).toEntity()).toList();
}

Future<ReportEntity> createReport(Map<String, dynamic> body) async {
  final res = await service.createReport(body);
  return ReportDto.fromJson(res.data).toEntity();
}


  Future<List<dynamic>> getManagers() async {
    final res = await service.getManagers();
    return res.data;
  }

  Future<void> createManager(Map<String, dynamic> data) async {
    await service.createManager(data);
  }

  // ============================================================
// PROFILE (en Manager, usando Manager para obtener el id)
// ============================================================

Future<int> _resolveManagerId() async {
  final res = await service.getManagers();
  final list = res.data as List;

  if (list.isEmpty) {
    throw Exception("No hay managers en /api/Manager");
  }

  // ✅ Ajusta este parse si tu manager viene con otro nombre de campo
  final first = Map<String, dynamic>.from(list.first);
  final id = (first['id'] as num?)?.toInt();

  if (id == null) {
    throw Exception("No se encontró 'id' en el manager. Revisa /api/Manager response.");
  }
  return id;
}

Future<ManagerProfileEntity> getMyProfile() async {
  final managerId = await _resolveManagerId();
  final res = await service.getAuthProfileById(managerId);
  return ManagerProfileDto.fromJson(res.data).toEntity();
}

Future<ManagerProfileEntity> updateMyProfile({
  required int id, // Ahora pasamos el id también
  required String firstName,
  required String lastName,
}) async {
  final body = {
    "firstName": firstName,
    "lastName": lastName,
  };

  final res = await service.updateAuthProfileById(id, body);

  // Mismo fallback si la respuesta es texto plano
  if (res.data is Map<String, dynamic>) {
    return ManagerProfileDto.fromJson(res.data).toEntity();
  }
  return getUserProfile(id); // Vuelve a leer el perfil completo
}


Future<void> changeMyPassword({
  required String currentPassword,
  required String newPassword, required int id,
}) async {
  final managerId = await _resolveManagerId();
  final body = {
    "currentPassword": currentPassword,
    "newPassword": newPassword,
  };
  await service.changeAuthPasswordById(managerId, body);
}

Future<ManagerProfileEntity> getUserProfile(int userId) async {
  final response = await service.getAuthProfileById(userId);
 final dto = ManagerProfileDto.fromJson(response.data);
  return dto.toEntity();
}



  
}
