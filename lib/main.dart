import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;

import 'firebase_options.dart';

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
      ),
    );
  }
}

class AuthenticatedSession {
  const AuthenticatedSession({required this.uid, required this.correo});

  final String uid;
  final String correo;
}

class PerfilUsuario {
  const PerfilUsuario({
    required this.uid,
    required this.username,
    required this.email,
    required this.telefono,
    required this.fechaRegistro,
  });

  final String uid;
  final String username;
  final String email;
  final String telefono;
  final DateTime? fechaRegistro;
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

class PantallaAdmin extends StatefulWidget {
  const PantallaAdmin({
    super.key,
    required this.sesion,
    this.cerrarSesion,
    this.escucharUsuarios,
    this.escucharMovimientosAdmin,
  });

  final AuthenticatedSession sesion;
  final Future<void> Function()? cerrarSesion;
  final Stream<List<PerfilUsuario>> Function()? escucharUsuarios;
  final Stream<List<Movimiento>> Function(String uid)? escucharMovimientosAdmin;

  @override
  State<PantallaAdmin> createState() => _PantallaAdminState();
}

class _PantallaAdminState extends State<PantallaAdmin> {
  final _busquedaController = TextEditingController();
  late final Stream<List<PerfilUsuario>> _usuariosStream;
  String _busqueda = '';

  @override
  void initState() {
    super.initState();
    final escucharUsuarios = widget.escucharUsuarios;
    _usuariosStream = escucharUsuarios == null
        ? FirebaseFirestore.instance
              .collection('usuarios')
              .snapshots()
              .map(_perfilesDesdeSnapshot)
        : escucharUsuarios();
    _busquedaController.addListener(_actualizarBusqueda);
  }

  @override
  void dispose() {
    _busquedaController
      ..removeListener(_actualizarBusqueda)
      ..dispose();
    super.dispose();
  }

