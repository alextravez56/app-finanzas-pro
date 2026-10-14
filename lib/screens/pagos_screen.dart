import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;

import '../models/movimiento.dart';
import '../models/pago.dart';
import '../utils/formatters.dart';

Stream<List<Pago>> streamPagosUsuario(String uid) {
  return FirebaseFirestore.instance
      .collection('usuarios')
      .doc(uid)
      .collection('pagos')
      .orderBy('fecha_limite')
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((documento) => pagoDesdeDatos(documento.id, documento.data()))
            .toList(),
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
    this.eliminarPago,
    this.guardarMovimiento,
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
  final Future<void> Function(String uid, String pagoId)? eliminarPago;
  final Future<void> Function(String uid, Movimiento movimiento)?
  guardarMovimiento;

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
        ? streamPagosUsuario(widget.uid)
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
            formatearMoneda(saldoPendiente),
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
                      ? formatearMoneda(pago.monto)
                      : formatearMoneda(saldo),
                  style: const TextStyle(
                    color: Color(0xFFF3F6FC),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  key: Key('payment_edit_${pago.id}'),
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: Color(0xFF8792A5),
                  ),
                  tooltip: 'Editar deuda',
                  onPressed: _procesando ? null : () => _editarDeuda(pago),
                ),
                IconButton(
                  key: Key('payment_delete_${pago.id}'),
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    size: 18,
                    color: Color(0xFFFF8798),
                  ),
                  tooltip: 'Eliminar deuda',
                  onPressed: _procesando ? null : () => _eliminarDeuda(pago),
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
                  'Abonado ${formatearMoneda(pago.montoPagado)} de '
                  '${formatearMoneda(pago.monto)}',
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
            ] else if (pago.estado == 'no_pagado') ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    key: Key('payment_reactivate_${pago.id}'),
                    onPressed: _procesando ? null : () => _reactivarDeuda(pago),
                    icon: const Icon(Icons.replay_rounded, size: 18),
                    label: const Text('Reactivar'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF55D6A0),
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
                    decoration: decoracionAcceso(
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
                    decoration: decoracionAcceso(
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
                'Saldo pendiente: ${formatearMoneda(pago.saldoPendiente)}',
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
                decoration: decoracionAcceso(
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
                    return 'Ingresa un monto hasta ${formatearMoneda(pago.saldoPendiente)}';
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
                          if (widget.guardarMovimiento != null) {
                            await widget.guardarMovimiento!(
                              widget.uid,
                              Movimiento(
                                categoria: CategoriaMovimiento.gastos,
                                monto: monto,
                                descripcion: 'Pago de deuda: ${pago.titulo}',
                                fecha: DateTime.now(),
                              ),
                            );
                          }
                        } else {
                          final nuevoMontoPagado = double.parse(
                            (pago.montoPagado + monto).toStringAsFixed(2),
                          );
                          final firestore = FirebaseFirestore.instance;
                          final batch = firestore.batch();
                          final pagoRef = firestore
                              .collection('usuarios')
                              .doc(widget.uid)
                              .collection('pagos')
                              .doc(pago.id);
                          batch.update(pagoRef, {
                            'monto_pagado': nuevoMontoPagado,
                            'estado': nuevoMontoPagado >= pago.monto
                                ? 'pagado'
                                : 'pendiente',
                            'fecha_pago': FieldValue.serverTimestamp(),
                          });

                          final movimientoRef = firestore
                              .collection('usuarios')
                              .doc(widget.uid)
                              .collection('movimientos')
                              .doc();
                          batch.set(movimientoRef, {
                            'monto': monto,
                            'categoria': 'gastos',
                            'descripcion': 'Pago de deuda: ${pago.titulo}',
                            'fecha': FieldValue.serverTimestamp(),
                          });

                          await batch.commit();
                        }
                      },
                      mensajeExito:
                          'Abono de ${formatearMoneda(monto)} registrado.',
                    );
                    if (exito && dialogContext.mounted) {
                      Navigator.of(dialogContext).pop();
                      await _mostrarNotificacionNativa(
                        '✅ Pago Confirmado',
                        'Se registró tu pago de ${formatearMoneda(monto)} '
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

  Future<void> _reactivarDeuda(Pago pago) async {
    await _ejecutarAccion(() async {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(widget.uid)
          .collection('pagos')
          .doc(pago.id)
          .update({'estado': 'pendiente'});
    }, mensajeExito: 'La deuda se reactivó como pendiente.');
  }

  Future<void> _eliminarDeuda(Pago pago) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF151D2B),
        title: const Text(
          'Eliminar deuda / recordatorio',
          style: TextStyle(color: Color(0xFFF3F6FC)),
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar "${pago.titulo}"? Esta acción no se puede deshacer.',
          style: const TextStyle(color: Color(0xFF9AA6B8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            key: Key('payment_delete_confirm_${pago.id}'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFF7187),
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmado != true) return;

    await _ejecutarAccion(() async {
      final eliminar = widget.eliminarPago;
      if (eliminar != null) {
        await eliminar(widget.uid, pago.id);
      } else {
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(widget.uid)
            .collection('pagos')
            .doc(pago.id)
            .delete();
      }
    }, mensajeExito: 'Deuda eliminada correctamente.');
  }

  Future<void> _editarDeuda(Pago pago) async {
    final formKey = GlobalKey<FormState>();
    final tituloController = TextEditingController(text: pago.titulo);
    final montoController = TextEditingController(
      text: pago.monto.toStringAsFixed(2),
    );
    DateTime fechaSeleccionada = pago.fechaLimite;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF151D2B),
          title: const Text(
            'Editar deuda',
            style: TextStyle(color: Color(0xFFF3F6FC)),
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    key: Key('payment_edit_title_${pago.id}'),
                    controller: tituloController,
                    textCapitalization: TextCapitalization.sentences,
                    maxLength: 60,
                    decoration: decoracionAcceso(
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
                    key: Key('payment_edit_amount_${pago.id}'),
                    controller: montoController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: decoracionAcceso(
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
                          monto < pago.montoPagado) {
                        return 'Debe ser al menos lo ya abonado (${formatearMoneda(pago.montoPagado)})';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.calendar_month_outlined,
                      color: Color(0xFF55D6A0),
                    ),
                    title: Text(
                      '${fechaSeleccionada.day.toString().padLeft(2, '0')}/'
                      '${fechaSeleccionada.month.toString().padLeft(2, '0')}/'
                      '${fechaSeleccionada.year}',
                      style: const TextStyle(color: Color(0xFFF3F6FC)),
                    ),
                    trailing: TextButton(
                      onPressed: () async {
                        final seleccionada = await showDatePicker(
                          context: context,
                          initialDate: fechaSeleccionada,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now().add(
                            const Duration(days: 3650),
                          ),
                        );
                        if (seleccionada != null) {
                          setDialogState(() {
                            fechaSeleccionada = seleccionada;
                          });
                        }
                      },
                      child: const Text('Cambiar'),
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
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final nuevoMonto = double.parse(
                  montoController.text.trim().replaceAll(',', '.'),
                );
                final nuevoEstado = pago.montoPagado >= nuevoMonto
                    ? 'pagado'
                    : (pago.estado == 'no_pagado' ? 'no_pagado' : 'pendiente');
                await _ejecutarAccion(() async {
                  await FirebaseFirestore.instance
                      .collection('usuarios')
                      .doc(widget.uid)
                      .collection('pagos')
                      .doc(pago.id)
                      .update({
                        'titulo': tituloController.text.trim(),
                        'monto': nuevoMonto,
                        'estado': nuevoEstado,
                        'fecha_limite': Timestamp.fromDate(fechaSeleccionada),
                      });
                }, mensajeExito: 'Deuda actualizada correctamente.');
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
              },
              child: const Text('Guardar cambios'),
            ),
          ],
        ),
      ),
    );
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
