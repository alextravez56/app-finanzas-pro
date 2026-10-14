import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;

import '../models/movimiento.dart';
import '../models/pago.dart';
import '../models/sesion.dart';
import '../utils/formatters.dart';
import 'pagos_screen.dart';
import 'perfil_screen.dart';

class DashboardFinanzas extends StatefulWidget {
  const DashboardFinanzas({
    super.key,
    required this.sesion,
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

  final AuthenticatedSession sesion;
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
  bool _filtrarMesActual = false;

  double get _sobrante =>
      _ingresosPeriodo - _gastosPeriodo - _ahorroPeriodo - _inversionPeriodo;

  List<Movimiento> get _movimientosFiltrados {
    if (!_filtrarMesActual) return _movimientos;
    final ahora = DateTime.now();
    return _movimientos
        .where(
          (m) => m.fecha.year == ahora.year && m.fecha.month == ahora.month,
        )
        .toList();
  }

  double get _ingresosPeriodo {
    if (!_filtrarMesActual) return salario;
    return _movimientosFiltrados
        .where((m) => m.categoria == CategoriaMovimiento.ingresos)
        .fold(0.0, (acc, m) => acc + m.monto);
  }

  double get _gastosPeriodo {
    if (!_filtrarMesActual) return gastado;
    return _movimientosFiltrados
        .where((m) => m.categoria == CategoriaMovimiento.gastos)
        .fold(0.0, (acc, m) => acc + m.monto);
  }

  double get _ahorroPeriodo {
    if (!_filtrarMesActual) return ahorrado;
    return _movimientosFiltrados
        .where((m) => m.categoria == CategoriaMovimiento.ahorro)
        .fold(0.0, (acc, m) => acc + m.monto);
  }

  double get _inversionPeriodo {
    if (!_filtrarMesActual) return invertido;
    return _movimientosFiltrados
        .where((m) => m.categoria == CategoriaMovimiento.inversion)
        .fold(0.0, (acc, m) => acc + m.monto);
  }

  @override
  void initState() {
    super.initState();
    final escucharPagos = widget.escucharPagos;
    _pagosStream = escucharPagos == null
        ? streamPagosUsuario(widget.sesion.uid)
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
                          movimientoDesdeDatos(document.id, document.data()),
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
                  _seccionMovimientosEncabezado(),
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

  Widget _seccionMovimientosEncabezado() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: _TituloSeccion(
            titulo: 'Así se mueve tu dinero',
            subtitulo: _filtrarMesActual
                ? 'Resumen de tus finanzas este mes'
                : 'Resumen general de tus movimientos',
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF151D2B),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          padding: const EdgeInsets.all(3),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _botonFiltro(
                etiqueta: 'Todo',
                seleccionado: !_filtrarMesActual,
                onTap: () => setState(() => _filtrarMesActual = false),
              ),
              _botonFiltro(
                etiqueta: 'Este mes',
                seleccionado: _filtrarMesActual,
                onTap: () => setState(() => _filtrarMesActual = true),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _botonFiltro({
    required String etiqueta,
    required bool seleccionado,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: seleccionado
              ? const Color(0xFF55D6A0).withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(
          etiqueta,
          style: TextStyle(
            color: seleccionado
                ? const Color(0xFF55D6A0)
                : const Color(0xFF8792A5),
            fontSize: 12,
            fontWeight: seleccionado ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
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
              style: const TextStyle(color: Color(0xFFFF7187)),
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
                  pago.titulo,
                  style: const TextStyle(
                    color: Color(0xFFF3F6FC),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            formatearMoneda(pago.saldoPendiente),
            style: TextStyle(
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
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
          eliminarPago: widget.eliminarPago,
          guardarMovimiento: widget.guardarMovimiento,
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
          formatearMoneda(_sobrante),
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
          formatearMoneda(value),
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
        monto: _ingresosPeriodo,
        color: const Color(0xFF55D6A0),
        icono: Icons.south_west_rounded,
      ),
      _ResumenDato(
        titulo: 'Gastos',
        monto: _gastosPeriodo,
        color: const Color(0xFFFF7187),
        icono: Icons.shopping_bag_outlined,
      ),
      _ResumenDato(
        titulo: 'Ahorro',
        monto: _ahorroPeriodo,
        color: const Color(0xFF62B6FF),
        icono: Icons.savings_outlined,
      ),
      _ResumenDato(
        titulo: 'Inversión',
        monto: _inversionPeriodo,
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
            ],
          ),
          const SizedBox(height: 16),
          Text(
            dato.titulo,
            style: const TextStyle(color: Color(0xFF9AA6B8), fontSize: 13),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              formatearMoneda(dato.monto),
              style: const TextStyle(
                color: Color(0xFFF3F6FC),
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
    final movimientos = _movimientosFiltrados;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TituloSeccion(
          titulo: 'Actividad reciente',
          subtitulo: _filtrarMesActual
              ? 'Movimientos registrados este mes'
              : 'Los últimos movimientos de tu cuenta',
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF151D2B),
            borderRadius: BorderRadius.circular(19),
            border: Border.all(color: Colors.white.withValues(alpha: 0.055)),
          ),
          child: movimientos.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 18,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.receipt_long_outlined,
                        color: Color(0xFF8792A5),
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _filtrarMesActual
                              ? 'No hay movimientos registrados en este mes.'
                              : 'Aún no hay movimientos registrados. Agrega uno para ver aquí tu actividad.',
                          style: const TextStyle(
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
                      index < movimientos.length && index < 5;
                      index++
                    )
                      _filaMovimiento(
                        movimientos[index],
                        isLast: index == movimientos.length - 1 || index == 4,
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _filaMovimiento(Movimiento movimiento, {required bool isLast}) {
    final detalle = detalleCategoria(movimiento.categoria);

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
                '${movimiento.categoria == CategoriaMovimiento.ingresos ? '+' : '-'}${formatearMoneda(movimiento.monto)}',
                style: TextStyle(
                  color: detalle.color,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4),
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert_rounded,
                  size: 18,
                  color: Color(0xFF8792A5),
                ),
                tooltip: 'Opciones',
                onSelected: (accion) {
                  if (accion == 'editar') {
                    _editarMovimiento(movimiento);
                  } else if (accion == 'eliminar') {
                    _confirmarEliminarMovimiento(movimiento);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'editar',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 16, color: Color(0xFF55D6A0)),
                        SizedBox(width: 8),
                        Text('Editar', style: TextStyle(color: Color(0xFFE9EDF4), fontSize: 13)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'eliminar',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, size: 16, color: Color(0xFFFF8798)),
                        SizedBox(width: 8),
                        Text('Eliminar', style: TextStyle(color: Color(0xFFFF8798), fontSize: 13)),
                      ],
                    ),
                  ),
                ],
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

  Future<void> _editarMovimiento(Movimiento movimiento) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: const Color(0xFF151D2B),
      builder: (sheetContext) => _FormularioMovimiento(
        movimientoInicial: movimiento,
        onSave: (movimientoActualizado) async {
          final actualizar = widget.actualizarMovimiento;
          if (actualizar != null) {
            await actualizar(widget.sesion.uid, movimientoActualizado);
          } else if (movimiento.id.isNotEmpty) {
            await FirebaseFirestore.instance
                .collection('usuarios')
                .doc(widget.sesion.uid)
                .collection('movimientos')
                .doc(movimiento.id)
                .update({
                  'monto': movimientoActualizado.monto,
                  'categoria': movimientoActualizado.categoria.name,
                  'descripcion': movimientoActualizado.descripcion,
                });
          }
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Movimiento actualizado')),
            );
          }
        },
      ),
    );
  }

  Future<void> _confirmarEliminarMovimiento(Movimiento movimiento) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF151D2B),
        title: const Text(
          'Eliminar movimiento',
          style: TextStyle(color: Color(0xFFF3F6FC)),
        ),
        content: Text(
          '¿Deseas eliminar este movimiento de '
          '${formatearMoneda(movimiento.monto)}? Esta acción no se puede deshacer.',
          style: const TextStyle(color: Color(0xFF9AA6B8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFF7187),
            ),
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmado != true) return;

    try {
      final eliminar = widget.eliminarMovimiento;
      if (eliminar != null) {
        await eliminar(widget.sesion.uid, movimiento);
      } else if (movimiento.id.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(widget.sesion.uid)
            .collection('movimientos')
            .doc(movimiento.id)
            .delete();
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Movimiento eliminado correctamente')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar movimiento: $error'),
            backgroundColor: const Color(0xFFFF7187),
          ),
        );
      }
    }
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
  const _FormularioMovimiento({
    required this.onSave,
    this.movimientoInicial,
  });

  final Future<void> Function(Movimiento movimiento) onSave;
  final Movimiento? movimientoInicial;

  @override
  State<_FormularioMovimiento> createState() => _FormularioMovimientoState();
}

