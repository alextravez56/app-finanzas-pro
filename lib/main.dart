import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'models/movimiento.dart';
import 'models/pago.dart';
import 'models/sesion.dart';
import 'models/usuario.dart';
import 'screens/admin_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'screens/pagos_screen.dart';
import 'screens/perfil_screen.dart';
import 'screens/registro_screen.dart';
import 'utils/formatters.dart';

export 'models/movimiento.dart';
export 'models/pago.dart';
export 'models/sesion.dart';
export 'models/usuario.dart';
export 'screens/admin_screen.dart';
export 'screens/dashboard_screen.dart';
export 'screens/login_screen.dart';
export 'screens/pagos_screen.dart';
export 'screens/perfil_screen.dart';
export 'screens/registro_screen.dart';
export 'utils/formatters.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MiAppFinanzasPro());
}

class MiAppFinanzasPro extends StatelessWidget {
  const MiAppFinanzasPro({
    super.key,
    this.escucharSesion,
    this.escucharRol,
    this.escucharUsuarios,
    this.escucharMovimientosAdmin,
    this.iniciarSesion,
    this.registrarCuenta,
    this.recuperarContrasena,
    this.cerrarSesion,
    this.guardarMovimiento,
    this.eliminarMovimiento,
    this.actualizarMovimiento,
    this.escucharMovimientos,
    this.leerTelefonoPerfil,
    this.guardarTelefonoPerfil,
    this.reautenticarPerfil,
    this.enviarCambioCorreoPerfil,
    this.actualizarContrasenaPerfil,
    this.escucharPagos,
    this.registrarPago,
    this.confirmarPago,
    this.marcarPagoNoPagado,
    this.eliminarPago,
  });

  final Stream<AuthenticatedSession?> Function()? escucharSesion;
  final Stream<String?> Function(String uid)? escucharRol;
  final Stream<List<PerfilUsuario>> Function()? escucharUsuarios;
  final Stream<List<Movimiento>> Function(String uid)? escucharMovimientosAdmin;
  final Future<void> Function(String correo, String contrasena)? iniciarSesion;
  final Future<void> Function(
    String nombre,
    String correo,
    String telefono,
    String contrasena,
  )?
  registrarCuenta;
  final Future<void> Function(String correo)? recuperarContrasena;
  final Future<void> Function()? cerrarSesion;
  final Future<void> Function(String uid, Movimiento movimiento)?
  guardarMovimiento;
  final Future<void> Function(String uid, Movimiento movimiento)?
  eliminarMovimiento;
  final Future<void> Function(String uid, Movimiento movimiento)?
  actualizarMovimiento;
  final Stream<List<Movimiento>> Function(String uid)? escucharMovimientos;
  final Future<String?> Function(String uid)? leerTelefonoPerfil;
  final Future<void> Function(String uid, String telefono)?
  guardarTelefonoPerfil;
  final Future<void> Function(String correo, String contrasena)?
  reautenticarPerfil;
  final Future<void> Function(String correo)? enviarCambioCorreoPerfil;
  final Future<void> Function(String contrasena)? actualizarContrasenaPerfil;
  final Stream<List<Pago>> Function(String uid)? escucharPagos;
  final Future<void> Function(String uid, Pago pago)? registrarPago;
  final Future<void> Function(
    String uid,
    String pagoId,
    double montoPagado,
    DateTime fechaPago,
  )?
  confirmarPago;
  final Future<void> Function(String uid, String pagoId)? marcarPagoNoPagado;
  final Future<void> Function(String uid, String pagoId)? eliminarPago;

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFF0C111B);

    return MaterialApp(
      title: 'Control Financiero Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF55D6A0),
          brightness: Brightness.dark,
          surface: const Color(0xFF151D2B),
        ),
        fontFamily: 'Segoe UI',
        useMaterial3: true,
      ),
      home: _AuthenticationGate(
        escucharSesion: escucharSesion,
        escucharRol: escucharRol,
        escucharUsuarios: escucharUsuarios,
        escucharMovimientosAdmin: escucharMovimientosAdmin,
        iniciarSesion: iniciarSesion,
        registrarCuenta: registrarCuenta,
        recuperarContrasena: recuperarContrasena,
        cerrarSesion: cerrarSesion,
        guardarMovimiento: guardarMovimiento,
        eliminarMovimiento: eliminarMovimiento,
        actualizarMovimiento: actualizarMovimiento,
        escucharMovimientos: escucharMovimientos,
        leerTelefonoPerfil: leerTelefonoPerfil,
        guardarTelefonoPerfil: guardarTelefonoPerfil,
        reautenticarPerfil: reautenticarPerfil,
        enviarCambioCorreoPerfil: enviarCambioCorreoPerfil,
        actualizarContrasenaPerfil: actualizarContrasenaPerfil,
        escucharPagos: escucharPagos,
        registrarPago: registrarPago,
        confirmarPago: confirmarPago,
        marcarPagoNoPagado: marcarPagoNoPagado,
        eliminarPago: eliminarPago,
      ),
    );
  }
}

class _AuthenticationGate extends StatefulWidget {
  const _AuthenticationGate({
    required this.escucharSesion,
    required this.escucharRol,
    required this.escucharUsuarios,
    required this.escucharMovimientosAdmin,
    required this.iniciarSesion,
    required this.registrarCuenta,
    required this.recuperarContrasena,
    required this.cerrarSesion,
    required this.guardarMovimiento,
    this.eliminarMovimiento,
    this.actualizarMovimiento,
    required this.escucharMovimientos,
    required this.leerTelefonoPerfil,
    required this.guardarTelefonoPerfil,
    required this.reautenticarPerfil,
    required this.enviarCambioCorreoPerfil,
    required this.actualizarContrasenaPerfil,
    required this.escucharPagos,
    required this.registrarPago,
    required this.confirmarPago,
    required this.marcarPagoNoPagado,
    this.eliminarPago,
  });

