import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_footer.dart';

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantChatMessage {
  final String sender;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? agentTag;
  final List<String>? sources;

  _AssistantChatMessage({
    required this.sender,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.agentTag,
    this.sources,
  });
}

class _AssistantScreenState extends State<AssistantScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<_AssistantChatMessage> _messages = [
    _AssistantChatMessage(
      sender: 'SAP Joule · Copiloto Minero',
      text:
          '¡Hola! Soy Joule, tu copiloto inteligente de GeoPredIA. He sintetizado 12 zonas de exploración minera en el Perú, correlacionando telemetría de campo, datos espaciales de SAP HANA Cloud y directrices de mitigación. ¿Qué deseas analizar hoy?',
      isUser: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      agentTag: 'Orquestador Joule',
      sources: ['SAP HANA Cloud v4', 'Sensor LoRaWAN Z-001', 'MINEM Catastro'],
    ),
  ];

  final List<String> _quickPrompts = [
    '¿Por qué Quellaveco Norte tiene riesgo social alto?',
    '¿Qué ocurre en Cuenca Alta con los sensores de agua?',
    'Verificar compuerta HITL 2 para Cordillera Central',
    'Explicar el impacto de la regla del dato faltante',
  ];

  void _sendMessage(String query) {
    if (query.trim().isEmpty) return;

    final userMsg = _AssistantChatMessage(
      sender: 'Tú (Especialista)',
      text: query,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMsg);
    });
    _textController.clear();

    Future.delayed(const Duration(milliseconds: 650), () {
      String response = '';
      String tag = 'Joule Orquestador';
      List<String> sources = ['SAP HANA Cloud'];

      if (query.contains('Quellaveco') || query.contains('social')) {
        tag = 'Agente Social & Comunitario';
        sources = ['Encuesta de Clima Comunal', 'SAP HANA SPATIAL', 'Actas de Diálogo'];
        response =
            'En Quellaveco Norte (Z-001), el índice social se ubica en 88/100 (Crítico). '
            'Las fuentes primarias indican 3 mesas de diálogo pendientes con la Comunidad de Tumilaca '
            'respecto al desvío de cauce hídrico estacional. La recomendación de la IA es condicionar '
            'el permiso de sondajes de la Compuerta 2 a la firma de compromisos hídricos vinculantes.';
      } else if (query.contains('Cuenca Alta') || query.contains('agua') || query.contains('faltante')) {
        tag = 'Agente Hidrológico & Integridad';
        sources = ['Regla de Oro GeoPredIA', 'Sensor Cuenca Alta', 'ISO 19115'];
        response =
            'En Cuenca Alta (Z-005), se aplica la directriz "El dato que falta también importa". '
            'Debido a una pérdida de conectividad en el nodo de turbidez hídrica TH-09, el puntaje '
            'global NO se computa en cero; se clasifica como "Sin datos" con penalización de incertidumbre. '
            'No se autoriza dictamen favorable hasta restablecer la telemetría.';
      } else if (query.contains('Cordillera') || query.contains('HITL')) {
        tag = 'SAP Build Process Automation';
        sources = ['Workflow BTP #4829', 'Compuerta 1 Aprobada'];
        response =
            'Cordillera Central (Z-002) completó con éxito la Compuerta 1 (Revisión Técnica) con score 52/100. '
            'Actualmente está en cola de la Compuerta 2 (Gobernanza y Sostenibilidad), asignada al Gerente de Operaciones. '
            'Las medidas de contención de relaves ya cuentan con visto bueno geológico.';
      } else {
        response =
            'He consultado el repositorio analítico de SAP HANA Cloud. Para tu consulta sobre "$query", '
            'los modelos predictivos recomiendan revisar la telemetría en tiempo real y validar con el '
            'equipo multidisciplinario antes de elevar la solicitud al Comité de Exploraciones.';
      }

      setState(() {
        _messages.add(
          _AssistantChatMessage(
            sender: 'SAP Joule · Copiloto Minero',
            text: response,
            isUser: false,
            timestamp: DateTime.now(),
            agentTag: tag,
            sources: sources,
          ),
        );
      });

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 200,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primaryDark,
              child: Icon(Icons.auto_awesome, color: Colors.amber, size: 18),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Asistente Joule',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'SAP Joule Studio · Razonamiento Copiloto',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.cleaning_services_outlined),
            tooltip: 'Limpiar conversación',
            onPressed: () {
              setState(() {
                _messages.removeRange(1, _messages.length);
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(vertical: 6),
            color: Colors.white,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _quickPrompts.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final prompt = _quickPrompts[index];
                return ActionChip(
                  label: Text(prompt, style: const TextStyle(fontSize: 12)),
                  backgroundColor: AppColors.background,
                  side: const BorderSide(color: AppColors.borderSubtle),
                  onPressed: () => _sendMessage(prompt),
                );
              },
            ),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.borderSubtle),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _ChatBubble(message: msg);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      onSubmitted: _sendMessage,
                      decoration: InputDecoration(
                        hintText: 'Pregunta a Joule sobre riesgos, sensores o normativas...',
                        hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                        filled: true,
                        fillColor: AppColors.background,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: AppColors.primaryDark,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_upward, color: Colors.white),
                      onPressed: () => _sendMessage(_textController.text),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const AppFooter(
            customMessage: 'SAP Joule Studio · Generative AI Copilot for Mining Sustainability',
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final _AssistantChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    if (message.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12, left: 48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: AppColors.primaryDark,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(4),
            ),
          ),
          child: Text(
            message.text,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14, right: 32),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
          ),
          border: Border.all(color: AppColors.borderSubtle),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, size: 14, color: Colors.amber),
                const SizedBox(width: 6),
                Text(
                  message.agentTag ?? 'SAP Joule',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
                const Spacer(),
                Text(
                  "${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}",
                  style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              message.text,
              style: const TextStyle(fontSize: 14, height: 1.4, color: AppColors.textPrimary),
            ),
            if (message.sources != null && message.sources!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: message.sources!.map((src) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified_outlined, size: 11, color: AppColors.riskLow),
                        const SizedBox(width: 4),
                        Text(
                          src,
                          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}