class _FormularioMovimientoState extends State<_FormularioMovimiento> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _montoController;
  late final TextEditingController _descripcionController;
  late CategoriaMovimiento _categoria;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    final inicial = widget.movimientoInicial;
    _montoController = TextEditingController(
      text: inicial != null ? inicial.monto.toStringAsFixed(2) : '',
    );
    _descripcionController = TextEditingController(
      text: inicial?.descripcion ?? '',
    );
    _categoria = inicial?.categoria ?? CategoriaMovimiento.gastos;
  }

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
              Text(
                widget.movimientoInicial == null
                    ? 'Nuevo movimiento'
                    : 'Editar movimiento',
                style: const TextStyle(
                  color: Color(0xFFF3F6FC),
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.movimientoInicial == null
                    ? 'Registra una operación para actualizar tu balance.'
                    : 'Modifica los datos del movimiento registrado.',
                style: const TextStyle(color: Color(0xFF9AA6B8), fontSize: 13),
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
                        child: Text(detalleCategoria(categoria).titulo),
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
                      : Text(
                          widget.movimientoInicial == null
                              ? 'Guardar movimiento'
                              : 'Actualizar movimiento',
                        ),
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
          id: widget.movimientoInicial?.id ?? '',
          categoria: _categoria,
          monto: monto,
          descripcion: _descripcionController.text.trim(),
          fecha: widget.movimientoInicial?.fecha ?? DateTime.now(),
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

String _horaMovimiento(DateTime fecha) {
  final hora = fecha.hour.toString().padLeft(2, '0');
  final minuto = fecha.minute.toString().padLeft(2, '0');
  return '$hora:$minuto';
}
