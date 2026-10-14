import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../utils/formatters.dart';
import 'registro_screen.dart';

class PantallaLogin extends StatefulWidget {
  const PantallaLogin({
    super.key,
    this.iniciarSesion,
    this.registrarCuenta,
    this.recuperarContrasena,
  });

  final Future<void> Function(String correo, String contrasena)? iniciarSesion;
  final Future<void> Function(
    String nombre,
    String correo,
    String telefono,
    String contrasena,
  )?
  registrarCuenta;
  final Future<void> Function(String correo)? recuperarContrasena;

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin> {
  final _formKey = GlobalKey<FormState>();
  final _correoController = TextEditingController();
  final _contrasenaController = TextEditingController();
  bool _mostrarContrasena = false;
  bool _ocupado = false;
  String? _error;
  String? _mensaje;

  @override
  void dispose() {
    _correoController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C111B),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: const Color(0xFF151D2B),
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.07),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.22),
                      blurRadius: 36,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        width: 62,
                        height: 62,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFF55D6A0)
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(19),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          color: Color(0xFF55D6A0),
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 25),
                      Text(
                        'Bienvenido de nuevo',
                        style: const TextStyle(
                          color: Color(0xFFF3F6FC),
                          fontSize: 27,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.6,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Inicia sesión para ver tus finanzas.',
                        style: const TextStyle(
                          color: Color(0xFF9AA6B8),
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 28),
                      const EtiquetaAcceso('Correo electrónico'),
                      const SizedBox(height: 8),
                      TextFormField(
                        key: const Key('auth_email'),
                        controller: _correoController,
                        enabled: !_ocupado,
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
                          if (correo.isEmpty ||
                              !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                  .hasMatch(correo)) {
                            return 'Ingresa un correo electrónico válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      const EtiquetaAcceso('Contraseña'),
                      const SizedBox(height: 8),
                      TextFormField(
                        key: const Key('auth_password'),
                        controller: _contrasenaController,
                        enabled: !_ocupado,
                        obscureText: !_mostrarContrasena,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        onFieldSubmitted: (_) {
                          if (!_ocupado) _enviarFormulario();
                        },
                        style: const TextStyle(color: Color(0xFFF3F6FC)),
                        decoration: decoracionAcceso(
                          hint: 'Mínimo 6 caracteres',
                          icon: Icons.lock_outline_rounded,
                          suffix: IconButton(
                            tooltip: _mostrarContrasena
                                ? 'Ocultar contraseña'
                                : 'Mostrar contraseña',
                            onPressed: _ocupado
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
                          final contrasena = value ?? '';
                          if (contrasena.length < 6) {
                            return 'La contraseña debe tener al menos 6 caracteres';
                          }
                          return null;
                        },
                      ),
                      if (_error != null || _mensaje != null) ...[
                        const SizedBox(height: 18),
                        mensajeAcceso(
                          _error ?? _mensaje!,
                          esError: _error != null,
                        ),
                      ],
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 52,
                        child: FilledButton(
                          key: const Key('auth_submit'),
                          onPressed: _ocupado ? null : _enviarFormulario,
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
                          child: _ocupado
                              ? const SizedBox(
                                  width: 21,
                                  height: 21,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF0C111B),
                                  ),
                                )
                              : const Text('Iniciar sesión'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _ocupado
                            ? null
                            : () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => PantallaRecuperarPassword(
                                      initialEmail: _correoController.text
                                          .trim(),
                                      recuperarContrasena:
                                          widget.recuperarContrasena,
                                    ),
                                  ),
                                );
                              },
                        child: const Text(
                          '¿Olvidaste tu contraseña?',
                          style: TextStyle(color: Color(0xFF9DDDC1)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _ocupado
                            ? null
                            : () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => PantallaRegistro(
                                      registrarCuenta: widget.registrarCuenta,
                                    ),
                                  ),
                                );
                              },
                        child: Text(
                          '¿Eres nuevo? Crea una cuenta',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFFB9C3D2),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tus datos se sincronizan de forma privada con tu cuenta.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF69768A),
                          fontSize: 11,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'Para cualquier información, contacto por:\n'
                        'Teléfono: 0995220518\n'
                        'Correo: alextravez29@gmail.com',
                        key: Key('login_contact_information'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                          height: 1.5,
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

  Future<void> _enviarFormulario() async {
    if (_ocupado || !_formKey.currentState!.validate()) return;

    setState(() {
      _ocupado = true;
      _error = null;
      _mensaje = null;
    });

    try {
      final correo = _correoController.text.trim();
      final contrasena = _contrasenaController.text;
      final iniciarSesion = widget.iniciarSesion;
      if (iniciarSesion == null) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: correo,
          password: contrasena,
        );
      } else {
        await iniciarSesion(correo, contrasena);
      }
    } on FirebaseAuthException catch (error) {
      if (mounted) setState(() => _error = mensajeErrorAuth(error));
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }
}

