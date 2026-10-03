import 'dart:convert';
import 'dart:math' as math;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/widgets/topographic_background.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const _nameKey = 'operator_profile_name';
  static const _emailKey = 'operator_profile_email';
  static const _phoneKey = 'operator_profile_phone';
  static const _avatarKey = 'operator_profile_avatar';

  String _name = 'Ing. Alejandro Samir';
  String _email = '';
  String _phone = '';
  Uint8List? _avatarBytes;
  bool _isLoading = true;
  bool _isPickingPhoto = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final encodedAvatar = preferences.getString(_avatarKey);
      Uint8List? avatar;
      if (encodedAvatar != null) {
        try {
          avatar = base64Decode(encodedAvatar);
        } on FormatException {
          await preferences.remove(_avatarKey);
        }
      }

      if (!mounted) return;
      setState(() {
        _name = preferences.getString(_nameKey) ?? _name;
        _email = preferences.getString(_emailKey) ?? '';
        _phone = preferences.getString(_phoneKey) ?? '';
        _avatarBytes = avatar;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickPhoto() async {
    if (_isPickingPhoto) return;
    setState(() => _isPickingPhoto = true);

    try {
      final files = await FilePicker.pickFiles(
        type: FileType.image,
        compressionQuality: 90,
        dialogTitle: 'Seleccionar foto de perfil',
      );
      if (files.isEmpty) return;

      final sourceBytes = await files.first.readAsBytes();
      final compressedBytes = await compute(_compressAvatar, sourceBytes);
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(_avatarKey, base64Encode(compressedBytes));

      if (!mounted) return;
      setState(() => _avatarBytes = compressedBytes);
      _showMessage('Foto de perfil actualizada');
    } catch (_) {
      if (mounted) _showMessage('No se pudo cargar la imagen seleccionada');
    } finally {
      if (mounted) setState(() => _isPickingPhoto = false);
    }
  }

  Future<void> _editProfile() async {
    final formKey = GlobalKey<FormState>();
    var nameValue = _name;
    var emailValue = _email;
    var phoneValue = _phone;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Editar perfil'),
        content: SizedBox(
          width: math.min(MediaQuery.sizeOf(context).width * 0.82, 420),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    key: const ValueKey('profile-name-field'),
                    initialValue: _name,
                    onChanged: (value) => nameValue = value,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Nombre completo',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) => (value ?? '').trim().isEmpty
                        ? 'Escribe tu nombre'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const ValueKey('profile-email-field'),
                    initialValue: _email,
                    onChanged: (value) => emailValue = value,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Correo electrónico',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      final email = (value ?? '').trim();
                      if (email.isEmpty) return null;
                      return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                              .hasMatch(email)
                          ? null
                          : 'Escribe un correo válido';
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const ValueKey('profile-phone-field'),
                    initialValue: _phone,
                    onChanged: (value) => phoneValue = value,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Teléfono',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton.icon(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(dialogContext, true);
              }
            },
            icon: const Icon(Icons.save_outlined, size: 18),
            label: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    final name = nameValue.trim();
    final email = emailValue.trim();
    final phone = phoneValue.trim();

    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(_nameKey, name);
      await preferences.setString(_emailKey, email);
      await preferences.setString(_phoneKey, phone);
      if (!mounted) return;
      setState(() {
        _name = name;
        _email = email;
        _phone = phone;
      });
      _showMessage('Perfil actualizado');
    } catch (_) {
      if (mounted) _showMessage('No se pudo guardar el perfil');
    }
  }

  Future<void> _showPasswordNotice() => showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          icon: const Icon(Icons.lock_outline),
          title: const Text('Cambio de contraseña'),
          content: const Text(
            'Esta aplicación todavía no está conectada a un proveedor de '
            'autenticación. Por seguridad, no guarda ni cambia contraseñas '
            'localmente. Cuando se conecte el servicio de identidad, este '
            'control podrá actualizar tu cuenta.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Entendido'),
            ),
          ],
        ),
      );

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBF9),
      appBar: AppBar(
        title: const Text(
          'Perfil del Operador',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Stack(
        children: [
          const Positioned.fill(
            child: RepaintBoundary(child: TopographicBackground()),
          ),
          Positioned.fill(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 680),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildIdentityCard(),
                              const SizedBox(height: 12),
                              _buildContactCard(),
                              const SizedBox(height: 12),
                              _buildSecurityCard(),
                              const SizedBox(height: 12),
                              _buildPrivilegesCard(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdentityCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: const Color(0xFF0E3B2E),
                  backgroundImage:
                      _avatarBytes == null ? null : MemoryImage(_avatarBytes!),
                  child: _avatarBytes == null
                      ? Text(
                          _initials,
                          style: const TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
                Positioned(
                  right: -4,
                  bottom: -4,
                  child: Material(
                    color: const Color(0xFF0E3B2E),
                    shape: const CircleBorder(),
                    child: IconButton(
                      tooltip: 'Cambiar foto de perfil',
                      onPressed: _isPickingPhoto ? null : _pickPhoto,
                      icon: _isPickingPhoto
                          ? const SizedBox.square(
                              dimension: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.photo_camera_outlined,
                              size: 18,
                              color: Colors.white,
                            ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              _name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Ingeniero Geotécnico Senior · Revisor HITL',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0E3B2E),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'CIP N.° 284910 · Capítulo de Minas y Geología',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _editProfile,
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Editar perfil'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'INFORMACIÓN DE CONTACTO',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0E3B2E),
              ),
            ),
            const SizedBox(height: 6),
            _infoTile(
              icon: Icons.email_outlined,
              label: 'Correo electrónico',
              value: _email.isEmpty ? 'Añadir correo' : _email,
            ),
            _infoTile(
              icon: Icons.phone_outlined,
              label: 'Teléfono',
              value: _phone.isEmpty ? 'Añadir teléfono' : _phone,
            ),
            _infoTile(
              icon: Icons.badge_outlined,
              label: 'Número de colegiatura',
              value: 'CIP 284910',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: ListTile(
        leading: const Icon(Icons.lock_outline, color: Color(0xFF0E3B2E)),
        title: const Text('Cambiar contraseña'),
        subtitle: const Text('Requiere conectar un proveedor de identidad'),
        trailing: const Icon(Icons.chevron_right),
        onTap: _showPasswordNotice,
      ),
    );
  }

  Widget _buildPrivilegesCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PRIVILEGIOS HITL ACTIVOS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0E3B2E),
              ),
            ),
            Divider(height: 20, color: Color(0xFFF1F5F9)),
            Text('Dictamen vinculante en Revisión Humana (Compuerta 2)'),
            SizedBox(height: 6),
            Text('Validación de telemetría IoT de campo en tiempo real'),
            SizedBox(height: 6),
            Text('Integración autorizada con SAP HANA Cloud y SAC'),
          ],
        ),
      ),
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: const Color(0xFF64748B)),
      title: Text(label, style: const TextStyle(fontSize: 12)),
      subtitle: Text(
        value,
        softWrap: true,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF1E293B),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String get _initials {
    final parts = _name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return 'OP';
    return parts.take(2).map((part) => part[0].toUpperCase()).join();
  }
}

Uint8List _compressAvatar(Uint8List sourceBytes) {
  final source = img.decodeImage(sourceBytes);
  if (source == null) throw const FormatException('Invalid image data');

  final scale = math.min(512 / source.width, 512 / source.height);
  final resized = img.copyResize(
    source,
    width: math.max(1, (source.width * scale).round()),
    height: math.max(1, (source.height * scale).round()),
    interpolation: img.Interpolation.average,
  );
  return Uint8List.fromList(img.encodeJpg(resized, quality: 82));
}