  void _actualizarBusqueda() {
    setState(() => _busqueda = _busquedaController.text.trim().toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C111B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF101722),
        title: const Text(
          'Panel de administración',
          style: TextStyle(
            color: Color(0xFFF3F6FC),
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              key: const Key('admin_sign_out'),
              tooltip: 'Cerrar sesión',
              onPressed: _cerrarSesion,
              icon: const Icon(Icons.logout_rounded),
              color: const Color(0xFF9DDDC1),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: StreamBuilder<List<PerfilUsuario>>(
                stream: _usuariosStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return _estadoAdmin(
                      icon: Icons.cloud_off_outlined,
                      texto:
                          'No se pudieron cargar las cuentas. '
                          '${snapshot.error}',
                      error: true,
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF55D6A0),
                      ),
                    );
                  }

                  final usuarios = snapshot.data ?? const <PerfilUsuario>[];
                  final usuariosFiltrados = usuarios
                      .where(
                        (usuario) =>
                            _busqueda.isEmpty ||
                            usuario.username.toLowerCase().contains(
                              _busqueda,
                            ) ||
                            usuario.email.toLowerCase().contains(_busqueda),
                      )
                      .toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _resumenAdmin(usuarios.length),
                      const SizedBox(height: 22),
                      TextField(
                        key: const Key('admin_search'),
                        controller: _busquedaController,
                        style: const TextStyle(color: Color(0xFFF3F6FC)),
                        decoration: InputDecoration(
                          hintText: 'Buscar por nombre o correo',
                          hintStyle: const TextStyle(color: Color(0xFF69768A)),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: Color(0xFF8792A5),
                          ),
                          suffixIcon: _busqueda.isEmpty
                              ? null
                              : IconButton(
                                  tooltip: 'Limpiar búsqueda',
                                  onPressed: _busquedaController.clear,
                                  icon: const Icon(Icons.close_rounded),
                                ),
                          filled: true,
                          fillColor: const Color(0xFF151D2B),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: usuariosFiltrados.isEmpty
                            ? _estadoAdmin(
                                icon: usuarios.isEmpty
                                    ? Icons.people_outline_rounded
                                    : Icons.search_off_rounded,
                                texto: usuarios.isEmpty
                                    ? 'Todavía no hay cuentas registradas.'
                                    : 'No hay cuentas que coincidan con la búsqueda.',
                              )
                            : ListView.separated(
                                key: const Key('admin_user_list'),
                                itemCount: usuariosFiltrados.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (context, index) =>
                                    _tarjetaUsuario(usuariosFiltrados[index]),
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _resumenAdmin(int cantidadUsuarios) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A3440), Color(0xFF172535)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF55D6A0).withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.admin_panel_settings_outlined,
              color: Color(0xFF55D6A0),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cuentas registradas',
                  style: TextStyle(color: Color(0xFF9AA6B8), fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  '$cantidadUsuarios',
                  key: const Key('admin_user_count'),
                  style: const TextStyle(
                    color: Color(0xFFF3F6FC),
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (widget.sesion.correo.isNotEmpty)
            Flexible(
              child: Text(
                widget.sesion.correo,
                key: const Key('admin_signed_in_email'),
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFFB9C3D2), fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _tarjetaUsuario(PerfilUsuario usuario) {
    final fecha = usuario.fechaRegistro;
    final fechaTexto = fecha == null
        ? 'Fecha de registro no disponible'
        : 'Registrado ${_fechaHoraAdmin(fecha)}';
    final inicial = usuario.username.isNotEmpty
        ? String.fromCharCode(usuario.username.runes.first).toUpperCase()
        : '?';

    return Tooltip(
      message: 'Abrir movimientos e información personal',
      child: Material(
        color: const Color(0xFF151D2B),
        borderRadius: BorderRadius.circular(17),
        child: InkWell(
          key: ValueKey('admin_user_${usuario.uid}'),
          borderRadius: BorderRadius.circular(17),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => PantallaDetalleUsuarioAdmin(
                usuario: usuario,
                escucharMovimientos: widget.escucharMovimientosAdmin,
              ),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: Colors.white.withValues(alpha: 0.055)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 23,
                  backgroundColor: const Color(0xFF55D6A0)
                      .withValues(alpha: 0.12),
                  child: Text(
                    inicial,
                    style: const TextStyle(
                      color: Color(0xFF55D6A0),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        usuario.username,
                        style: const TextStyle(
                          color: Color(0xFFF3F6FC),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        usuario.email,
                        style: const TextStyle(
                          color: Color(0xFF9AA6B8),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        fechaTexto,
                        key: Key('admin_user_date_${usuario.uid}'),
                        style: const TextStyle(
                          color: Color(0xFF55D6A0),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _uidCorto(usuario.uid),
                  key: Key('admin_user_short_uid_${usuario.uid}'),
                  style: const TextStyle(
                    color: Color(0xFF69768A),
                    fontSize: 10,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF8792A5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _estadoAdmin({
    required IconData icon,
    required String texto,
    bool error = false,
  }) {
    final color = error ? const Color(0xFFFF8798) : const Color(0xFF9AA6B8);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 34),
            const SizedBox(height: 12),
            Text(
              texto,
              key: error ? const Key('admin_error') : null,
              textAlign: TextAlign.center,
              style: TextStyle(color: color, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _cerrarSesion() async {
    try {
      final cerrarSesion = widget.cerrarSesion;
      if (cerrarSesion == null) {
        await FirebaseAuth.instance.signOut();
      } else {
        await cerrarSesion();
      }
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(_mensajeErrorAuth(error))));
      }
    }
  }
}

List<PerfilUsuario> _perfilesDesdeSnapshot(
  QuerySnapshot<Map<String, dynamic>> snapshot,
) {
  final perfiles = snapshot.docs.map((documento) {
    final datos = documento.data();
    final registro = datos['fecha_registro'];
    return PerfilUsuario(
      uid: documento.id,
      username: datos['username'] is String ? datos['username'] as String : '',
      email: datos['email'] is String ? datos['email'] as String : '',
      telefono: datos['telefono'] is String ? datos['telefono'] as String : '',
      fechaRegistro: registro is Timestamp ? registro.toDate() : null,
    );
  }).toList();

  perfiles.sort((a, b) {
    final fechaA = a.fechaRegistro;
    final fechaB = b.fechaRegistro;
    if (fechaA == null) return fechaB == null ? 0 : 1;
    if (fechaB == null) return -1;
    return fechaB.compareTo(fechaA);
  });
  return perfiles;
}

String _uidCorto(String uid) {
  if (uid.length <= 12) return uid;
  return '${uid.substring(0, 6)}…${uid.substring(uid.length - 4)}';
}

String _fechaHoraAdmin(DateTime fecha) {
  final local = fecha.toLocal();
  final dia = local.day.toString().padLeft(2, '0');
  final mes = local.month.toString().padLeft(2, '0');
  final hora = local.hour.toString().padLeft(2, '0');
  final minuto = local.minute.toString().padLeft(2, '0');
  return '$dia/$mes/${local.year} · $hora:$minuto';
}

class PantallaDetalleUsuarioAdmin extends StatefulWidget {
  const PantallaDetalleUsuarioAdmin({
    super.key,
    required this.usuario,
    this.escucharMovimientos,
  });

  final PerfilUsuario usuario;
  final Stream<List<Movimiento>> Function(String uid)? escucharMovimientos;

  @override
  State<PantallaDetalleUsuarioAdmin> createState() =>
      _PantallaDetalleUsuarioAdminState();
}

class _PantallaDetalleUsuarioAdminState
    extends State<PantallaDetalleUsuarioAdmin> {
  late final Stream<List<Movimiento>> _movimientosStream;

  @override
  void initState() {
    super.initState();
    final escuchar = widget.escucharMovimientos;
    _movimientosStream = escuchar == null
        ? FirebaseFirestore.instance
              .collection('usuarios')
              .doc(widget.usuario.uid)
              .collection('movimientos')
              .snapshots()
              .map(
                (snapshot) => snapshot.docs
                    .map(
                      (documento) =>
                          _movimientoDesdeDatos(documento.id, documento.data()),
                    )
                    .toList(),
              )
        : escuchar(widget.usuario.uid);
  }

  @override
  Widget build(BuildContext context) {
    final usuario = widget.usuario;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF0C111B),
        appBar: AppBar(
          backgroundColor: const Color(0xFF101722),
          title: Text(
            usuario.username.isEmpty ? 'Perfil del usuario' : usuario.username,
            style: const TextStyle(
              color: Color(0xFFF3F6FC),
              fontWeight: FontWeight.w700,
            ),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(
                key: Key('admin_user_movements_tab'),
                icon: Icon(Icons.receipt_long_outlined),
                text: 'Movimientos realizados',
              ),
              Tab(
                key: Key('admin_user_information_tab'),
                icon: Icon(Icons.person_outline_rounded),
                text: 'Información personal',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [_pestanaMovimientos(), _pestanaInformacion(usuario)],
        ),
      ),
    );
  }

  Widget _pestanaMovimientos() {
    return StreamBuilder<List<Movimiento>>(
      stream: _movimientosStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _estadoDetalle(
            icon: Icons.cloud_off_outlined,
            texto: 'No se pudieron cargar los movimientos: ${snapshot.error}',
            error: true,
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF55D6A0)),
          );
        }

        final movimientos = List<Movimiento>.of(
          snapshot.data ?? const <Movimiento>[],
        )..sort((a, b) => b.fecha.compareTo(a.fecha));
        if (movimientos.isEmpty) {
          return _estadoDetalle(
            icon: Icons.receipt_long_outlined,
            texto: 'Este usuario todavía no ha registrado movimientos.',
          );
        }

        var ingresos = 0.0;
        var gastos = 0.0;
        var ahorro = 0.0;
        var inversion = 0.0;
        for (final movimiento in movimientos) {
          switch (movimiento.categoria) {
            case CategoriaMovimiento.ingresos:
              ingresos += movimiento.monto;
            case CategoriaMovimiento.gastos:
              gastos += movimiento.monto;
            case CategoriaMovimiento.ahorro:
              ahorro += movimiento.monto;
            case CategoriaMovimiento.inversion:
              inversion += movimiento.monto;
          }
        }

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Resumen calculado · ${movimientos.length} '
              '${movimientos.length == 1 ? 'movimiento' : 'movimientos'}',
              key: const Key('admin_user_movement_summary'),
              style: const TextStyle(
                color: Color(0xFFF3F6FC),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _datoResumenMovimiento('Ingresos', ingresos),
                _datoResumenMovimiento('Gastos', gastos),
                _datoResumenMovimiento('Ahorro', ahorro),
                _datoResumenMovimiento('Inversión', inversion),
                _datoResumenMovimiento(
                  'Balance disponible',
                  ingresos - gastos - ahorro - inversion,
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Historial',
              style: TextStyle(
                color: Color(0xFFF3F6FC),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            for (final movimiento in movimientos)
              _tarjetaMovimiento(movimiento),
          ],
        );
      },
    );
  }

  Widget _datoResumenMovimiento(String titulo, double monto) {
    return Container(
      key: Key('admin_user_total_${titulo.toLowerCase().replaceAll(' ', '_')}'),
      width: 165,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF151D2B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.055)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(color: Color(0xFF9AA6B8), fontSize: 11),
          ),
          const SizedBox(height: 7),
          Text(
            _formatearMoneda(monto),
            style: const TextStyle(
              color: Color(0xFFF3F6FC),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tarjetaMovimiento(Movimiento movimiento) {
    final detalle = _detalleCategoria(movimiento.categoria);
    return Container(
      key: Key(
        'admin_movement_${movimiento.fecha.microsecondsSinceEpoch}_'
        '${movimiento.categoria.name}',
      ),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF151D2B),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.055)),
      ),
      child: Row(
        children: [
          Icon(detalle.icono, color: detalle.color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movimiento.descripcion.isEmpty
                      ? detalle.titulo
                      : movimiento.descripcion,
                  style: const TextStyle(
                    color: Color(0xFFF3F6FC),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${detalle.titulo} · ${_fechaHoraAdmin(movimiento.fecha)}',
                  style: const TextStyle(
                    color: Color(0xFF9AA6B8),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatearMoneda(movimiento.monto),
            style: TextStyle(color: detalle.color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _pestanaInformacion(PerfilUsuario usuario) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _filaInformacion('Nombre de usuario', usuario.username),
        _filaInformacion('Correo electrónico', usuario.email),
        _filaInformacion(
          'Teléfono',
          usuario.telefono.isEmpty ? 'No registrado' : usuario.telefono,
        ),
        _filaInformacion(
          'Fecha de registro',
          usuario.fechaRegistro == null
              ? 'No disponible'
              : _fechaHoraAdmin(usuario.fechaRegistro!),
        ),
        _filaInformacion(
          'ID de usuario',
          _uidCorto(usuario.uid),
          key: const Key('admin_user_detail_short_uid'),
          tooltip: 'Identificador abreviado por privacidad visual',
        ),
      ],
    );
  }

  Widget _filaInformacion(
    String titulo,
    String valor, {
    Key? key,
    String? tooltip,
  }) {
    final fila = Container(
      key: key,
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151D2B),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.055)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(color: Color(0xFF9AA6B8), fontSize: 12),
          ),
          const SizedBox(height: 6),
          SelectableText(
            valor.isEmpty ? 'No disponible' : valor,
            style: const TextStyle(
              color: Color(0xFFF3F6FC),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
    return tooltip == null ? fila : Tooltip(message: tooltip, child: fila);
  }

  Widget _estadoDetalle({
    required IconData icon,
    required String texto,
    bool error = false,
  }) {
    final color = error ? const Color(0xFFFF8798) : const Color(0xFF9AA6B8);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 38),
            const SizedBox(height: 12),
            Text(
              texto,
              key: error ? const Key('admin_user_movements_error') : null,
              textAlign: TextAlign.center,
              style: TextStyle(color: color, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

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
                      const _EtiquetaAcceso('Correo electrónico'),
                      const SizedBox(height: 8),
                      TextFormField(
                        key: const Key('auth_email'),
                        controller: _correoController,
                        enabled: !_ocupado,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        style: const TextStyle(color: Color(0xFFF3F6FC)),
                        decoration: _decoracionAcceso(
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
                      const _EtiquetaAcceso('Contraseña'),
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
                        decoration: _decoracionAcceso(
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
                        _mensajeAcceso(
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
      if (mounted) setState(() => _error = _mensajeErrorAuth(error));
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }
}

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
                      const _EtiquetaAcceso('Nombre de usuario'),
                      const SizedBox(height: 8),
                      TextFormField(
                        key: const Key('registration_username'),
                        controller: _nombreController,
                        enabled: !_registrando,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.nickname],
                        style: const TextStyle(color: Color(0xFFF3F6FC)),
                        decoration: _decoracionAcceso(
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
                      const _EtiquetaAcceso('Correo electrónico'),
                      const SizedBox(height: 8),
                      TextFormField(
                        key: const Key('registration_email'),
                        controller: _correoController,
                        enabled: !_registrando,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        style: const TextStyle(color: Color(0xFFF3F6FC)),
                        decoration: _decoracionAcceso(
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
                      const _EtiquetaAcceso('Teléfono (opcional)'),
                      const SizedBox(height: 8),
                      TextFormField(
                        key: const Key('registration_phone'),
                        controller: _telefonoController,
                        enabled: !_registrando,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.telephoneNumber],
                        style: const TextStyle(color: Color(0xFFF3F6FC)),
                        decoration: _decoracionAcceso(
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
                      const _EtiquetaAcceso('Contraseña'),
                      const SizedBox(height: 8),
                      TextFormField(
                        key: const Key('registration_password'),
                        controller: _contrasenaController,
                        enabled: !_registrando,
                        obscureText: !_mostrarContrasena,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.newPassword],
                        style: const TextStyle(color: Color(0xFFF3F6FC)),
                        decoration: _decoracionAcceso(
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
                      const _EtiquetaAcceso('Confirma tu contraseña'),
                      const SizedBox(height: 8),
                      TextFormField(
                        key: const Key('registration_confirmation'),
                        controller: _confirmacionController,
                        enabled: !_registrando,
                        obscureText: !_mostrarContrasena,
                        textInputAction: TextInputAction.done,
                        style: const TextStyle(color: Color(0xFFF3F6FC)),
                        decoration: _decoracionAcceso(
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
                        _mensajeAcceso(_error!, esError: true),
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
      if (mounted) setState(() => _error = _mensajeErrorAuth(error));
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
                      const _EtiquetaAcceso('Correo electrónico'),
                      const SizedBox(height: 8),
                      TextFormField(
                        key: const Key('recovery_email'),
                        controller: _correoController,
                        enabled: !_enviando,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.email],
                        style: const TextStyle(color: Color(0xFFF3F6FC)),
                        decoration: _decoracionAcceso(
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
                        _mensajeAcceso(
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
        setState(() => _error = _mensajeErrorAuth(error));
      }
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }
}

class _EtiquetaAcceso extends StatelessWidget {
  const _EtiquetaAcceso(this.texto);

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

InputDecoration _decoracionAcceso({
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

Widget _mensajeAcceso(String mensaje, {required bool esError}) {
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

String _mensajeErrorAuth(FirebaseAuthException error) {
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
    'requires-recent-login' => 'Vuelve a iniciar sesión y repite la operación para confirmar tu identidad.',
    'credential-already-in-use' => 'Ese correo ya está asociado a otra cuenta.',
    _ =>
      'No se pudo completar la operación de acceso. '
          '${error.message ?? error.code}',
  };
}

enum CategoriaMovimiento { ingresos, gastos, ahorro, inversion }

class Movimiento {
  const Movimiento({
    required this.categoria,
    required this.monto,
    required this.descripcion,
    required this.fecha,
  });

  final CategoriaMovimiento categoria;
  final double monto;
  final String descripcion;
  final DateTime fecha;
}

class Pago {
  const Pago({
    required this.id,
    required this.titulo,
    required this.monto,
    required this.fechaLimite,
    required this.estado,
    required this.montoPagado,
  });

  final String id;
  final String titulo;
  final double monto;
  final DateTime fechaLimite;
  final String estado;
  final double montoPagado;

  double get saldoPendiente => (monto - montoPagado).clamp(0, monto).toDouble();
}

class DashboardFinanzas extends StatefulWidget {
  const DashboardFinanzas({
    super.key,
    required this.sesion,
    this.cerrarSesion,
    this.guardarMovimiento,
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
  });

  final AuthenticatedSession sesion;
  final Future<void> Function()? cerrarSesion;
  final Future<void> Function(String uid, Movimiento movimiento)?
  guardarMovimiento;
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

  @override
  State<DashboardFinanzas> createState() => _DashboardFinanzasState();
}

class _DashboardFinanzasState extends State<DashboardFinanzas> {
  double salario = 0;
  double gastado = 0;
  double ahorrado = 0;
  double invertido = 0;
  List<Movimiento> _movimientos = [];
  StreamSubscription<List<Movimiento>>? _movimientosSubscription;
  bool _cargandoMovimientos = true;
  String? _errorMovimientos;
  late final Stream<List<Pago>> _pagosStream;
  final Set<String> _alertasMostradas = <String>{};

  double get _sobrante => salario - gastado - ahorrado - invertido;

  @override
  void initState() {
    super.initState();
    final escucharPagos = widget.escucharPagos;
    _pagosStream = escucharPagos == null
        ? _streamPagosUsuario(widget.sesion.uid)
        : escucharPagos(widget.sesion.uid);
    _escucharMovimientosFirebase();
  }

  @override
  void dispose() {
    _movimientosSubscription?.cancel();
    super.dispose();
  }

  void _escucharMovimientosFirebase() {
    final escuchar = widget.escucharMovimientos;
    final stream = escuchar == null
        ? FirebaseFirestore.instance
              .collection('usuarios')
              .doc(widget.sesion.uid)
              .collection('movimientos')
              .snapshots()
              .map(
                (snapshot) => snapshot.docs
                    .map(
                      (document) =>
                          _movimientoDesdeDatos(document.id, document.data()),
                    )
                    .toList(),
              )
        : escuchar(widget.sesion.uid);

    _movimientosSubscription = stream.listen(
      _actualizarMovimientos,
      onError: (Object error) {
        if (!mounted) return;
        setState(() {
          _cargandoMovimientos = false;
          _errorMovimientos = error is FirebaseException
              ? error.message ?? error.code
              : error.toString();
        });
      },
    );
  }

  void _actualizarMovimientos(List<Movimiento> movimientos) {
    if (!mounted) return;

    final movimientosOrdenados = List<Movimiento>.of(movimientos)
      ..sort((a, b) => b.fecha.compareTo(a.fecha));
    var ingresos = 0.0;
    var gastos = 0.0;
    var ahorro = 0.0;
    var inversion = 0.0;

    for (final movimiento in movimientosOrdenados) {
      switch (movimiento.categoria) {
        case CategoriaMovimiento.ingresos:
          ingresos += movimiento.monto;
        case CategoriaMovimiento.gastos:
          gastos += movimiento.monto;
        case CategoriaMovimiento.ahorro:
          ahorro += movimiento.monto;
        case CategoriaMovimiento.inversion:
          inversion += movimiento.monto;
      }
    }

    setState(() {
      salario = ingresos;
      gastado = gastos;
      ahorrado = ahorro;
      invertido = inversion;
      _movimientos = movimientosOrdenados;
      _cargandoMovimientos = false;
      _errorMovimientos = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 980;

        return Scaffold(
          body: SafeArea(
            child: Row(
              children: [
                if (isDesktop) const _BarraLateral(),
                Expanded(child: _contenido(isDesktop)),
              ],
            ),
          ),
          floatingActionButton: isDesktop
              ? null
              : FloatingActionButton.extended(
                  tooltip: 'Registra un ingreso, gasto, ahorro o inversión',
                  onPressed: _agregarMovimiento,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Nuevo movimiento'),
                  backgroundColor: const Color(0xFF55D6A0),
                  foregroundColor: const Color(0xFF0C111B),
                ),
        );
      },
    );
  }

  Widget _contenido(bool isDesktop) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = isDesktop ? 48.0 : 22.0;
        final contentWidth = (constraints.maxWidth - horizontalPadding * 2)
            .clamp(0.0, 1180.0);

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            isDesktop ? 34 : 22,
            horizontalPadding,
            100,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _encabezado(isDesktop),
                  if (_cargandoMovimientos || _errorMovimientos != null) ...[
                    const SizedBox(height: 14),
                    _estadoSincronizacion(),
                  ],
                  const SizedBox(height: 12),
                  _alertasPagos(),
                  const SizedBox(height: 28),
                  _tarjetaBalance(contentWidth),
                  const SizedBox(height: 30),
                  const _TituloSeccion(
                    titulo: 'Así se mueve tu dinero',
                    subtitulo: 'Resumen de tus finanzas este mes',
                  ),
                  const SizedBox(height: 16),
                  _cuadriculaResumen(contentWidth),
                  const SizedBox(height: 30),
                  _actividadReciente(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _estadoSincronizacion() {
    final error = _errorMovimientos;
    final cargando = _cargandoMovimientos;
    final color = cargando ? const Color(0xFF9AA6B8) : const Color(0xFFFF8798);

    return Container(
      key: const Key('movement_sync_status'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Icon(
            cargando ? Icons.cloud_sync_outlined : Icons.cloud_off_outlined,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              cargando
                  ? 'Sincronizando movimientos...'
                  : 'No se pudieron sincronizar los movimientos: $error',
              style: TextStyle(color: color, fontSize: 12, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _alertasPagos() {
    return StreamBuilder<List<Pago>>(
      stream: _pagosStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Container(
            key: const Key('payment_alert_error'),
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFF7187).withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFFF7187).withValues(alpha: 0.25),
              ),
            ),
            child: Text(
              'No se pudieron revisar los próximos pagos: ${snapshot.error}',
              style: const TextStyle(color: Color(0xFFFF8798)),
            ),
          );
        }
        if (!snapshot.hasData) return const SizedBox.shrink();

        final hoy = DateTime.now();
        final hoySinHora = DateTime(hoy.year, hoy.month, hoy.day);
        final pagosPendientes =
            snapshot.data!
                .where((pago) => pago.estado == 'pendiente')
                .map((pago) {
                  final limite = DateTime(
                    pago.fechaLimite.year,
                    pago.fechaLimite.month,
                    pago.fechaLimite.day,
                  );
                  final dias = limite.difference(hoySinHora).inDays;
                  return (pago: pago, dias: dias);
                })
                .where((item) => item.dias <= 2)
                .toList()
              ..sort((a, b) => a.dias.compareTo(b.dias));
        if (pagosPendientes.isEmpty) return const SizedBox.shrink();

        if (kIsWeb &&
            html.Notification.supported &&
            html.Notification.permission == 'granted') {
          for (final item in pagosPendientes) {
            if (_alertasMostradas.add(item.pago.id)) {
              Future.microtask(() {
                if (!mounted) return;
                final mensaje = item.dias < 0
                    ? '¡Atrasado! El pago de ${item.pago.titulo} ya venció.'
                    : 'Faltan ${item.dias} día(s) para pagar: '
                          '${item.pago.titulo}';
                _mostrarNotificacionNativa('⚠️ Alerta de Pago', mensaje);
              });
            }
          }
        }

        return Column(
          key: const Key('payment_alerts'),
          children: [
            if (kIsWeb &&
                html.Notification.supported &&
                html.Notification.permission != 'granted')
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  key: const Key('enable_native_payment_notifications'),
                  onPressed: _activarNotificacionesNativas,
                  icon: const Icon(Icons.notifications_active_outlined),
                  label: const Text('Activar notificaciones'),
                ),
              ),
            for (final item in pagosPendientes)
              _tarjetaAlertaPago(item.pago, item.dias),
          ],
        );
      },
    );
  }

  Future<void> _activarNotificacionesNativas() async {
    if (!kIsWeb || !html.Notification.supported) return;

    try {
      final permiso = html.Notification.permission == 'granted'
          ? 'granted'
          : await html.Notification.requestPermission();
      if (!mounted) return;
      if (permiso == 'granted') {
        setState(() {});
      } else {
        _mostrarAvisoNotificaciones(
          'Permite las notificaciones de este sitio en la configuración '
          'del navegador.',
        );
      }
    } catch (error) {
      if (mounted) {
        _mostrarAvisoNotificaciones(
          'No se pudo activar las notificaciones: $error',
        );
      }
    }
  }

  void _mostrarNotificacionNativa(String titulo, String mensaje) {
    if (!kIsWeb ||
        !html.Notification.supported ||
        html.Notification.permission != 'granted') {
      return;
    }

    try {
      html.Notification(titulo, body: mensaje);
    } catch (error) {
      if (mounted) {
        _mostrarAvisoNotificaciones(
          'No se pudo mostrar la notificación: $error',
        );
      }
    }
  }

  void _mostrarAvisoNotificaciones(String mensaje) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensaje)));
  }

  Widget _tarjetaAlertaPago(Pago pago, int dias) {
    final color = dias <= 0 ? const Color(0xFFFF7187) : const Color(0xFFFFC56E);
    final mensaje = switch (dias) {
      < 0 => 'Vencido hace ${dias.abs()} ${dias.abs() == 1 ? 'día' : 'días'}',
      0 => 'Vence hoy',
      1 => 'Vence mañana',
      _ => 'Vence en 2 días',
    };
    return Container(
      key: Key('payment_alert_${pago.id}'),
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF1B2333), color.withValues(alpha: 0.12)],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withValues(alpha: 0.42)),
      ),
      child: Row(
        children: [
          Icon(Icons.notifications_active_outlined, color: color, size: 21),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mensaje,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${pago.titulo} · saldo ${_formatearMoneda(pago.saldoPendiente)}',
                  style: const TextStyle(
                    color: Color(0xFFF3F6FC),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            key: Key('payment_alert_open_${pago.id}'),
            onPressed: _abrirPagos,
            child: const Text('Ver'),
          ),
        ],
      ),
    );
  }

  Widget _encabezado(bool isDesktop) {
    final fecha = DateTime.now();
    const meses = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${meses[fecha.month - 1].toUpperCase()} ${fecha.year}',
                style: const TextStyle(
                  color: Color(0xFF8792A5),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                isDesktop ? 'Tu dinero, en orden.' : 'Resumen financiero',
                style: const TextStyle(
                  color: Color(0xFFF3F6FC),
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.6,
                ),
              ),
              if (widget.sesion.correo.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  'Conectado como ${widget.sesion.correo}',
                  key: const Key('signed_in_email'),
                  style: const TextStyle(
                    color: Color(0xFF8792A5),
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (isDesktop)
          Tooltip(
            message: 'Registra un ingreso, gasto, ahorro o inversión',
            child: FilledButton.icon(
              onPressed: _agregarMovimiento,
              icon: const Icon(Icons.add_rounded, size: 19),
              label: const Text('Nuevo movimiento'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF55D6A0),
                foregroundColor: const Color(0xFF0C111B),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 15,
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          )
        else
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF192333),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              color: Color(0xFF55D6A0),
              size: 21,
            ),
          ),
        IconButton(
          key: const Key('open_user_profile'),
          tooltip: 'Administrar teléfono, correo y contraseña',
          onPressed: _abrirPerfil,
          icon: const Icon(Icons.person_outline_rounded),
          color: const Color(0xFF9DDDC1),
        ),
        if (isDesktop)
          Tooltip(
            message: 'Registra y consulta tus deudas y pagos',
            child: FilledButton.tonalIcon(
              key: const Key('open_user_payments'),
              onPressed: _abrirPagos,
              icon: const Icon(Icons.receipt_long_outlined, size: 18),
              label: const Text('Mis deudas'),
              style: FilledButton.styleFrom(
                foregroundColor: const Color(0xFF55D6A0),
                backgroundColor: const Color(0xFF55D6A0)
                    .withValues(alpha: 0.12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 13,
                ),
              ),
            ),
          )
        else
          IconButton(
            key: const Key('open_user_payments'),
            tooltip: 'Registra y consulta tus deudas y pagos',
            onPressed: _abrirPagos,
            icon: const Icon(Icons.receipt_long_outlined),
            color: const Color(0xFF55D6A0),
          ),
        const SizedBox(width: 8),
        IconButton(
          key: const Key('sign_out'),
          tooltip: 'Cerrar sesión',
          onPressed: _cerrarSesion,
          icon: const Icon(Icons.logout_rounded),
          color: const Color(0xFF9AA6B8),
        ),
      ],
    );
  }

  Future<void> _abrirPerfil() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => PantallaPerfilUsuario(
          uid: widget.sesion.uid,
          correo: widget.sesion.correo,
          leerTelefono: widget.leerTelefonoPerfil,
          guardarTelefono: widget.guardarTelefonoPerfil,
          reautenticar: widget.reautenticarPerfil,
          enviarCambioCorreo: widget.enviarCambioCorreoPerfil,
          actualizarContrasena: widget.actualizarContrasenaPerfil,
        ),
      ),
    );
  }

  Future<void> _abrirPagos() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => PantallaPagos(
          uid: widget.sesion.uid,
          escucharPagos: widget.escucharPagos,
          registrarPago: widget.registrarPago,
          confirmarPago: widget.confirmarPago,
          marcarPagoNoPagado: widget.marcarPagoNoPagado,
        ),
      ),
    );
  }

  Future<void> _cerrarSesion() async {
    try {
      final cerrarSesion = widget.cerrarSesion;
      if (cerrarSesion == null) {
        await FirebaseAuth.instance.signOut();
      } else {
        await cerrarSesion();
      }
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(_mensajeErrorAuth(error))));
      }
    }
  }

  Widget _tarjetaBalance(double availableWidth) {
    final verticalLayout = availableWidth < 590;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A3440), Color(0xFF172535), Color(0xFF192333)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -35,
            top: -70,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF55D6A0).withValues(alpha: 0.07),
              ),
            ),
          ),
          if (verticalLayout)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _balancePrincipal(),
                const SizedBox(height: 26),
                _resumenBalance(),
              ],
            )
          else
            Row(
              children: [
                Expanded(child: _balancePrincipal()),
                const SizedBox(width: 24),
                _resumenBalance(),
              ],
            ),
        ],
      ),
    );
  }

  Widget _balancePrincipal() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'BALANCE DISPONIBLE',
              style: TextStyle(
                color: Color(0xFFB3C3C7),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.3,
              ),
            ),
            const SizedBox(width: 8),
            Tooltip(
              message:
                  'Ingresos menos gastos, ahorros e inversiones registrados.',
              child: Icon(
                Icons.info_outline_rounded,
                color: Colors.white.withValues(alpha: 0.45),
                size: 15,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          _formatearMoneda(_sobrante),
          key: const Key('available_balance'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 38,
            height: 1.1,
            fontWeight: FontWeight.w700,
            letterSpacing: -1.5,
          ),
        ),
        const SizedBox(height: 9),
        const Text(
          'Ingresos menos gastos, ahorro e inversión',
          style: TextStyle(color: Color(0xFFB3C3C7), fontSize: 12),
        ),
      ],
    );
  }

  Widget _resumenBalance() {
    return Wrap(
      spacing: 22,
      runSpacing: 16,
      children: [
        _datoBalance('INGRESOS', salario, const Color(0xFF55D6A0)),
        _datoBalance(
          'SALIDAS',
          gastado + ahorrado + invertido,
          const Color(0xFFFFB86B),
        ),
      ],
    );
  }

  Widget _datoBalance(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFB3C3C7),
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          _formatearMoneda(value),
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _cuadriculaResumen(double availableWidth) {
    final columns = availableWidth >= 1040
        ? 4
        : availableWidth >= 570
        ? 2
        : 2;
    final gap = 12.0;
    final cardWidth = (availableWidth - (gap * (columns - 1))) / columns;
    final data = [
      _ResumenDato(
        titulo: 'Ingresos',
        monto: salario,
        color: const Color(0xFF55D6A0),
        icono: Icons.south_west_rounded,
      ),
      _ResumenDato(
        titulo: 'Gastos',
        monto: gastado,
        color: const Color(0xFFFF7187),
        icono: Icons.shopping_bag_outlined,
      ),
      _ResumenDato(
        titulo: 'Ahorro',
        monto: ahorrado,
        color: const Color(0xFF62B6FF),
        icono: Icons.savings_outlined,
      ),
      _ResumenDato(
        titulo: 'Inversión',
        monto: invertido,
        color: const Color(0xFFFFC56E),
        icono: Icons.trending_up_rounded,
      ),
    ];

    return Wrap(
      spacing: gap,
      runSpacing: gap,
      children: [
        for (final dato in data)
          SizedBox(width: cardWidth, child: _tarjetaResumen(dato)),
      ],
    );
  }

  Widget _tarjetaResumen(_ResumenDato dato) {
    return Container(
      constraints: const BoxConstraints(minHeight: 126),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151D2B),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: Colors.white.withValues(alpha: 0.055)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: dato.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(dato.icono, color: dato.color, size: 18),
              ),
              const Spacer(),
              Icon(
                Icons.more_horiz_rounded,
                color: Colors.white.withValues(alpha: 0.35),
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            dato.titulo,
            style: const TextStyle(color: Color(0xFF9AA6B8), fontSize: 12),
          ),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              _formatearMoneda(dato.monto),
              style: const TextStyle(
                color: Color(0xFFF0F3F8),
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actividadReciente() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _TituloSeccion(
          titulo: 'Actividad reciente',
          subtitulo: 'Los últimos movimientos de tu cuenta',
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF151D2B),
            borderRadius: BorderRadius.circular(19),
            border: Border.all(color: Colors.white.withValues(alpha: 0.055)),
          ),
          child: _movimientos.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24, horizontal: 18),
                  child: Row(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        color: Color(0xFF8792A5),
                        size: 22,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Aún no hay movimientos registrados. Agrega uno para ver aquí tu actividad.',
                          style: TextStyle(
                            color: Color(0xFF9AA6B8),
                            height: 1.45,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    for (
                      var index = 0;
                      index < _movimientos.length && index < 5;
                      index++
                    )
                      _filaMovimiento(
                        _movimientos[index],
                        isLast: index == _movimientos.length - 1 || index == 4,
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _filaMovimiento(Movimiento movimiento, {required bool isLast}) {
    final detalle = _detalleCategoria(movimiento.categoria);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: detalle.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(detalle.icono, color: detalle.color, size: 19),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movimiento.descripcion.isEmpty
                          ? detalle.titulo
                          : movimiento.descripcion,
                      style: const TextStyle(
                        color: Color(0xFFE9EDF4),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${detalle.titulo} · ${_horaMovimiento(movimiento.fecha)}',
                      style: const TextStyle(
                        color: Color(0xFF8792A5),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${movimiento.categoria == CategoriaMovimiento.ingresos ? '+' : '-'}${_formatearMoneda(movimiento.monto)}',
                style: TextStyle(
                  color: detalle.color,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          if (!isLast) ...[
            const SizedBox(height: 13),
            Divider(height: 1, color: Colors.white.withValues(alpha: 0.055)),
          ],
        ],
      ),
    );
  }

  Future<void> _agregarMovimiento() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: const Color(0xFF151D2B),
      builder: (sheetContext) =>
          _FormularioMovimiento(onSave: _guardarMovimiento),
    );
  }

  Future<void> _guardarMovimiento(Movimiento movimiento) async {
    final guardar = widget.guardarMovimiento;
    if (guardar == null) {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(widget.sesion.uid)
          .collection('movimientos')
          .add({
            'monto': movimiento.monto,
            'categoria': movimiento.categoria.name,
            'descripcion': movimiento.descripcion,
            'fecha': FieldValue.serverTimestamp(),
          });
    } else {
      await guardar(widget.sesion.uid, movimiento);
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Movimiento registrado correctamente')),
    );
  }
}

