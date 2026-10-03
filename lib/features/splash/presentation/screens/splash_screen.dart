// =============================================================
// features/splash/presentation/screens/splash_screen.dart
// -------------------------------------------------------------
// Pantalla de carga inicial. No permite ingresar hasta que el dataset esté listo.
// =============================================================

import 'dart:async';

import 'package:flutter/material.dart';
import '../../../../app/navigation/main_bottom_nav.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/geopredia_logo.dart';
import '../../../dashboard/data/services/mining_dataset_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  Timer? _progressTimer;
  final Stopwatch _progressClock = Stopwatch();
  double _progress = 0;
  String _statusText = 'Iniciando GeoPredIA...';
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );

    _animController.forward();
    _loadDataset();
  }

  Future<void> _loadDataset() async {
    final minimumSplashDuration =
        Future<void>.delayed(const Duration(seconds: 3));
    _progressTimer?.cancel();
    _progress = 0;
    _progressClock
      ..reset()
      ..start();
    _progressTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (!mounted) return;
      final nextProgress = (_progressClock.elapsedMilliseconds / 3000 * 0.9)
          .clamp(0.0, 0.9)
          .toDouble();
      if (nextProgress > _progress) {
        setState(() => _progress = nextProgress);
      }
    });

    if (_hasError) {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _statusText = 'Cargando los datos de GeoPredIA...';
      });
    }

    try {
      final dataset = MiningDatasetService.instance;
      await Future.wait<void>([
        dataset.init(),
        minimumSplashDuration,
      ]);
      if (!dataset.isLoaded || dataset.allZones.isEmpty) {
        throw StateError('El dataset no contiene zonas disponibles.');
      }
      _progressTimer?.cancel();
      _progressClock.stop();
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _progress = 1;
        _statusText =
            'Carga completa · ${dataset.allZones.length} zonas listas';
      });
      await WidgetsBinding.instance.endOfFrame;
      _goToMain();
    } catch (_) {
      await minimumSplashDuration;
      _progressTimer?.cancel();
      _progressClock.stop();
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
        _statusText = 'No se pudieron cargar los datos';
      });
    }
  }

  void _goToMain() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const MainBottomNav(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _progressClock.stop();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF113F35),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth < 400 ? 20.0 : 32.0;
            final logoSize = (constraints.maxWidth * 0.3).clamp(96.0, 132.0);

            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: 24,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const SizedBox(height: 24),
                        GeoPredIALogo(size: logoSize),
                        const SizedBox(height: 40),
                        Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 460),
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                    value: _progress,
                                    minHeight: 6,
                                    backgroundColor:
                                        Colors.white.withValues(alpha: 0.24),
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                      Color(0xFFFFB74D),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 18),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  child: Text(
                                    _statusText,
                                    key: ValueKey<String>(_statusText),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (_hasError) ...[
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Revisa la conexión e inténtalo de nuevo.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  FilledButton.icon(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: AppColors.primaryDark,
                                    ),
                                    onPressed: _isLoading ? null : _loadDataset,
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Reintentar carga'),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'GeoPredIA · Inteligencia para la Exploración Minera\nSAP BTP & Joule Integration',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
