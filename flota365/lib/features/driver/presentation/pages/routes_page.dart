// Archivo: lib/features/driver/presentation/pages/routes_page.dart

import 'package:flutter/material.dart';
import '../../domain/entities/route.dart';
import '../widgets/route_list_item.dart';

class RoutesPage extends StatelessWidget {
  const RoutesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Datos de ejemplo
    final List<RouteEntity> mockRoutes = [
      RouteEntity.example(),
      const RouteEntity(
        id: 'RT-046', 
        name: 'Ruta Este 046', 
        status: 'Pendiente', 
        weight: 15.0, 
        height: 4.1, 
        restrictedRoads: 0
      ),
      // Añadir más rutas de ejemplo si es necesario
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Rutas', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF00BCD4),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: <Widget>[
          // Placeholder del Mapa (Expandido para simular el área superior)
          Expanded(
            flex: 1, 
            child: Container(
              color: Colors.grey[300],
              child: const Center(
                child: Text('[Mapa de Rutas aquí]', style: TextStyle(fontSize: 18, color: Colors.black54)),
              ),
            ),
          ),

          // Lista de Rutas
          Expanded(
            flex: 2, 
            child: ListView.builder(
              padding: const EdgeInsets.all(12.0),
              itemCount: mockRoutes.length,
              itemBuilder: (context, index) {
                return RouteListItem(route: mockRoutes[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}