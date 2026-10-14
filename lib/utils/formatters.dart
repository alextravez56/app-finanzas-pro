import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

String formatearMoneda(double monto) {
  final partes = monto.abs().toStringAsFixed(2).split('.');
  final entero = partes[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => ',',
  );
  return '${monto < 0 ? '-' : ''}\$$entero.${partes[1]}';
}

String mensajeErrorAuth(FirebaseAuthException error) {
  return switch (error.code) {
    'invalid-email' => 'El formato del correo no es válido.',
    'user-not-found' ||
    'invalid-credential' ||
    'wrong-password' => 'Correo o contraseña incorrectos.',
    'email-already-in-use' => 'Ya existe una cuenta con este correo.',
    'weak-password' => 'Elige una contraseña más segura (mínimo 6 caracteres).',
    'too-many-requests' =>
      'Hubo demasiados intentos. Espera un momento y vuelve a intentarlo.',
    'network-request-failed' =>
      'No hay conexión. Revisa tu internet e inténtalo de nuevo.',
    'operation-not-allowed' =>
      'El inicio de sesión por correo aún no está habilitado en Firebase.',
    'user-disabled' => 'Esta cuenta está deshabilitada. Contacta al soporte.',
    'requires-recent-login' =>
      'Vuelve a iniciar sesión y repite la operación para confirmar tu identidad.',
    'credential-already-in-use' => 'Ese correo ya está asociado a otra cuenta.',
    _ =>
      'No se pudo completar la operación de acceso. '
          '${error.message ?? error.code}',
  };
}

class EtiquetaAcceso extends StatelessWidget {
  const EtiquetaAcceso(this.texto, {super.key});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: const TextStyle(
        color: Color(0xFFD6DCE7),
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

InputDecoration decoracionAcceso({
  required String hint,
  required IconData icon,
  Widget? suffix,
}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Color(0xFF69768A), fontSize: 13),
    prefixIcon: Icon(icon, color: const Color(0xFF8792A5), size: 19),
    suffixIcon: suffix,
    filled: true,
    fillColor: const Color(0xFF0F1724),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.07)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFF55D6A0)),
    ),
    errorStyle: const TextStyle(color: Color(0xFFFF8798)),
  );
}

Widget mensajeAcceso(String mensaje, {required bool esError}) {
  final color = esError ? const Color(0xFFFF8798) : const Color(0xFF8DE3B7);
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withValues(alpha: 0.22)),
    ),
    child: Text(
      mensaje,
      key: Key(esError ? 'auth_error' : 'auth_message'),
      style: TextStyle(color: color, fontSize: 12, height: 1.45),
    ),
  );
}
