import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum CategoriaMovimiento { ingresos, gastos, ahorro, inversion }

class Movimiento {
  const Movimiento({
    this.id = '',
    required this.categoria,
    required this.monto,
    required this.descripcion,
    required this.fecha,
  });

  final String id;
  final CategoriaMovimiento categoria;
  final double monto;
  final String descripcion;
  final DateTime fecha;
}

Movimiento movimientoDesdeDatos(String id, Map<String, dynamic> datos) {
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
    id: id,
    categoria: categoria,
    monto: monto.toDouble(),
    descripcion: descripcionOriginal as String? ?? '',
    fecha: fecha,
  );
}

class DetalleCategoria {
  const DetalleCategoria(this.titulo, this.color, this.icono);

  final String titulo;
  final Color color;
  final IconData icono;
}

DetalleCategoria detalleCategoria(CategoriaMovimiento categoria) {
  return switch (categoria) {
    CategoriaMovimiento.ingresos => const DetalleCategoria(
      'Ingresos',
      Color(0xFF55D6A0),
      Icons.south_west_rounded,
    ),
    CategoriaMovimiento.gastos => const DetalleCategoria(
      'Gastos',
      Color(0xFFFF7187),
      Icons.shopping_bag_outlined,
    ),
    CategoriaMovimiento.ahorro => const DetalleCategoria(
      'Ahorro',
      Color(0xFF62B6FF),
      Icons.savings_outlined,
    ),
    CategoriaMovimiento.inversion => const DetalleCategoria(
      'Inversión',
      Color(0xFFFFC56E),
      Icons.trending_up_rounded,
    ),
  };
}
