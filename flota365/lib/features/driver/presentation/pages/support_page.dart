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

  // ✅ SOLO UI: texto negro siempre
  static const _inputTextStyle = TextStyle(color: Colors.black);

  InputDecoration _deco(String label, {String? hint, IconData? icon}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon) : null,

      // ✅ fuerza negro (tema oscuro ya no lo pone blanco)
      labelStyle: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
      hintStyle: const TextStyle(color: Colors.black45),

      filled: true,
      fillColor: Colors.black.withOpacity(.03),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.black.withOpacity(.10)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.black.withOpacity(.10)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.black.withOpacity(.35), width: 1.2),
      ),
    );
  }

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
            // ignore: avoid_print
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
        final loading = state.status == SupportStatus.loading;

        return Scaffold(
          appBar: AppBar(title: const Text("Servicio al Cliente")),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header pro (solo UI)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
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
                                color: Colors.teal.withOpacity(.12),
                              ),
                              child: const Icon(Icons.support_agent_rounded, color: Colors.teal),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Centro de soporte",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.black, // ✅ negro
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Cuéntanos tu problema y lo enviamos por WhatsApp.",
                                    style: TextStyle(
                                      color: Colors.black.withOpacity(.65),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Form Card pro
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.black.withOpacity(.06)),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 18,
                              offset: const Offset(0, 10),
                              color: Colors.black.withOpacity(.06),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            TextField(
                              style: _inputTextStyle, // ✅ texto negro
                              cursorColor: Colors.black,
                              textInputAction: TextInputAction.next,
                              decoration: _deco(
                                "Asunto",
                                hint: "Ej: Problema con mi ruta",
                                icon: Icons.subject_rounded,
                              ),
                              onChanged: (v) => context
                                  .read<SupportBloc>()
                                  .add(SupportSubjectChanged(v)),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              style: _inputTextStyle, // ✅ texto negro
                              cursorColor: Colors.black,
                              maxLines: 6,
                              textInputAction: TextInputAction.newline,
                              decoration: _deco(
                                "Mensaje",
                                hint: "Describe lo ocurrido con el mayor detalle posible...",
                                icon: Icons.message_rounded,
                              ),
                              onChanged: (v) => context
                                  .read<SupportBloc>()
                                  .add(SupportMessageChanged(v)),
                            ),
                            const SizedBox(height: 16),

                            SizedBox(
                              height: 52,
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: loading
                                    ? null
                                    : () {
                                        context
                                            .read<SupportBloc>()
                                            .add(SupportSubmitted());
                                      },
                                icon: const Icon(Icons.chat_rounded),
                                label: loading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.black,
                                        ),
                                      )
                                    : const Text(
                                        "Enviar por WhatsApp",
                                        style: TextStyle(fontWeight: FontWeight.w800),
                                      ),
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),

                            if (state.status == SupportStatus.failure)
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(.08),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: Colors.red.withOpacity(.25)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.error_outline_rounded, color: Colors.red),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          state.error ?? "",
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
