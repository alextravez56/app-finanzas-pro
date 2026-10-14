import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../utils/formatters.dart';

class PantallaPerfilUsuario extends StatefulWidget {
  const PantallaPerfilUsuario({
    super.key,
    required this.uid,
    required this.correo,
    this.leerTelefono,
    this.guardarTelefono,
    this.reautenticar,
    this.enviarCambioCorreo,
    this.actualizarContrasena,
  });

  final String uid;
  final String correo;
  final Future<String?> Function(String uid)? leerTelefono;
  final Future<void> Function(String uid, String telefono)? guardarTelefono;
  final Future<void> Function(String correo, String contrasena)? reautenticar;
  final Future<void> Function(String correo)? enviarCambioCorreo;
  final Future<void> Function(String contrasena)? actualizarContrasena;

  @override
  State<PantallaPerfilUsuario> createState() => _PantallaPerfilUsuarioState();
}

class _PantallaPerfilUsuarioState extends State<PantallaPerfilUsuario> {
  final _telefonoFormKey = GlobalKey<FormState>();
  final _correoFormKey = GlobalKey<FormState>();
  final _contrasenaFormKey = GlobalKey<FormState>();
  final _telefonoController = TextEditingController();
  final _nuevoCorreoController = TextEditingController();
  final _passCorreoController = TextEditingController();
  final _passActualController = TextEditingController();
  final _passNuevaController = TextEditingController();
  final _scrollController = ScrollController();
  bool _cargandoTelefono = true;
  bool _ocupado = false;
  String? _error;
  String? _mensaje;

  @override
  void initState() {
    super.initState();
    _cargarTelefono();
  }

