import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../theme/app_theme.dart';
import '../models/producto.dart';
import '../services/reclamacion_service.dart';

class ReclamacionScreen extends StatefulWidget {
  final Producto producto;
  const ReclamacionScreen({super.key, required this.producto});

  @override
  State<ReclamacionScreen> createState() => _ReclamacionScreenState();
}

class _ReclamacionScreenState extends State<ReclamacionScreen> {
  final _nombreCtrl = TextEditingController();
  final _problemaCtrl = TextEditingController();
  String? _textoGenerado;

  void _generar() {
    if (_nombreCtrl.text.trim().isEmpty || _problemaCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rellena tu nombre y describe el problema')),
      );
      return;
    }
    setState(() {
      _textoGenerado = ReclamacionService.generarTextoReclamacion(
        producto: widget.producto,
        nombreUsuario: _nombreCtrl.text.trim(),
        descripcionProblema: _problemaCtrl.text.trim(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final legalVigente = ReclamacionService.tieneGarantiaLegalVigente(widget.producto);

    return Scaffold(
      appBar: AppBar(title: const Text('Reclamar garantía')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (!legalVigente)
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.warning, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Este producto ya ha superado el plazo de garantía legal mínima (3 años). La reclamación puede no prosperar, pero puedes intentarlo igualmente.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

          if (_textoGenerado == null) ...[
            TextField(
              controller: _nombreCtrl,
              decoration: const InputDecoration(labelText: 'Tu nombre completo'),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _problemaCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Describe el problema',
                hintText: 'Ej: el producto ha dejado de encender tras un uso normal',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _generar,
              child: const Text('Generar escrito de reclamación'),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.greyBackground,
                borderRadius: BorderRadius.circular(14),
              ),
              child: SelectableText(_textoGenerado!, style: const TextStyle(fontSize: 14, height: 1.5)),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => setState(() => _textoGenerado = null),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Editar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Share.share(_textoGenerado!, subject: 'Reclamación de garantía - ${widget.producto.nombre}'),
                    icon: const Icon(Icons.send_outlined, size: 18),
                    label: const Text('Enviar'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Revisa el texto antes de enviarlo. Este contenido es orientativo y no sustituye el asesoramiento legal profesional.',
              style: TextStyle(color: AppColors.greyText, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
