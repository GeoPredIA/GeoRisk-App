import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi perfil')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Column(
              children: [
                const CircleAvatar(
                    radius: 42,
                    backgroundColor: AppColors.primaryDark,
                    child: Icon(Icons.person, size: 44, color: Colors.white)),
                const SizedBox(height: 12),
                Text('Alejandro Especialista',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                const Text('alejandro@geopredia.com'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Card(
            child: Column(
              children: [
                ListTile(
                    leading:
                        Icon(Icons.verified_outlined, color: AppColors.riskLow),
                    title: Text('Correo verificado'),
                    subtitle: Text('Identidad confirmada por Brevo')),
                Divider(height: 1),
                ListTile(
                    leading: Icon(Icons.badge_outlined),
                    title: Text('Rol institucional'),
                    subtitle: Text('Ingeniero de evaluación')),
                Divider(height: 1),
                ListTile(
                    leading: Icon(Icons.cloud_done_outlined,
                        color: AppColors.riskLow),
                    title: Text('Sincronización cloud'),
                    subtitle: Text('SAP HANA Cloud sincronizado hace 2 min')),
              ],
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (_) => false),
            icon: const Icon(Icons.logout),
            label: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}