  @override
  void dispose() {
    _telefonoController.dispose();
    _nuevoCorreoController.dispose();
    _passCorreoController.dispose();
    _passActualController.dispose();
    _passNuevaController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _cargarTelefono() async {
    try {
      final leerTelefono = widget.leerTelefono;
      String? telefono;
      if (leerTelefono == null) {
        final documento = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(widget.uid)
            .get();
        final valor = documento.data()?['telefono'];
        telefono = valor is String ? valor : null;
      } else {
        telefono = await leerTelefono(widget.uid);
      }
      if (!mounted) return;
      _telefonoController.text = telefono ?? '';
    } on FirebaseException catch (error) {
      if (mounted) _mostrarError(error);
    } catch (error) {
      if (mounted) _mostrarError(error);
    } finally {
      if (mounted) setState(() => _cargandoTelefono = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C111B),
      appBar: AppBar(
        title: const Text('Mi perfil'),
        backgroundColor: const Color(0xFF101722),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.all(22),
              children: [
                const Text(
                  'Administra tus datos y credenciales',
                  style: TextStyle(
                    color: Color(0xFFF3F6FC),
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Cuenta: ${widget.correo}',
                  key: const Key('profile_current_email'),
                  style: const TextStyle(color: Color(0xFF9AA6B8)),
                ),
                if (_error != null || _mensaje != null) ...[
                  const SizedBox(height: 16),
                  mensajeAcceso(_error ?? _mensaje!, esError: _error != null),
                ],
                const SizedBox(height: 22),
                _tarjetaSeccion(
                  titulo: 'Datos personales',
                  descripcion:
                      'Tu teléfono se guarda solo en el perfil de tu cuenta.',
                  contenido: Form(
                    key: _telefonoFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          key: const Key('profile_phone'),
                          controller: _telefonoController,
                          enabled: !_ocupado && !_cargandoTelefono,
                          keyboardType: TextInputType.phone,
                          autofillHints: const [AutofillHints.telephoneNumber],
                          decoration:
                              decoracionAcceso(
                                hint: '+593 99 123 4567',
                                icon: Icons.phone_outlined,
                              ).copyWith(
                                labelText: 'Número de teléfono',
                                suffixIcon: _cargandoTelefono
                                    ? const Padding(
                                        padding: EdgeInsets.all(14),
                                        child: SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      )
                                    : null,
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
                                !RegExp(r'^\+?[0-9 ()-]+$')
                                    .hasMatch(telefono)) {
                              return 'Ingresa un teléfono válido o déjalo vacío';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        Align(
                          alignment: Alignment.centerRight,
                          child: FilledButton.icon(
                            key: const Key('profile_save_phone'),
                            onPressed: _ocupado || _cargandoTelefono
                                ? null
                                : _guardarTelefono,
                            icon: const Icon(Icons.save_outlined),
                            label: const Text('Guardar teléfono'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _tarjetaSeccion(
                  titulo: 'Cambiar correo electrónico',
                  descripcion:
                      'Confirmaremos el cambio mediante un enlace enviado '
                      'al nuevo correo. Se requiere tu contraseña actual.',
                  contenido: Form(
                    key: _correoFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          key: const Key('profile_new_email'),
                          controller: _nuevoCorreoController,
                          enabled: !_ocupado,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          decoration: decoracionAcceso(
                            hint: 'nuevo@correo.com',
                            icon: Icons.mail_outline_rounded,
                          ).copyWith(labelText: 'Nuevo correo'),
                          validator: (value) {
                            final correo = (value ?? '').trim();
                            if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                .hasMatch(correo)) {
                              return 'Ingresa un correo válido';
                            }
                            if (correo.toLowerCase() ==
                                widget.correo.toLowerCase()) {
                              return 'Ese ya es el correo de tu cuenta';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          key: const Key('profile_email_password'),
                          controller: _passCorreoController,
                          enabled: !_ocupado,
                          obscureText: true,
                          decoration: decoracionAcceso(
                            hint: 'Contraseña actual',
                            icon: Icons.lock_outline_rounded,
                          ).copyWith(labelText: 'Confirma tu contraseña'),
                          validator: (value) => (value ?? '').isEmpty
                              ? 'Ingresa tu contraseña actual'
                              : null,
                        ),
                        const SizedBox(height: 14),
                        Align(
                          alignment: Alignment.centerRight,
                          child: FilledButton.icon(
                            key: const Key('profile_send_email_change'),
                            onPressed: _ocupado ? null : _solicitarCambioCorreo,
                            icon: const Icon(Icons.mark_email_read_outlined),
                            label: const Text('Enviar enlace de confirmación'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _tarjetaSeccion(
                  titulo: 'Cambiar contraseña',
                  descripcion:
                      'Por seguridad, vuelve a validar tu identidad antes '
                      'de guardar una contraseña nueva.',
                  contenido: Form(
                    key: _contrasenaFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          key: const Key('profile_current_password'),
                          controller: _passActualController,
                          enabled: !_ocupado,
                          obscureText: true,
                          decoration: decoracionAcceso(
                            hint: 'Contraseña actual',
                            icon: Icons.lock_outline_rounded,
                          ).copyWith(labelText: 'Contraseña actual'),
                          validator: (value) => (value ?? '').isEmpty
                              ? 'Ingresa tu contraseña actual'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          key: const Key('profile_new_password'),
                          controller: _passNuevaController,
                          enabled: !_ocupado,
                          obscureText: true,
                          autofillHints: const [AutofillHints.newPassword],
                          decoration: decoracionAcceso(
                            hint: 'Mínimo 8 caracteres',
                            icon: Icons.password_outlined,
                          ).copyWith(labelText: 'Nueva contraseña'),
                          validator: (value) {
                            if ((value ?? '').length < 8) {
                              return 'Usa al menos 8 caracteres';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        Align(
                          alignment: Alignment.centerRight,
                          child: FilledButton.icon(
                            key: const Key('profile_update_password'),
                            onPressed: _ocupado ? null : _cambiarContrasena,
                            icon: const Icon(Icons.password_rounded),
                            label: const Text('Actualizar contraseña'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tarjetaSeccion({
    required String titulo,
    required String descripcion,
    required Widget contenido,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF151D2B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              color: Color(0xFFF3F6FC),
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            descripcion,
            style: const TextStyle(
              color: Color(0xFF9AA6B8),
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          contenido,
        ],
      ),
    );
  }

  Future<void> _guardarTelefono() async {
    if (!_telefonoFormKey.currentState!.validate()) return;
    final telefono = _telefonoController.text.trim();
    await _ejecutar(
      accion: () async {
        final guardarTelefono = widget.guardarTelefono;
        if (guardarTelefono == null) {
          await FirebaseFirestore.instance
              .collection('usuarios')
              .doc(widget.uid)
              .update({
                'telefono': telefono.isEmpty ? FieldValue.delete() : telefono,
              });
        } else {
          await guardarTelefono(widget.uid, telefono);
        }
      },
      mensajeExito: telefono.isEmpty
          ? 'Teléfono eliminado de tu perfil.'
          : 'Teléfono actualizado en tu perfil.',
    );
  }

  Future<void> _solicitarCambioCorreo() async {
    if (!_correoFormKey.currentState!.validate()) return;
    final correo = _nuevoCorreoController.text.trim();
    final contrasena = _passCorreoController.text;
    await _ejecutar(
      accion: () async {
        await _reautenticarUsuario(contrasena);
        final enviarCambioCorreo = widget.enviarCambioCorreo;
        if (enviarCambioCorreo == null) {
          final usuario = FirebaseAuth.instance.currentUser;
          if (usuario == null) {
            throw StateError('Tu sesión expiró. Inicia sesión nuevamente.');
          }
          await usuario.verifyBeforeUpdateEmail(correo);
        } else {
          await enviarCambioCorreo(correo);
        }
      },
      mensajeExito:
          'Enviamos un enlace a $correo. Ábrelo para confirmar el cambio.',
    );
  }

  Future<void> _cambiarContrasena() async {
    if (!_contrasenaFormKey.currentState!.validate()) return;
    final actual = _passActualController.text;
    final nueva = _passNuevaController.text;
    await _ejecutar(
      accion: () async {
        await _reautenticarUsuario(actual);
        final actualizarContrasena = widget.actualizarContrasena;
        if (actualizarContrasena == null) {
          final usuario = FirebaseAuth.instance.currentUser;
          if (usuario == null) {
            throw StateError('Tu sesión expiró. Inicia sesión nuevamente.');
          }
          await usuario.updatePassword(nueva);
        } else {
          await actualizarContrasena(nueva);
        }
      },
      mensajeExito: 'Contraseña actualizada correctamente.',
    );
    if (_error == null && mounted) {
      _passActualController.clear();
      _passNuevaController.clear();
    }
  }

  Future<void> _reautenticarUsuario(String contrasena) async {
    final reautenticar = widget.reautenticar;
    if (reautenticar != null) {
      await reautenticar(widget.correo, contrasena);
      return;
    }

    final usuario = FirebaseAuth.instance.currentUser;
    if (usuario == null || usuario.email == null) {
      throw StateError('Tu sesión expiró. Inicia sesión nuevamente.');
    }
    final usaContrasena = usuario.providerData.any(
      (provider) => provider.providerId == EmailAuthProvider.PROVIDER_ID,
    );
    if (!usaContrasena) {
      throw StateError(
        'Esta cuenta no usa contraseña de correo. '
        'Inicia sesión con tu proveedor para actualizar el perfil.',
      );
    }
    final credencial = EmailAuthProvider.credential(
      email: usuario.email!,
      password: contrasena,
    );
    await usuario.reauthenticateWithCredential(credencial);
  }

  Future<void> _ejecutar({
    required Future<void> Function() accion,
    required String mensajeExito,
  }) async {
    setState(() {
      _ocupado = true;
      _error = null;
      _mensaje = null;
    });
    try {
      await accion();
      if (mounted) {
        setState(() => _mensaje = mensajeExito);
        _mostrarFeedbackVisible();
      }
    } on FirebaseAuthException catch (error) {
      if (mounted) _mostrarError(error);
    } on FirebaseException catch (error) {
      if (mounted) _mostrarError(error);
    } on StateError catch (error) {
      if (mounted) _mostrarError(error);
    } catch (error) {
      if (mounted) _mostrarError(error);
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  void _mostrarError(Object error) {
    final mensaje = switch (error) {
      FirebaseAuthException authError => mensajeErrorAuth(authError),
      FirebaseException firebaseError =>
        'No se pudo guardar el cambio en Firebase. '
            '${firebaseError.message ?? firebaseError.code}',
      StateError stateError => stateError.message,
      _ => 'No se pudo completar el cambio. $error',
    };
    setState(() {
      _error = mensaje;
      _mensaje = null;
    });
    _mostrarFeedbackVisible();
  }

  void _mostrarFeedbackVisible() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      unawaited(
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        ),
      );
    });
  }
}
