/// Representa un producto guardado en Tiqora, con su ticket y garantía.
class Producto {
  final int? id;
  final String nombre;
  final String categoria; // Electrodoméstico, Móvil, Mueble, Otro...
  final String tienda;
  final DateTime fechaCompra;
  final int mesesGarantia; // Por defecto 36 (3 años, Ley de Garantías UE 2022)
  final double? importe;
  final String? rutaFotoTicket; // Ruta local de la imagen del ticket
  final String? notas;
  final String? numeroSerie;

  Producto({
    this.id,
    required this.nombre,
    required this.categoria,
    required this.tienda,
    required this.fechaCompra,
    this.mesesGarantia = 36,
    this.importe,
    this.rutaFotoTicket,
    this.notas,
    this.numeroSerie,
  });

  /// Fecha en la que caduca la garantía
  DateTime get fechaCaducidad {
    return DateTime(
      fechaCompra.year,
      fechaCompra.month + mesesGarantia,
      fechaCompra.day,
    );
  }

  /// Días restantes de garantía (negativo si ya caducó)
  int get diasRestantes {
    return fechaCaducidad.difference(DateTime.now()).inDays;
  }

  /// Estado visual: 'activa', 'porCaducar' (<30 días), 'caducada'
  String get estado {
    if (diasRestantes < 0) return 'caducada';
    if (diasRestantes <= 30) return 'porCaducar';
    return 'activa';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'categoria': categoria,
      'tienda': tienda,
      'fechaCompra': fechaCompra.toIso8601String(),
      'mesesGarantia': mesesGarantia,
      'importe': importe,
      'rutaFotoTicket': rutaFotoTicket,
      'notas': notas,
      'numeroSerie': numeroSerie,
    };
  }

  factory Producto.fromMap(Map<String, dynamic> map) {
    return Producto(
      id: map['id'] as int?,
      nombre: map['nombre'] as String,
      categoria: map['categoria'] as String,
      tienda: map['tienda'] as String,
      fechaCompra: DateTime.parse(map['fechaCompra'] as String),
      mesesGarantia: map['mesesGarantia'] as int,
      importe: map['importe'] as double?,
      rutaFotoTicket: map['rutaFotoTicket'] as String?,
      notas: map['notas'] as String?,
      numeroSerie: map['numeroSerie'] as String?,
    );
  }

  Producto copyWith({
    int? id,
    String? nombre,
    String? categoria,
    String? tienda,
    DateTime? fechaCompra,
    int? mesesGarantia,
    double? importe,
    String? rutaFotoTicket,
    String? notas,
    String? numeroSerie,
  }) {
    return Producto(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      categoria: categoria ?? this.categoria,
      tienda: tienda ?? this.tienda,
      fechaCompra: fechaCompra ?? this.fechaCompra,
      mesesGarantia: mesesGarantia ?? this.mesesGarantia,
      importe: importe ?? this.importe,
      rutaFotoTicket: rutaFotoTicket ?? this.rutaFotoTicket,
      notas: notas ?? this.notas,
      numeroSerie: numeroSerie ?? this.numeroSerie,
    );
  }
}

const List<String> categoriasProducto = [
  'Electrodoméstico',
  'Móvil / Tecnología',
  'Mueble',
  'Ropa / Calzado',
  'Herramienta',
  'Otro',
];
