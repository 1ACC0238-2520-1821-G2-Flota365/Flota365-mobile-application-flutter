import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/routes/routes_bloc.dart';
import '../blocs/routes/routes_event.dart';
import '../blocs/routes/routes_state.dart';
import 'route_detail_page.dart';

class RoutesPage extends StatelessWidget {
  final String driverId;

  const RoutesPage({super.key, required this.driverId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RoutesBloc()..add(const RoutesLoadRequested()),
      child: Scaffold(
        appBar: AppBar(title: const Text("Mis Rutas")),
        body: BlocBuilder<RoutesBloc, RoutesState>(
          builder: (context, state) {
            if (state.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.routes.isEmpty) {
              return const Center(child: Text("No tienes rutas asignadas."));
            }

            return ListView.builder(
              itemCount: state.routes.length,
              itemBuilder: (context, index) {
                final r = state.routes[index];

                return Card(
                  child: ListTile(
                    title: Text(r["title"]),
                    subtitle: Text("Estado: ${r["status"]}"),
                    trailing: Text("${r["distance"]} • ${r["time"]}"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RouteDetailPage(routeId: r["id"]),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
