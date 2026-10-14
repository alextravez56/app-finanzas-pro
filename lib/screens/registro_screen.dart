import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../utils/formatters.dart';

class PantallaRegistro extends StatefulWidget {
  const PantallaRegistro({super.key, this.registrarCuenta});

  final Future<void> Function(
    String nombre,
    String correo,
    String telefono,
    String contrasena,
  )?
  registrarCuenta;

  @override
  State<PantallaRegistro> createState() => _PantallaRegistroState();
}

class _PantallaRegistroState extends State<PantallaRegistro> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _correoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _contrasenaController = TextEditingController();
  final _confirmacionController = TextEditingController();
  bool _mostrarContrasena = false;
  bool _registrando = false;
  String? _error;

  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _contrasenaController.dispose();
    _confirmacionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C111B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          key: const Key('registration_back'),
          tooltip: 'Volver al inicio de sesión',
          onPressed: _registrando ? null : () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: const Color(0xFF151D2B),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.07),
                  ),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFF55D6A0)
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.person_add_alt_1_rounded,
                          color: Color(0xFF55D6A0),
                          size: 27,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Crea tu cuenta',
                        style: TextStyle(
                          color: Color(0xFFF3F6FC),
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Configura tu perfil financiero privado.',
                        style: TextStyle(
                          color: Color(0xFF9AA6B8),
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 26),
                      const EtiquetaAcceso('Nombre de usuario'),
                      const SizedBox(height: 8),
                      TextFormField(
                        key: const Key('registration_username'),
                        controller: _nombreController,
                        enabled: !_registrando,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.nickname],
                        style: const TextStyle(color: Color(0xFFF3F6FC)),
                        decoration: decoracionAcceso(
                          hint: 'Ej. Alex Travez',
                          icon: Icons.person_outline_rounded,
                        ),
                        validator: (value) {
                          final nombre = (value ?? '').trim();
                          if (nombre.length < 2 || nombre.length > 40) {
                            return 'Usa entre 2 y 40 caracteres';
                          }
                          if (nombre.contains(RegExp(r'[\u0000-\u001F]'))) {
                            return 'El nombre contiene caracteres no válidos';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 17),
                      const EtiquetaAcceso('Correo electrónico'),
                      const SizedBox(height: 8),
                      TextFormField(
                        key: const Key('registration_email'),
                        controller: _correoController,
                        enabled: !_registrando,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        style: const TextStyle(color: Color(0xFFF3F6FC)),
                        decoration: decoracionAcceso(
                          hint: 'nombre@correo.com',
                          icon: Icons.mail_outline_rounded,
                        ),
                        validator: (value) {
                          final correo = (value ?? '').trim();
                          if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                              .hasMatch(correo)) {
                            return 'Ingresa un correo electrónico válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 17),
                      const EtiquetaAcceso('Teléfono (opcional)'),
                      const SizedBox(height: 8),
                      TextFormField(
                        key: const Key('registration_phone'),
                        controller: _telefonoController,
                        enabled: !_registrando,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.telephoneNumber],
                        style: const TextStyle(color: Color(0xFFF3F6FC)),
                        decoration: decoracionAcceso(
                          hint: '+593 99 123 4567',
                          icon: Icons.phone_outlined,
                        ),
                        validator: (value) {
                          final telefono = (value ?? '').trim();
                          if (telefono.isEmpty) return null;
                          final digitos = telefono.replaceAll(
                            RegExp(r'\D'),
                            '',
                          );
                          if (telefono.length > 20 ||
                              digitos.length < 7 ||
                              !RegExp(r'^\+?[0-9 ()-]+$').hasMatch(telefono)) {
                            return 'Ingresa un teléfono válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 17),
                      const EtiquetaAcceso('Contraseña'),
                      const SizedBox(height: 8),
                      TextFormField(
                        key: const Key('registration_password'),
                        controller: _contrasenaController,
                        enabled: !_registrando,
                        obscureText: !_mostrarContrasena,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.newPassword],
                        style: const TextStyle(color: Color(0xFFF3F6FC)),
                        decoration: decoracionAcceso(
                          hint: 'Mínimo 8 caracteres',
                          icon: Icons.lock_outline_rounded,
                          suffix: IconButton(
                            tooltip: _mostrarContrasena
                                ? 'Ocultar contraseña'
                                : 'Mostrar contraseña',
                            onPressed: _registrando
                                ? null
                                : () => setState(
                                    () => _mostrarContrasena =
                                        !_mostrarContrasena,
                                  ),
                            icon: Icon(
                              _mostrarContrasena
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: const Color(0xFF8792A5),
                              size: 19,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if ((value ?? '').length < 8) {
                            return 'Usa al menos 8 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 17),
                      const EtiquetaAcceso('Confirma tu contraseña'),
                      const SizedBox(height: 8),
                      TextFormField(
                        key: const Key('registration_confirmation'),
                        controller: _confirmacionController,
                        enabled: !_registrando,
                        obscureText: !_mostrarContrasena,
                        textInputAction: TextInputAction.done,
                        style: const TextStyle(color: Color(0xFFF3F6FC)),
                        decoration: decoracionAcceso(
                          hint: 'Repite tu contraseña',
                          icon: Icons.lock_outline_rounded,
                        ),
                        validator: (value) {
                          if (value != _contrasenaController.text) {
                            return 'Las contraseñas no coinciden';
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) {
                          if (!_registrando) _enviarRegistro();
                        },
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 18),
                        mensajeAcceso(_error!, esError: true),
                      ],
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 52,
                        child: FilledButton(
                          key: const Key('registration_submit'),
                          onPressed: _registrando ? null : _enviarRegistro,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF55D6A0),
                            foregroundColor: const Color(0xFF0C111B),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          child: _registrando
                              ? const SizedBox(
                                  width: 21,
                                  height: 21,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF0C111B),
                                  ),
                                )
                              : const Text('Crear cuenta segura'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _registrando
                            ? null
                            : () => Navigator.of(context).pop(),
                        child: const Text(
                          'Ya tengo una cuenta',
                          style: TextStyle(color: Color(0xFF9DDDC1)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _enviarRegistro() async {
    if (_registrando || !_formKey.currentState!.validate()) return;
    setState(() {
      _registrando = true;
      _error = null;
    });

    try {
      final nombre = _nombreController.text.trim();
      final correo = _correoController.text.trim();
      final telefono = _telefonoController.text.trim();
      final contrasena = _contrasenaController.text;
      final registrarCuenta = widget.registrarCuenta;
      if (registrarCuenta != null) {
        await registrarCuenta(nombre, correo, telefono, contrasena);
      } else {
        final credencial = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: correo,
              password: contrasena,
            );
        final usuario = credencial.user;
        if (usuario == null) {
          throw StateError('Firebase no devolvió el usuario recién creado.');
        }

        await usuario.updateDisplayName(nombre);
        final perfil = <String, Object?>{
          'username': nombre,
          'email': usuario.email ?? correo,
          'fecha_registro': FieldValue.serverTimestamp(),
        };
        if (telefono.isNotEmpty) perfil['telefono'] = telefono;
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(usuario.uid)
            .set(perfil);
      }
      if (mounted) Navigator.of(context).pop();
    } on FirebaseAuthException catch (error) {
      if (mounted) setState(() => _error = mensajeErrorAuth(error));
    } on FirebaseException catch (error) {
      if (mounted) {
        setState(
          () => _error =
              'No se pudo guardar el perfil en la nube. Comprueba tu conexión '
              'y las reglas de Firestore. ${error.message ?? error.code}',
        );
      }
    } on StateError catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _registrando = false);
    }
  }
}
