import 'package:intl/intl.dart';
import '../models/producto.dart';

/// Genera el texto de reclamación de garantía, citando la normativa
/// española/europea vigente, listo para copiar o enviar por email.
///
/// IMPORTANTE (nota para cuando se conecte con IA en el futuro):
/// Este texto está basado en el Real Decreto-ley 7/2021 y el Texto
/// Refundido de la Ley General para la Defensa de los Consumidores,
/// que desde el 1 de enero de 2022 establece 3 años de garantía legal
/// mínima en productos (2 años para contratos anteriores a esa fecha).
/// Antes de lanzar a producción, este texto debe ser revisado por un
/// profesional legal para confirmar que sigue vigente y es aplicable
/// al caso exacto del usuario.
class ReclamacionService {
  static const int mesesGarantiaLegalMinima = 36; // 3 años, UE desde 2022

  /// Genera el texto de la reclamación personalizado con los datos del producto.
  static String generarTextoReclamacion({
    required Producto producto,
    required String nombreUsuario,
    required String descripcionProblema,
  }) {
    final formatoFecha = DateFormat('dd/MM/yyyy', 'es_ES');
    final fechaCompraStr = formatoFecha.format(producto.fechaCompra);
    final fechaCaducidadStr = formatoFecha.format(producto.fechaCaducidad);
    final fechaHoy = formatoFecha.format(DateTime.now());

    return '''
Asunto: Reclamación por garantía - ${producto.nombre}

$fechaHoy

A la atención de ${producto.tienda}:

Mi nombre es $nombreUsuario y me dirijo a ustedes para ejercer mi derecho de garantía legal sobre el siguiente producto:

- Producto: ${producto.nombre}
- Fecha de compra: $fechaCompraStr
- Tienda: ${producto.tienda}
${producto.numeroSerie != null ? '- Número de serie: ${producto.numeroSerie}\n' : ''}${producto.importe != null ? '- Importe: ${producto.importe!.toStringAsFixed(2)} €\n' : ''}
Problema detectado:
$descripcionProblema

De acuerdo con el Texto Refundido de la Ley General para la Defensa de los Consumidores y Usuarios (Real Decreto Legislativo 1/2007, modificado por el Real Decreto-ley 7/2021), los productos cuentan con una garantía legal mínima de 3 años desde la fecha de entrega, dentro de la cual el vendedor responde de las faltas de conformidad del producto.

La garantía de este producto es válida hasta el $fechaCaducidadStr, por lo que la presente reclamación se encuentra dentro del plazo legal establecido.

Solicito, conforme a mis derechos como consumidor, que se proceda a la reparación o sustitución del producto sin coste alguno, o en su defecto, a la reducción del precio o resolución del contrato, según lo establecido en el artículo 118 y siguientes de dicha normativa.

Adjunto el justificante de compra como prueba de la transacción.

Quedo a la espera de su respuesta en un plazo razonable.

Atentamente,
$nombreUsuario
''';
  }

  /// Comprueba si el producto sigue teniendo garantía legal mínima
  /// aunque la tienda diga lo contrario (caso de garantías más cortas
  /// que la mínima legal, algo que a veces ocurre por desconocimiento).
  static bool tieneGarantiaLegalVigente(Producto producto) {
    final fechaLimiteLegal = DateTime(
      producto.fechaCompra.year,
      producto.fechaCompra.month + mesesGarantiaLegalMinima,
      producto.fechaCompra.day,
    );
    return DateTime.now().isBefore(fechaLimiteLegal);
  }
}