class _FormularioMovimiento extends StatefulWidget {
  const _FormularioMovimiento({required this.onSave});

  final Future<void> Function(Movimiento movimiento) onSave;

  @override
  State<_FormularioMovimiento> createState() => _FormularioMovimientoState();
}

class _FormularioMovimientoState extends State<_FormularioMovimiento> {
  final _formKey = GlobalKey<FormState>();
  final _montoController = TextEditingController();
  final _descripcionController = TextEditingController();
  CategoriaMovimiento _categoria = CategoriaMovimiento.gastos;
  bool _guardando = false;

  @override
  void dispose() {
    _montoController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          22,
          4,
          22,
          MediaQuery.viewInsetsOf(context).bottom + 22,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Nuevo movimiento',
                style: TextStyle(
                  color: Color(0xFFF3F6FC),
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Registra una operación para actualizar tu balance.',
                style: TextStyle(color: Color(0xFF9AA6B8), fontSize: 13),
              ),
              const SizedBox(height: 22),
              _etiquetaCampo('Monto'),
              const SizedBox(height: 8),
              TextFormField(
                key: const Key('movement_amount'),
                controller: _montoController,
                enabled: !_guardando,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: _decoracionCampo(
                  hint: '0.00',
                  prefix: const Text('\$  '),
                ),
                validator: (value) {
                  final amount = double.tryParse(
                    (value ?? '').trim().replaceAll(',', '.'),
                  );
                  if (amount == null || !amount.isFinite || amount <= 0) {
                    return 'Ingresa un monto mayor que cero';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 17),
              _etiquetaCampo('Categoría'),
              const SizedBox(height: 8),
              DropdownButtonFormField<CategoriaMovimiento>(
                initialValue: _categoria,
                decoration: _decoracionCampo(),
                dropdownColor: const Color(0xFF202B3B),
                items: CategoriaMovimiento.values
                    .map(
                      (categoria) => DropdownMenuItem(
                        value: categoria,
                        child: Text(_detalleCategoria(categoria).titulo),
                      ),
                    )
                    .toList(),
                onChanged: _guardando
                    ? null
                    : (categoria) {
                        if (categoria != null) {
                          setState(() => _categoria = categoria);
                        }
                      },
              ),
              const SizedBox(height: 17),
              _etiquetaCampo('Descripción (opcional)'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descripcionController,
                enabled: !_guardando,
                textCapitalization: TextCapitalization.sentences,
                decoration: _decoracionCampo(
                  hint: 'Ej. Compra del supermercado',
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: _guardando ? null : _guardar,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF55D6A0),
                    foregroundColor: const Color(0xFF0C111B),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: _guardando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF0C111B),
                          ),
                        )
                      : const Text('Guardar movimiento'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _etiquetaCampo(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFFD6DCE7),
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  InputDecoration _decoracionCampo({String? hint, Widget? prefix}) {
    return InputDecoration(
      hintText: hint,
      prefix: prefix,
      filled: true,
      fillColor: const Color(0xFF0F1724),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.07)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: Color(0xFF55D6A0)),
      ),
      errorStyle: const TextStyle(color: Color(0xFFFF8798)),
    );
  }

  Future<void> _guardar() async {
    if (_guardando || !_formKey.currentState!.validate()) return;
    final monto = double.parse(
      _montoController.text.trim().replaceAll(',', '.'),
    );

    setState(() => _guardando = true);
    try {
      await widget.onSave(
        Movimiento(
          categoria: _categoria,
          monto: monto,
          descripcion: _descripcionController.text.trim(),
          fecha: DateTime.now(),
        ),
      );
      if (mounted) Navigator.of(context).pop();
    } on FirebaseException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'No se pudo guardar el movimiento: '
              '${error.message ?? error.code}',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }
}

