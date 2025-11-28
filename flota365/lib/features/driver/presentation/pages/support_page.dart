import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../blocs/support/support_bloc.dart';
import '../blocs/support/support_event.dart';
import '../blocs/support/support_state.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SupportBloc(),
      child: const _SupportView(),
    );
  }
}

class _SupportView extends StatelessWidget {
  const _SupportView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SupportBloc, SupportState>(
      listener: (context, state) async {
        if (state.status == SupportStatus.success) {
          final url = Uri.parse(state.whatsappUrl!);

          try {
            await launchUrl(
              url,
              mode: LaunchMode.externalApplication,
            );
          } catch (e) {
            print("ERROR al abrir WhatsApp: $e");
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("WhatsApp no está instalado en este dispositivo"),
              ),
            );
          }
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text("Servicio al Cliente")),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: "Asunto",
                  ),
                  onChanged: (v) =>
                      context.read<SupportBloc>().add(SupportSubjectChanged(v)),
                ),
                const SizedBox(height: 12),
                TextField(
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: "Mensaje",
                  ),
                  onChanged: (v) =>
                      context.read<SupportBloc>().add(SupportMessageChanged(v)),
                ),
                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () {
                    context.read<SupportBloc>().add(SupportSubmitted());
                  },
                  child: state.status == SupportStatus.loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Enviar mensaje por WhatsApp"),
                ),

                if (state.status == SupportStatus.failure)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      state.error ?? "",
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