  final Stream<AuthenticatedSession?> Function()? escucharSesion;
  final Stream<String?> Function(String uid)? escucharRol;
  final Stream<List<PerfilUsuario>> Function()? escucharUsuarios;
  final Stream<List<Movimiento>> Function(String uid)? escucharMovimientosAdmin;
  final Future<void> Function(String correo, String contrasena)? iniciarSesion;
  final Future<void> Function(
    String nombre,
    String correo,
    String telefono,
    String contrasena,
  )?
  registrarCuenta;
  final Future<void> Function(String correo)? recuperarContrasena;
  final Future<void> Function()? cerrarSesion;
  final Future<void> Function(String uid, Movimiento movimiento)?
  guardarMovimiento;
  final Future<void> Function(String uid, Movimiento movimiento)?
  eliminarMovimiento;
  final Future<void> Function(String uid, Movimiento movimiento)?
  actualizarMovimiento;
  final Stream<List<Movimiento>> Function(String uid)? escucharMovimientos;
  final Future<String?> Function(String uid)? leerTelefonoPerfil;
  final Future<void> Function(String uid, String telefono)?
  guardarTelefonoPerfil;
  final Future<void> Function(String correo, String contrasena)?
  reautenticarPerfil;
  final Future<void> Function(String correo)? enviarCambioCorreoPerfil;
  final Future<void> Function(String contrasena)? actualizarContrasenaPerfil;
  final Stream<List<Pago>> Function(String uid)? escucharPagos;
  final Future<void> Function(String uid, Pago pago)? registrarPago;
  final Future<void> Function(
    String uid,
    String pagoId,
    double montoPagado,
    DateTime fechaPago,
  )?
  confirmarPago;
  final Future<void> Function(String uid, String pagoId)? marcarPagoNoPagado;
  final Future<void> Function(String uid, String pagoId)? eliminarPago;

  @override
  State<_AuthenticationGate> createState() => _AuthenticationGateState();
}

class _AuthenticationGateState extends State<_AuthenticationGate> {
  late final Stream<AuthenticatedSession?> _sesionStream;

  @override
  void initState() {
    super.initState();
    _sesionStream =
        widget.escucharSesion?.call() ??
        FirebaseAuth.instance.authStateChanges().map(
          (user) => user == null
              ? null
              : AuthenticatedSession(uid: user.uid, correo: user.email ?? ''),
        );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthenticatedSession?>(
      stream: _sesionStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _ErrorAutenticacion(error: snapshot.error!);
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _CargandoAutenticacion();
        }

        final sesion = snapshot.data;
        if (sesion == null) {
          return PantallaLogin(
            iniciarSesion: widget.iniciarSesion,
            registrarCuenta: widget.registrarCuenta,
            recuperarContrasena: widget.recuperarContrasena,
          );
        }

        final escucharRol = widget.escucharRol;
        final rolStream = escucharRol == null
            ? FirebaseFirestore.instance
                  .collection('usuarios')
                  .doc(sesion.uid)
                  .snapshots()
                  .map((documento) => documento.data()?['rol'] as String?)
            : escucharRol(sesion.uid);

        return StreamBuilder<String?>(
          key: ValueKey(sesion.uid),
          stream: rolStream,
          builder: (context, roleSnapshot) {
            if (roleSnapshot.hasError) {
              return _ErrorAutenticacion(error: roleSnapshot.error!);
            }
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const _CargandoAutenticacion();
            }

            if (roleSnapshot.data == 'admin') {
              return PantallaAdmin(
                sesion: sesion,
                cerrarSesion: widget.cerrarSesion,
                escucharUsuarios: widget.escucharUsuarios,
                escucharMovimientosAdmin: widget.escucharMovimientosAdmin,
              );
            }

            return DashboardFinanzas(
              sesion: sesion,
              cerrarSesion: widget.cerrarSesion,
              guardarMovimiento: widget.guardarMovimiento,
              eliminarMovimiento: widget.eliminarMovimiento,
              actualizarMovimiento: widget.actualizarMovimiento,
              escucharMovimientos: widget.escucharMovimientos,
              leerTelefonoPerfil: widget.leerTelefonoPerfil,
              guardarTelefonoPerfil: widget.guardarTelefonoPerfil,
              reautenticarPerfil: widget.reautenticarPerfil,
              enviarCambioCorreoPerfil: widget.enviarCambioCorreoPerfil,
              actualizarContrasenaPerfil: widget.actualizarContrasenaPerfil,
              escucharPagos: widget.escucharPagos,
              registrarPago: widget.registrarPago,
              confirmarPago: widget.confirmarPago,
              marcarPagoNoPagado: widget.marcarPagoNoPagado,
              eliminarPago: widget.eliminarPago,
            );
          },
        );
      },
    );
  }
}

class _CargandoAutenticacion extends StatelessWidget {
  const _CargandoAutenticacion();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0C111B),
      body: Center(child: CircularProgressIndicator(color: Color(0xFF55D6A0))),
    );
  }
}

class _ErrorAutenticacion extends StatelessWidget {
  const _ErrorAutenticacion({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C111B),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'No se pudo comprobar la sesión. Reinicia la aplicación.\n$error',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFFFF8798)),
          ),
        ),
      ),
    );
  }
}