class _BarraLateral extends StatelessWidget {
  const _BarraLateral();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 238,
      decoration: const BoxDecoration(
        color: Color(0xFF101722),
        border: Border(right: BorderSide(color: Color(0xFF202A38))),
      ),
      padding: const EdgeInsets.fromLTRB(22, 26, 18, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFF55D6A0).withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Color(0xFF55D6A0),
                  size: 20,
                ),
              ),
              const SizedBox(width: 11),
              const Text(
                'Finanzas',
                style: TextStyle(
                  color: Color(0xFFF3F6FC),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 44),
          const Text(
            'MENÚ',
            style: TextStyle(
              color: Color(0xFF69768A),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1B2935),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.grid_view_rounded,
                  color: Color(0xFF55D6A0),
                  size: 19,
                ),
                SizedBox(width: 12),
                Text(
                  'Resumen',
                  style: TextStyle(
                    color: Color(0xFFF0F3F8),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFF172230),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  color: Color(0xFFFFC56E),
                  size: 20,
                ),
                SizedBox(height: 12),
                Text(
                  'Un paso a la vez',
                  style: TextStyle(
                    color: Color(0xFFE9EDF4),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Registra tus movimientos para tener una visión clara de tu dinero.',
                  style: TextStyle(
                    color: Color(0xFF8792A5),
                    fontSize: 11,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TituloSeccion extends StatelessWidget {
  const _TituloSeccion({required this.titulo, required this.subtitulo});

  final String titulo;
  final String subtitulo;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            color: Color(0xFFF0F3F8),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitulo,
          style: const TextStyle(color: Color(0xFF8792A5), fontSize: 12),
        ),
      ],
    );
  }
}

