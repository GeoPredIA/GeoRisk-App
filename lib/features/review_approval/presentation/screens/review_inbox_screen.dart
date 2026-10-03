import 'package:flutter/material.dart';

import '../../data/services/review_manager_service.dart';

class ReviewInboxScreen extends StatefulWidget {
  const ReviewInboxScreen({super.key});

  @override
  State<ReviewInboxScreen> createState() => _ReviewInboxScreenState();
}

class _ReviewInboxScreenState extends State<ReviewInboxScreen> {
  static const _filters = [
    'Todas',
    'Pendiente',
    'Aprobada',
    'Observada',
    'Rechazada',
  ];

  String _selectedFilter = 'Todas';

  Future<void> _submitDecision(
    BuildContext context,
    ReviewTaskItem task,
    String title,
    void Function(String id, {String? comment}) submit,
  ) async {
    var commentValue = task.comment;
    final comment = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: TextFormField(
          initialValue: task.comment,
          autofocus: true,
          minLines: 2,
          maxLines: 5,
          onChanged: (value) => commentValue = value,
          decoration: const InputDecoration(
            labelText: 'Comentario para el expediente',
            alignLabelWithHint: true,
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, commentValue),
            child: const Text('Confirmar dictamen'),
          ),
        ],
      ),
    );
    if (comment == null) return;

    submit(task.id, comment: comment.trim());
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Dictamen registrado: $title')),
    );
  }

  Future<void> _deleteTask(BuildContext context, ReviewTaskItem task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar tarea'),
        content: Text('Se eliminará la revisión de ${task.zoneName}.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed == true) ReviewManagerService.instance.deleteTask(task.id);
  }

  @override
  Widget build(BuildContext context) {
    final service = ReviewManagerService.instance;

    return AnimatedBuilder(
      animation: service,
      builder: (context, _) {
        final allTasks = service.tasks;
        final tasks = _selectedFilter == 'Todas'
            ? allTasks
            : allTasks.where((task) => task.status == _selectedFilter).toList();
        final pendingCount =
            allTasks.where((task) => task.status == 'Pendiente').length;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Revisión humana'),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Text(
                    '$pendingCount pendientes',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Text(
                  'Dictámenes de evaluaciones y monitoreos',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final filter in _filters)
                      ChoiceChip(
                        label: Text(filter),
                        selected: _selectedFilter == filter,
                        onSelected: (_) =>
                            setState(() => _selectedFilter = filter),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: tasks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.task_alt, size: 40),
                            const SizedBox(height: 10),
                            Text(
                              _selectedFilter == 'Todas'
                                  ? 'No hay tareas de revisión'
                                  : 'No hay tareas con estado "$_selectedFilter"',
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
                        itemCount: tasks.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) => _buildTaskTile(
                          context,
                          tasks[index],
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTaskTile(BuildContext context, ReviewTaskItem task) {
    final statusColor = switch (task.status) {
      'Aprobada' => const Color(0xFF26734D),
      'Observada' => const Color(0xFFAA6810),
      'Rechazada' => const Color(0xFFB3261E),
      _ => const Color(0xFF315E8A),
    };

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Text(
          '${task.zoneCode} · ${task.zoneName}',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text('${task.origin} · ${task.date}'),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                task.status,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.expand_more),
          ],
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.summary),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _scoreChip('Global', task.globalScore),
                    _scoreChip('Geológico', task.geoScore),
                    _scoreChip('Ambiental', task.envScore),
                    _scoreChip('Social', task.socialScore),
                  ],
                ),
                const SizedBox(height: 12),
                _detailLine('Revisor', task.reviewer),
                _detailLine('Dictamen', task.decision),
                if (task.comment.isNotEmpty)
                  _detailLine('Comentario', task.comment),
                const SizedBox(height: 14),
                if (task.status == 'Pendiente')
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton.icon(
                        onPressed: () => _submitDecision(
                          context,
                          task,
                          'Aprobar evaluación',
                          ReviewManagerService.instance.approveTask,
                        ),
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Aprobar'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _submitDecision(
                          context,
                          task,
                          'Observar evaluación',
                          ReviewManagerService.instance.observeTask,
                        ),
                        icon: const Icon(Icons.rate_review_outlined, size: 18),
                        label: const Text('Observar'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _submitDecision(
                          context,
                          task,
                          'Rechazar evaluación',
                          ReviewManagerService.instance.rejectTask,
                        ),
                        icon: const Icon(Icons.block, size: 18),
                        label: const Text('Rechazar'),
                      ),
                    ],
                  )
                else
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      tooltip: 'Eliminar tarea',
                      onPressed: () => _deleteTask(context, task),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _scoreChip(String label, int score) {
    return Chip(
      label: Text('$label $score/100'),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _detailLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text('$label: $value'),
    );
  }
}
