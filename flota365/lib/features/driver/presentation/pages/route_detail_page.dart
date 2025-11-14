// Archivo: lib/features/driver/presentation/pages/route_detail_page.dart

import 'package:flutter/material.dart';
import '../../domain/entities/route.dart';
import '../widgets/route_progress.dart';

class RouteDetailPage extends StatelessWidget {
  const RouteDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Datos de detalle de ejemplo
    final routeDetail = RouteDetailEntity.example();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ruta a detalle', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF00BCD4),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: <Widget>[
          // 1. Placeholder del Mapa de Detalle (cubre toda la pantalla)
          Container(
            color: Colors.grey[400],
            child: const Center(
              child: Text(
                '[Mapa de Ruta Detallada aquí]',
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            ),
          ),
          
          // 2. Tarjeta de progreso (superpuesta en el centro)
          Align(
            alignment: Alignment.center,
            child: SingleChildScrollView( // Para asegurar que no haya overflow
              child: RouteProgressCard(routeDetail: routeDetail),
            ),
          ),
        ],
      ),
    );
  }
}