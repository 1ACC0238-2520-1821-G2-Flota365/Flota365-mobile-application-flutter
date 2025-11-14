import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/route_detail/route_detail_bloc.dart';
import '../blocs/route_detail/route_detail_event.dart';
import '../blocs/route_detail/route_detail_state.dart';

class RouteDetailPage extends StatelessWidget {
  final String routeId;

  const RouteDetailPage({super.key, required this.routeId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RouteDetailBloc()..add(RouteDetailRequested(routeId)),
      child: Scaffold(
        appBar: AppBar(title: const Text("Ruta en detalle")),
        body: BlocBuilder<RouteDetailBloc, RouteDetailState>(
          builder: (context, state) {
            if (state.loading || state.route == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final r = state.route!;

            return Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r["title"],
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  // PROGRESO
                  Text("Progreso: ${r["progress"]}%"),
                  Slider(
                    value: r["progress"].toDouble(),
                    min: 0,
                    max: 100,
                    onChanged: (v) {
                      context.read<RouteDetailBloc>().add(
                            RouteProgressUpdated(v.toInt()),
                          );
                    },
                  ),

                  const SizedBox(height: 20),
                  const Text("Paradas:", style: TextStyle(fontSize: 18)),

                  Expanded(
                    child: ListView.builder(
                      itemCount: r["stops"].length,
                      itemBuilder: (context, index) {
                        final stop = r["stops"][index];

                        return CheckboxListTile(
                          title: Text(stop["name"]),
                          value: stop["done"],
                          onChanged: (v) {
                            context
                                .read<RouteDetailBloc>()
                                .add(RouteStopToggled(index));
                          },
                        );
                      },
                    ),
                  ),

                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Ruta completada (simulada)"),
                        ),
                      );
                    },
                    child: const Text("Finalizar Ruta"),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