class _ResumenDato {
  const _ResumenDato({
    required this.titulo,
    required this.monto,
    required this.color,
    required this.icono,
  });

  final String titulo;
  final double monto;
  final Color color;
  final IconData icono;
}

class _DetalleCategoria {
  const _DetalleCategoria(this.titulo, this.color, this.icono);

  final String titulo;
  final Color color;
  final IconData icono;
}

_DetalleCategoria _detalleCategoria(CategoriaMovimiento categoria) {
  return switch (categoria) {
    CategoriaMovimiento.ingresos => const _DetalleCategoria(
      'Ingresos',
      Color(0xFF55D6A0),
      Icons.south_west_rounded,
    ),
    CategoriaMovimiento.gastos => const _DetalleCategoria(
      'Gastos',
      Color(0xFFFF7187),
      Icons.shopping_bag_outlined,
    ),
    CategoriaMovimiento.ahorro => const _DetalleCategoria(
      'Ahorro',
      Color(0xFF62B6FF),
      Icons.savings_outlined,
    ),
    CategoriaMovimiento.inversion => const _DetalleCategoria(
      'Inversión',
      Color(0xFFFFC56E),
      Icons.trending_up_rounded,
    ),
  };
}

String _formatearMoneda(double monto) {
  final partes = monto.abs().toStringAsFixed(2).split('.');
  final entero = partes[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => ',',
  );
  return '${monto < 0 ? '-' : ''}\$$entero.${partes[1]}';
}

