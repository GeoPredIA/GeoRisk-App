import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class MultiagentAnalysisScreen extends StatefulWidget {
  const MultiagentAnalysisScreen({super.key});

  @override
  State<MultiagentAnalysisScreen> createState() =>
      _MultiagentAnalysisScreenState();
}

class _MultiagentAnalysisScreenState extends State<MultiagentAnalysisScreen> {
  int _selectedIndex = 0;

  static const _agents = [
    (
      'Geológico',
      Icons.landscape_outlined,
      'Estabilidad de laderas y estructura del terreno',
      'Riesgo moderado: inspección de taludes al norte.'
    ),
    (
      'Ambiental',
      Icons.eco_outlined,
      'Agua, biodiversidad y calidad del suelo',
      'Riesgo bajo: sensores dentro de rangos esperados.'
    ),
    (
      'Social',
      Icons.groups_outlined,
      'Comunidad, territorio y licencia social',
      'Riesgo alto: requiere diálogo comunitario.'
    ),
    (
      'Coordinador',
      Icons.hub_outlined,
      'Dictamen consolidado por SAP Joule',
      'Revisión humana recomendada. Confianza: 91%.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final agent = _agents[_selectedIndex];
    return Scaffold(
      appBar: AppBar(title: const Text('Multiagentes')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
              color: AppColors.primaryDark,
              child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(children: [
                    const CircleAvatar(
                        backgroundColor: Colors.white24,
                        child: Icon(Icons.auto_awesome, color: Colors.white)),
                    const SizedBox(width: 12),
                    const Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text('Joule Orchestrator',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text('Análisis coordinado listo para revisión',
                              style: TextStyle(color: Colors.white70))
                        ])),
                    const Icon(Icons.circle, size: 12, color: AppColors.riskLow)
                  ]))),
          const SizedBox(height: 16),
          SegmentedButton<int>(
              segments: [
                for (var index = 0; index < _agents.length; index++)
                  ButtonSegment(
                      value: index,
                      label: Text(_agents[index].$1),
                      icon: Icon(_agents[index].$2))
              ],
              selected: {
                _selectedIndex
              },
              onSelectionChanged: (selection) =>
                  setState(() => _selectedIndex = selection.first),
              showSelectedIcon: false),
          const SizedBox(height: 16),
          Card(
              child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Icon(agent.$2, color: AppColors.primaryDark),
                          const SizedBox(width: 10),
                          Text(agent.$1,
                              style: Theme.of(context).textTheme.titleLarge)
                        ]),
                        const SizedBox(height: 18),
                        Text(agent.$3,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 12),
                        Text(agent.$4),
                        const SizedBox(height: 20),
                        LinearProgressIndicator(
                            value: _selectedIndex == 2 ? .82 : .91,
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(8),
                            color: _selectedIndex == 2
                                ? AppColors.riskHigh
                                : AppColors.riskLow),
                        const SizedBox(height: 8),
                        Text(
                            'Evidencia procesada · ${_selectedIndex == 3 ? '3' : '12'} hallazgos',
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 12))
                      ]))),
          const SizedBox(height: 16),
          FilledButton.icon(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Dictamen enviado a Revisión Humana.'))),
              icon: const Icon(Icons.fact_check_outlined),
              label: const Text('Enviar a Revisión Humana')),
        ],
      ),
    );
  }
}
