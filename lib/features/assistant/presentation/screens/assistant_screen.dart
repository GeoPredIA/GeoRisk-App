import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../dashboard/data/services/mining_dataset_service.dart';
import '../../data/services/joule_data_assistant.dart';

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
  final JouleDataAssistant _assistant = JouleDataAssistant();
  bool _isResponding = false;

  final List<_AssistantChatMessage> _messages = [
    _AssistantChatMessage(
      sender: 'Joule · Asistente GeoPredIA',
      text:
          'Hola. Puedo consultar las zonas del dataset local, explicar sus puntajes geológicos, ambientales y sociales, revisar sus dictámenes HITL y comparar riesgos. Pregunta por el nombre o código de cualquier zona, o haz una consulta general.',
      isUser: false,
      timestamp: DateTime.now(),
      agentTag: 'Datos locales GeoPredIA',
      sources: ['Dataset minero local'],
    ),
  ];

  List<String> get _quickPrompts {
    final zones = MiningDatasetService.instance.allZones;
    if (zones.isEmpty) {
      return const [
        'Resume el riesgo del portafolio',
        '¿Qué significan los puntajes?',
      ];
    }
    return [
      'Resume el riesgo de ${zones.first.name}',
      'Variables ambientales de ${zones.last.name}',
      '¿Cuáles zonas tienen mayor riesgo?',
      '¿Qué información contiene el dataset?',
    ];
  }

  Future<void> _sendMessage(String query) async {
    final prompt = query.trim();
    if (prompt.isEmpty || _isResponding) return;

    final userMsg = _AssistantChatMessage(
      sender: 'Tú',
      text: prompt,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMsg);
      _isResponding = true;
    });
    _textController.clear();
    _scrollToLatest();

    await Future<void>.delayed(const Duration(milliseconds: 250));
    final answer = await _assistant.answer(prompt);
    if (!mounted) return;
    setState(() {
      _isResponding = false;
      _messages.add(
        _AssistantChatMessage(
          sender: 'Joule · GeoPredIA',
          text: answer.text,
          isUser: false,
          timestamp: DateTime.now(),
          agentTag: answer.topic,
          sources: answer.sources,
        ),
      );
    });
    _scrollToLatest();
  }

  void _scrollToLatest() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: MediaQuery.sizeOf(context).width < 360
            ? const Text(
                'Joule',
                style: TextStyle(fontWeight: FontWeight.bold),
              )
            : const Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primaryDark,
                    child: Icon(
                      Icons.auto_awesome,
                      color: Colors.amber,
                      size: 18,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Asistente Joule',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Consultas sobre el dataset GeoPredIA',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
        actions: [
          IconButton(
            icon: const Icon(Icons.cleaning_services_outlined),
            tooltip: 'Limpiar conversación',
            onPressed: _isResponding
                ? null
                : () {
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
                  onPressed: _isResponding ? null : () => _sendMessage(prompt),
                );
              },
            ),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.borderSubtle),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 960),
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length + (_isResponding ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length) {
                      return const _TypingIndicator();
                    }
                    return _ChatBubble(message: _messages[index]);
                  },
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: SafeArea(
              top: false,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 960),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isCompact = constraints.maxWidth < 360;
                          final input = TextField(
                            controller: _textController,
                            minLines: 1,
                            maxLines: 4,
                            textInputAction: TextInputAction.send,
                            onSubmitted: _isResponding ? null : _sendMessage,
                            decoration: InputDecoration(
                              hintText: 'Escribe tu pregunta...',
                              hintStyle: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textMuted,
                              ),
                              filled: true,
                              fillColor: AppColors.background,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          );
                          final sendButton = IconButton.filled(
                            tooltip: 'Enviar pregunta',
                            constraints: const BoxConstraints.tightFor(
                              width: 48,
                              height: 48,
                            ),
                            onPressed: _isResponding
                                ? null
                                : () => _sendMessage(_textController.text),
                            icon: const Icon(Icons.arrow_upward),
                          );

                          if (isCompact) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                input,
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: sendButton,
                                ),
                              ],
                            );
                          }

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(child: input),
                              const SizedBox(width: 8),
                              sendButton,
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 5),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Respuestas basadas en datos locales; valida decisiones con el equipo técnico.',
                          maxLines: 2,
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(12, 0, 12, 6),
            child: Text(
              'Joule · Respuestas basadas en el dataset local GeoPredIA',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, color: AppColors.textMuted),
            ),
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
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 740),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12, left: 36),
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
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Container(
          margin: const EdgeInsets.only(bottom: 14, right: 24),
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
                  Expanded(
                    child: Text(
                      message.agentTag ?? 'Joule',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}",
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                message.text,
                style: const TextStyle(
                    fontSize: 14, height: 1.4, color: AppColors.textPrimary),
              ),
              if (message.sources != null && message.sources!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: message.sources!.map((src) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified_outlined,
                              size: 11, color: AppColors.riskLow),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              src,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textSecondary,
                              ),
                            ),
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
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox.square(
              dimension: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 8),
            Text('Joule está consultando el dataset'),
          ],
        ),
      ),
    );
  }
}