Movimiento _movimientoDesdeDatos(String id, Map<String, dynamic> datos) {
  final monto = datos['monto'];
  if (monto is! num || !monto.toDouble().isFinite || monto <= 0) {
    throw FormatException('El movimiento $id tiene un monto inválido.');
  }

  final categoriaOriginal = datos['categoria'];
  if (categoriaOriginal is! String) {
    throw FormatException('El movimiento $id no tiene una categoría válida.');
  }

  final categoriaNormalizada = categoriaOriginal
      .trim()
      .toLowerCase()
      .replaceAll('ó', 'o');
  final categoria = switch (categoriaNormalizada) {
    'ingreso' || 'ingresos' => CategoriaMovimiento.ingresos,
    'gasto' || 'gastos' => CategoriaMovimiento.gastos,
    'ahorro' => CategoriaMovimiento.ahorro,
    'inversion' => CategoriaMovimiento.inversion,
    _ => throw FormatException(
      'El movimiento $id tiene una categoría desconocida: '
      '$categoriaOriginal.',
    ),
  };

  final descripcionOriginal = datos['descripcion'];
  if (descripcionOriginal != null && descripcionOriginal is! String) {
    throw FormatException('El movimiento $id tiene una descripción inválida.');
  }

  final fechaOriginal = datos['fecha'];
  final fecha = switch (fechaOriginal) {
    Timestamp timestamp => timestamp.toDate(),
    DateTime dateTime => dateTime,
    _ => DateTime.now(),
  };

  return Movimiento(
    categoria: categoria,
    monto: monto.toDouble(),
    descripcion: descripcionOriginal as String? ?? '',
    fecha: fecha,
  );
}

