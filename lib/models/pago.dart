import 'package:cloud_firestore/cloud_firestore.dart';

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

Pago pagoDesdeDatos(String id, Map<String, dynamic> datos) {
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
