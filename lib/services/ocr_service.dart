import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Resultado de analizar un ticket con OCR.
/// El usuario siempre puede corregir estos datos a mano: el OCR
/// es una ayuda, no una fuente de verdad infalible.
class DatosTicket {
  DateTime? fecha;
  String? tienda;
  double? importe;
  String textoCompleto;

  DatosTicket({this.fecha, this.tienda, this.importe, required this.textoCompleto});
}

/// Servicio de OCR usando Google ML Kit (funciona 100% offline,
/// no envía la imagen a ningún servidor - importante para la privacidad
/// de tickets con datos personales).
class OcrService {
  final _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<DatosTicket> analizarTicket(File imagen) async {
    final inputImage = InputImage.fromFile(imagen);
    final RecognizedText resultado = await _recognizer.processImage(inputImage);
    final texto = resultado.text;

    return DatosTicket(
      fecha: _extraerFecha(texto),
      tienda: _extraerTienda(resultado),
      importe: _extraerImporte(texto),
      textoCompleto: texto,
    );
  }

  /// Busca patrones de fecha típicos de tickets españoles: dd/mm/yyyy, dd-mm-yyyy, dd.mm.yyyy
  DateTime? _extraerFecha(String texto) {
    final patrones = [
      RegExp(r'(\d{2})[/\-.](\d{2})[/\-.](\d{4})'),
      RegExp(r'(\d{2})[/\-.](\d{2})[/\-.](\d{2})\b'),
    ];

    for (final patron in patrones) {
      final match = patron.firstMatch(texto);
      if (match != null) {
        try {
          final dia = int.parse(match.group(1)!);
          final mes = int.parse(match.group(2)!);
          var anio = int.parse(match.group(3)!);
          if (anio < 100) anio += 2000;

        if (dia.in12(1, 31) && mes.in12(1, 12)) {
            return DateTime(anio, mes, dia);
          }
        } catch (_) {
          continue;
        }
      }
    }
    return null;
  }

  /// Asume que la tienda suele aparecer en las primeras líneas del ticket
  String? _extraerTienda(RecognizedText resultado) {
    if (resultado.blocks.isEmpty) return null;
    final primeraLinea = resultado.blocks.first.lines.isNotEmpty
        ? resultado.blocks.first.lines.first.text
        : null;
    return primeraLinea?.trim();
  }

  /// Busca el importe total: patrones como "TOTAL 23,99" o "23,99 €"
  double? _extraerImporte(String texto) {
    final patronTotal = RegExp(
      r'TOTAL[:\s]*(\d+[.,]\d{2})',
      caseSensitive: false,
    );
    final matchTotal = patronTotal.firstMatch(texto);
    if (matchTotal != null) {
      final valor = matchTotal.group(1)!.replaceAll(',', '.');
      return double.tryParse(valor);
    }

    // Si no encuentra "TOTAL", busca cualquier importe con símbolo €
    final patronEuro = RegExp(r'(\d+[.,]\d{2})\s*€');
    final matches = patronEuro.allMatches(texto);
    if (matches.isNotEmpty) {
      final valor = matches.last.group(1)!.replaceAll(',', '.');
      return double.tryParse(valor);
    }
    return null;
  }

  void dispose() {
    _recognizer.close();
  }
}

extension on int {
  bool in12(int min, int max) => this >= min && this <= max;
}
