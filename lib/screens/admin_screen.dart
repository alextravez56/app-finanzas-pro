import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/movimiento.dart';
import '../models/sesion.dart';
import '../models/usuario.dart';
import '../utils/formatters.dart';

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
            .showSnackBar(SnackBar(content: Text(mensajeErrorAuth(error))));
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
                          movimientoDesdeDatos(documento.id, documento.data()),
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
            formatearMoneda(monto),
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
    final detalle = detalleCategoria(movimiento.categoria);
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
            formatearMoneda(movimiento.monto),
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
