// =============================================================
// features/splash/presentation/screens/splash_screen.dart
// -------------------------------------------------------------
// Pantalla de carga inicial. No permite ingresar hasta que el dataset esté listo.
// =============================================================

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
  String _statusText = 'Iniciando GeoPreIA...';
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

    if (_hasError) {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _statusText = 'Cargando los datos de GeoPreIA...';
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
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _statusText =
            'Carga completa · ${dataset.allZones.length} zonas listas';
      });
      await WidgetsBinding.instance.endOfFrame;
      _goToMain();
    } catch (_) {
      await minimumSplashDuration;
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
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth < 400 ? 20.0 : 32.0;
            final logoSize = constraints.maxWidth < 360 ? 48.0 : 62.0;

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
                        const SizedBox(height: 16),
                        GeoPredIALogo(
                          size: logoSize,
                          isDark: false,
                          showText: true,
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 460),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 22,
                                vertical: 20,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.borderSubtle,
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: LinearProgressIndicator(
                                      value: _hasError
                                          ? 0
                                          : (_isLoading ? null : 1),
                                      minHeight: 6,
                                      backgroundColor: AppColors.borderSubtle,
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                        AppColors.primaryDark,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    child: Text(
                                      _statusText,
                                      key: ValueKey<String>(_statusText),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 13,
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
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    FilledButton.icon(
                                      onPressed:
                                          _isLoading ? null : _loadDataset,
                                      icon: const Icon(Icons.refresh),
                                      label: const Text('Reintentar carga'),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'GeoPreIA · Inteligencia para la Exploración Minera\nSAP BTP & Joule Integration',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textMuted,
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