class PantallaRecuperarPassword extends StatefulWidget {
  const PantallaRecuperarPassword({
    super.key,
    this.initialEmail = '',
    this.recuperarContrasena,
  });

  final String initialEmail;
  final Future<void> Function(String correo)? recuperarContrasena;

  @override
  State<PantallaRecuperarPassword> createState() =>
      _PantallaRecuperarPasswordState();
}

class _PantallaRecuperarPasswordState extends State<PantallaRecuperarPassword> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _correoController;
  bool _enviando = false;
  String? _error;
  String? _mensaje;

  @override
  void initState() {
    super.initState();
    _correoController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _correoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C111B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          key: const Key('recovery_back'),
          tooltip: 'Volver al inicio de sesión',
          onPressed: _enviando ? null : () => Navigator.of(context).pop(),
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
                          Icons.mark_email_read_outlined,
                          color: Color(0xFF55D6A0),
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Recuperar contraseña',
                        style: TextStyle(
                          color: Color(0xFFF3F6FC),
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Ingresa tu correo y, si existe una cuenta asociada, '
                        'te enviaremos un enlace seguro para cambiar tu '
                        'contraseña.',
                        style: TextStyle(
                          color: Color(0xFF9AA6B8),
                          fontSize: 14,
                          height: 1.55,
                        ),
                      ),
                      const SizedBox(height: 28),
                      const EtiquetaAcceso('Correo electrónico'),
                      const SizedBox(height: 8),
                      TextFormField(
                        key: const Key('recovery_email'),
                        controller: _correoController,
                        enabled: !_enviando,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
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
                        onFieldSubmitted: (_) {
                          if (!_enviando) _enviarEnlace();
                        },
                      ),
                      if (_error != null || _mensaje != null) ...[
                        const SizedBox(height: 18),
                        mensajeAcceso(
                          _error ?? _mensaje!,
                          esError: _error != null,
                        ),
                      ],
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 52,
                        child: FilledButton(
                          key: const Key('recovery_submit'),
                          onPressed: _enviando ? null : _enviarEnlace,
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
                          child: _enviando
                              ? const SizedBox(
                                  width: 21,
                                  height: 21,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF0C111B),
                                  ),
                                )
                              : const Text('Enviar enlace'),
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

  Future<void> _enviarEnlace() async {
    if (_enviando || !_formKey.currentState!.validate()) return;
    final correo = _correoController.text.trim();
    setState(() {
      _enviando = true;
      _error = null;
      _mensaje = null;
    });

    try {
      final recuperarContrasena = widget.recuperarContrasena;
      if (recuperarContrasena == null) {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: correo);
      } else {
        await recuperarContrasena(correo);
      }
      if (mounted) {
        setState(() {
          _mensaje =
              'Si existe una cuenta asociada a este correo, recibirás '
              'un enlace para restablecer tu contraseña.';
        });
      }
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      if (error.code == 'user-not-found') {
        setState(() {
          _mensaje =
              'Si existe una cuenta asociada a este correo, recibirás '
              'un enlace para restablecer tu contraseña.';
        });
      } else {
        setState(() => _error = mensajeErrorAuth(error));
      }
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }
}