String _horaMovimiento(DateTime fecha) {
  final hora = fecha.hour.toString().padLeft(2, '0');
  final minuto = fecha.minute.toString().padLeft(2, '0');
  return '$hora:$minuto';
}

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
                  _mensajeAcceso(_error ?? _mensaje!, esError: _error != null),
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
                              _decoracionAcceso(
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
                          decoration: _decoracionAcceso(
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
                          decoration: _decoracionAcceso(
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
                          decoration: _decoracionAcceso(
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
                          decoration: _decoracionAcceso(
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
      FirebaseAuthException authError => _mensajeErrorAuth(authError),
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

Stream<List<Pago>> _streamPagosUsuario(String uid) {
  return FirebaseFirestore.instance
      .collection('usuarios')
      .doc(uid)
      .collection('pagos')
      .orderBy('fecha_limite')
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((documento) => _pagoDesdeDatos(documento.id, documento.data()))
            .toList(),
      );
}

Pago _pagoDesdeDatos(String id, Map<String, dynamic> datos) {
  final titulo = datos['titulo'];
  final monto = datos['monto'];
  final montoPagado = datos['monto_pagado'] ?? 0;
  final limite = datos['fecha_limite'];
  final estado = datos['estado'];
  if (titulo is! String || titulo.trim().isEmpty) {
    throw FormatException('El pago $id tiene un nombre inválido.');
  }
  if (monto is! num || !monto.toDouble().isFinite || monto <= 0) {
    throw FormatException('El pago $id tiene un monto inválido.');
  }
  if (montoPagado is! num ||
      !montoPagado.toDouble().isFinite ||
      montoPagado < 0 ||
      montoPagado > monto) {
    throw FormatException('El pago $id tiene un abono inválido.');
  }
  if (limite is! Timestamp) {
    throw FormatException('El pago $id no tiene una fecha límite válida.');
  }
  if (estado is! String ||
      !const {'pendiente', 'pagado', 'no_pagado'}.contains(estado)) {
    throw FormatException('El pago $id tiene un estado desconocido.');
  }

  return Pago(
    id: id,
    titulo: titulo,
    monto: monto.toDouble(),
    fechaLimite: limite.toDate(),
    estado: estado,
    montoPagado: montoPagado.toDouble(),
  );
}

class PantallaPagos extends StatefulWidget {
  const PantallaPagos({
    super.key,
    required this.uid,
    this.escucharPagos,
    this.registrarPago,
    this.confirmarPago,
    this.marcarPagoNoPagado,
  });

  final String uid;
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

  @override
  State<PantallaPagos> createState() => _PantallaPagosState();
}

class _PantallaPagosState extends State<PantallaPagos> {
  late final Stream<List<Pago>> _pagosStream;
  final _tituloPagoController = TextEditingController();
  final _montoPagoController = TextEditingController();
  final _montoAbonoController = TextEditingController();
  bool _procesando = false;

  @override
  void initState() {
    super.initState();
    final escuchar = widget.escucharPagos;
    _pagosStream = escuchar == null
        ? _streamPagosUsuario(widget.uid)
        : escuchar(widget.uid);
  }

  @override
  void dispose() {
    _tituloPagoController.dispose();
    _montoPagoController.dispose();
    _montoAbonoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C111B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF101722),
        title: const Text(
          'Pagos y recordatorios',
          style: TextStyle(
            color: Color(0xFFF3F6FC),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('payment_add_button'),
        tooltip: 'Agrega una deuda o pago por vencer',
        onPressed: _procesando ? null : _registrarNuevaDeuda,
        backgroundColor: const Color(0xFF55D6A0),
        foregroundColor: const Color(0xFF0C111B),
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Nueva deuda',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: StreamBuilder<List<Pago>>(
        stream: _pagosStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _estadoPagos(
              icon: Icons.cloud_off_outlined,
              mensaje: 'No se pudieron cargar tus pagos: ${snapshot.error}',
              error: true,
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF55D6A0)),
            );
          }

          final pagos = List<Pago>.of(snapshot.data ?? const <Pago>[])
            ..sort((a, b) => a.fechaLimite.compareTo(b.fechaLimite));
          final saldoPendiente = pagos
              .where((pago) => pago.estado == 'pendiente')
              .fold<double>(0, (total, pago) => total + pago.saldoPendiente);

          if (pagos.isEmpty) {
            return Column(
              children: [
                _resumenPagos(0, 0),
                Expanded(
                  child: _estadoPagos(
                    icon: Icons.event_available_outlined,
                    mensaje:
                        'Todavía no tienes pagos registrados. '
                        'Agrega uno para recibir recordatorios.',
                  ),
                ),
              ],
            );
          }

          return Column(
            children: [
              _resumenPagos(pagos.length, saldoPendiente),
              Expanded(
                child: ListView.separated(
                  key: const Key('payment_list'),
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 100),
                  itemCount: pagos.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 11),
                  itemBuilder: (context, index) => _tarjetaPago(pagos[index]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _resumenPagos(int cantidad, double saldoPendiente) {
    return Container(
      key: const Key('payment_overview'),
      margin: const EdgeInsets.fromLTRB(18, 18, 18, 10),
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A3440), Color(0xFF172535)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: const Color(0xFF55D6A0).withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              color: Color(0xFF55D6A0),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$cantidad ${cantidad == 1 ? 'pago registrado' : 'pagos registrados'}',
                  style: const TextStyle(
                    color: Color(0xFF9AA6B8),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Saldo pendiente',
                  style: TextStyle(
                    color: Color(0xFFF3F6FC),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatearMoneda(saldoPendiente),
            key: const Key('payment_outstanding_total'),
            style: const TextStyle(
              color: Color(0xFF55D6A0),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tarjetaPago(Pago pago) {
    final color = switch (pago.estado) {
      'pagado' => const Color(0xFF55D6A0),
      'no_pagado' => const Color(0xFFFF7187),
      _ => const Color(0xFFFFC56E),
    };
    final limite = pago.fechaLimite.toLocal();
    final fechaTexto =
        '${limite.day.toString().padLeft(2, '0')}/'
        '${limite.month.toString().padLeft(2, '0')}/${limite.year}';
    final saldo = pago.saldoPendiente;

    return Container(
      key: Key('payment_card_${pago.id}'),
      decoration: BoxDecoration(
        color: const Color(0xFF151D2B),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: Colors.white.withValues(alpha: 0.055)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 15, 12, 13),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    pago.estado == 'pagado'
                        ? Icons.verified_outlined
                        : Icons.receipt_long_outlined,
                    color: color,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pago.titulo,
                        style: const TextStyle(
                          color: Color(0xFFF3F6FC),
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Vence $fechaTexto · ${_estadoPagoTexto(pago.estado)}',
                        style: TextStyle(color: color, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Text(
                  pago.estado == 'pagado'
                      ? _formatearMoneda(pago.monto)
                      : _formatearMoneda(saldo),
                  style: const TextStyle(
                    color: Color(0xFFF3F6FC),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            if (pago.montoPagado > 0) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: (pago.montoPagado / pago.monto).clamp(0, 1),
                minHeight: 5,
                borderRadius: BorderRadius.circular(4),
                backgroundColor: Colors.white.withValues(alpha: 0.08),
                color: const Color(0xFF55D6A0),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Abonado ${_formatearMoneda(pago.montoPagado)} de '
                  '${_formatearMoneda(pago.monto)}',
                  style: const TextStyle(
                    color: Color(0xFF9AA6B8),
                    fontSize: 11,
                  ),
                ),
              ),
            ],
            if (pago.estado == 'pendiente') ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    key: Key('payment_unpaid_${pago.id}'),
                    onPressed: _procesando ? null : () => _marcarNoPagado(pago),
                    icon: const Icon(Icons.close_rounded, size: 18),
                    label: const Text('No pagado'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFFF8798),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.tonalIcon(
                    key: Key('payment_pay_${pago.id}'),
                    onPressed: _procesando || saldo <= 0
                        ? null
                        : () => _cobrarDeuda(pago),
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text('Registrar pago'),
                    style: FilledButton.styleFrom(
                      foregroundColor: const Color(0xFF55D6A0),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _estadoPagoTexto(String estado) => switch (estado) {
    'pagado' => 'PAGADO',
    'no_pagado' => 'NO PAGADO',
    _ => 'PENDIENTE',
  };

  Widget _estadoPagos({
    required IconData icon,
    required String mensaje,
    bool error = false,
  }) {
    final color = error ? const Color(0xFFFF8798) : const Color(0xFF9AA6B8);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 42),
            const SizedBox(height: 14),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: TextStyle(color: color, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _registrarNuevaDeuda() async {
    final formKey = GlobalKey<FormState>();
    final tituloController = _tituloPagoController..clear();
    final montoController = _montoPagoController..clear();
    DateTime? fechaSeleccionada;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF151D2B),
          title: const Text(
            'Registrar una deuda',
            style: TextStyle(color: Color(0xFFF3F6FC)),
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    key: const Key('payment_title_input'),
                    controller: tituloController,
                    textCapitalization: TextCapitalization.sentences,
                    maxLength: 60,
                    decoration: _decoracionAcceso(
                      hint: 'Ej. Servicio de electricidad',
                      icon: Icons.receipt_long_outlined,
                    ).copyWith(labelText: 'Nombre del pago'),
                    validator: (value) {
                      final titulo = (value ?? '').trim();
                      if (titulo.length < 2 || titulo.length > 60) {
                        return 'Escribe entre 2 y 60 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const Key('payment_amount_input'),
                    controller: montoController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: _decoracionAcceso(
                      hint: '0.00',
                      icon: Icons.attach_money_rounded,
                    ).copyWith(labelText: 'Monto total'),
                    validator: (value) {
                      final monto = double.tryParse(
                        (value ?? '').trim().replaceAll(',', '.'),
                      );
                      if (monto == null ||
                          !monto.isFinite ||
                          monto <= 0 ||
                          monto > 1000000000 ||
                          !RegExp(r'^\d+([.,]\d{1,2})?$')
                              .hasMatch((value ?? '').trim())) {
                        return 'Ingresa un monto válido mayor que cero';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      key: const Key('payment_due_date'),
                      onPressed: () async {
                        final hoy = DateTime.now();
                        final fecha = await showDatePicker(
                          context: context,
                          initialDate:
                              fechaSeleccionada ??
                              DateTime(hoy.year, hoy.month, hoy.day),
                          firstDate: DateTime(hoy.year, hoy.month, hoy.day),
                          lastDate: DateTime(hoy.year + 20),
                        );
                        if (fecha != null) {
                          setDialogState(() => fechaSeleccionada = fecha);
                        }
                      },
                      icon: const Icon(Icons.calendar_month_outlined),
                      label: Text(
                        fechaSeleccionada == null
                            ? 'Seleccionar fecha límite'
                            : 'Vence ${_fechaCorta(fechaSeleccionada!)}',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              key: const Key('payment_save_button'),
              onPressed: _procesando
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      final fecha = fechaSeleccionada;
                      if (fecha == null) {
                        _mostrarAviso(
                          'Selecciona la fecha límite del pago.',
                          error: true,
                        );
                        return;
                      }
                      final pago = Pago(
                        id: '',
                        titulo: tituloController.text.trim(),
                        monto: double.parse(
                          montoController.text.trim().replaceAll(',', '.'),
                        ),
                        fechaLimite: DateTime(
                          fecha.year,
                          fecha.month,
                          fecha.day,
                        ),
                        estado: 'pendiente',
                        montoPagado: 0,
                      );
                      final exito = await _ejecutarAccion(() async {
                        final registrar = widget.registrarPago;
                        if (registrar != null) {
                          await registrar(widget.uid, pago);
                        } else {
                          await FirebaseFirestore.instance
                              .collection('usuarios')
                              .doc(widget.uid)
                              .collection('pagos')
                              .add({
                                'uid': widget.uid,
                                'titulo': pago.titulo,
                                'monto': pago.monto,
                                'monto_pagado': 0,
                                'fecha_limite': Timestamp.fromDate(
                                  pago.fechaLimite,
                                ),
                                'estado': 'pendiente',
                                'fecha_creacion': FieldValue.serverTimestamp(),
                              });
                        }
                      }, mensajeExito: 'Pago agregado a tus recordatorios.');
                      if (exito && dialogContext.mounted) {
                        Navigator.of(dialogContext).pop();
                      }
                    },
              child: const Text('Guardar pago'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _cobrarDeuda(Pago pago) async {
    final formKey = GlobalKey<FormState>();
    final montoController = _montoAbonoController..clear();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF151D2B),
        title: Text(
          'Registrar abono · ${pago.titulo}',
          style: const TextStyle(color: Color(0xFFF3F6FC)),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Saldo pendiente: ${_formatearMoneda(pago.saldoPendiente)}',
                style: const TextStyle(color: Color(0xFF9AA6B8)),
              ),
              const SizedBox(height: 14),
              TextFormField(
                key: const Key('payment_paid_amount_input'),
                controller: montoController,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: _decoracionAcceso(
                  hint: '0.00',
                  icon: Icons.attach_money_rounded,
                ).copyWith(labelText: 'Monto pagado'),
                validator: (value) {
                  final monto = double.tryParse(
                    (value ?? '').trim().replaceAll(',', '.'),
                  );
                  if (monto == null ||
                      !monto.isFinite ||
                      monto <= 0 ||
                      monto > pago.saldoPendiente ||
                      !RegExp(r'^\d+([.,]\d{1,2})?$')
                          .hasMatch((value ?? '').trim())) {
                    return 'Ingresa un monto hasta ${_formatearMoneda(pago.saldoPendiente)}';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            key: const Key('payment_confirm_button'),
            onPressed: _procesando
                ? null
                : () async {
                    if (!formKey.currentState!.validate()) return;
                    final monto = double.parse(
                      montoController.text.trim().replaceAll(',', '.'),
                    );
                    final permisoNotificacion =
                        _solicitarPermisoNotificacionNativa();
                    final exito = await _ejecutarAccion(
                      () async {
                        final confirmar = widget.confirmarPago;
                        if (confirmar != null) {
                          await confirmar(
                            widget.uid,
                            pago.id,
                            monto,
                            DateTime.now(),
                          );
                        } else {
                          final nuevoMontoPagado = double.parse(
                            (pago.montoPagado + monto).toStringAsFixed(2),
                          );
                          await FirebaseFirestore.instance
                              .collection('usuarios')
                              .doc(widget.uid)
                              .collection('pagos')
                              .doc(pago.id)
                              .update({
                                'monto_pagado': nuevoMontoPagado,
                                'estado': nuevoMontoPagado >= pago.monto
                                    ? 'pagado'
                                    : 'pendiente',
                                'fecha_pago': FieldValue.serverTimestamp(),
                              });
                        }
                      },
                      mensajeExito:
                          'Abono de ${_formatearMoneda(monto)} registrado.',
                    );
                    if (exito && dialogContext.mounted) {
                      Navigator.of(dialogContext).pop();
                      await _mostrarNotificacionNativa(
                        '✅ Pago Confirmado',
                        'Se registró tu pago de ${_formatearMoneda(monto)} '
                            'para ${pago.titulo}.',
                        permisoSolicitado: permisoNotificacion,
                      );
                    }
                  },
            child: const Text('Confirmar abono'),
          ),
        ],
      ),
    );
  }

  Future<void> _marcarNoPagado(Pago pago) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF151D2B),
        title: const Text('Marcar como no pagado'),
        content: Text(
          '¿Quieres marcar "${pago.titulo}" como no pagado? '
          'Los abonos anteriores se conservarán.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            key: const Key('payment_confirm_unpaid'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Marcar no pagado'),
          ),
        ],
      ),
    );
    if (confirmado != true) return;
    await _ejecutarAccion(() async {
      final marcar = widget.marcarPagoNoPagado;
      if (marcar != null) {
        await marcar(widget.uid, pago.id);
      } else {
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(widget.uid)
            .collection('pagos')
            .doc(pago.id)
            .update({'estado': 'no_pagado'});
      }
    }, mensajeExito: 'El pago se marcó como no pagado.');
  }

  Future<bool> _ejecutarAccion(
    Future<void> Function() accion, {
    required String mensajeExito,
  }) async {
    setState(() => _procesando = true);
    try {
      await accion();
      if (mounted) _mostrarAviso(mensajeExito);
      return true;
    } on FirebaseException catch (error) {
      if (mounted) {
        _mostrarAviso(
          'Firebase no pudo guardar el cambio: '
          '${error.message ?? error.code}',
          error: true,
        );
      }
      return false;
    } catch (error) {
      if (mounted) {
        _mostrarAviso('No se pudo completar el cambio: $error', error: true);
      }
      return false;
    } finally {
      if (mounted) setState(() => _procesando = false);
    }
  }

  void _mostrarAviso(String texto, {bool error = false}) {
    final color = error ? const Color(0xFFB84055) : const Color(0xFF16875D);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          key: const Key('payment_feedback'),
          content: Row(
            children: [
              Icon(
                error
                    ? Icons.error_outline_rounded
                    : Icons.check_circle_rounded,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  texto,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 4),
        ),
      );
  }

  Future<String?> _solicitarPermisoNotificacionNativa() async {
    if (!kIsWeb || !html.Notification.supported) return null;
    if (html.Notification.permission == 'granted') return 'granted';

    try {
      return await html.Notification.requestPermission();
    } catch (error) {
      return 'error: $error';
    }
  }

  Future<void> _mostrarNotificacionNativa(
    String titulo,
    String mensaje, {
    required Future<String?> permisoSolicitado,
  }) async {
    if (!kIsWeb || !html.Notification.supported) return;

    try {
      final permiso = html.Notification.permission == 'granted'
          ? 'granted'
          : await permisoSolicitado;
      if (permiso == 'granted') {
        html.Notification(titulo, body: mensaje);
      } else if (permiso?.startsWith('error:') ?? false) {
        if (mounted) {
          _mostrarAviso(
            'Pago registrado, pero no se pudo solicitar permiso para '
            'notificaciones: ${permiso!.substring('error: '.length)}',
            error: true,
          );
        }
      } else if (mounted) {
        _mostrarAviso(
          'Pago registrado. Para recibir notificaciones, '
          'permítelas en la configuración de este sitio.',
          error: true,
        );
      }
    } catch (error) {
      if (mounted) {
        _mostrarAviso(
          'Pago registrado, pero no se pudo mostrar la notificación: $error',
          error: true,
        );
      }
    }
  }
}

String _fechaCorta(DateTime fecha) {
  return '${fecha.day.toString().padLeft(2, '0')}/'
      '${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
}
