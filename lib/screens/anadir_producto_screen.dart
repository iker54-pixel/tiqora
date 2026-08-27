import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../models/producto.dart';
import '../services/db_service.dart';
import '../services/ocr_service.dart';
import '../services/notificaciones_service.dart';

class AnadirProductoScreen extends StatefulWidget {
  const AnadirProductoScreen({super.key});

  @override
  State<AnadirProductoScreen> createState() => _AnadirProductoScreenState();
}

class _AnadirProductoScreenState extends State<AnadirProductoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ocrService = OcrService();

  File? _imagenTicket;
  bool _analizando = false;

  final _nombreCtrl = TextEditingController();
  final _tiendaCtrl = TextEditingController();
  final _importeCtrl = TextEditingController();
  final _serieCtrl = TextEditingController();
  DateTime _fechaCompra = DateTime.now();
  int _mesesGarantia = 24;
  String _categoria = categoriasProducto.first;

  Future<void> _tomarFoto() async {
    final picker = ImagePicker();
    final foto = await picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (foto == null) return;

    setState(() {
      _imagenTicket = File(foto.path);
      _analizando = true;
    });

    try {
      final datos = await _ocrService.analizarTicket(_imagenTicket!);
      setState(() {
        if (datos.fecha != null) _fechaCompra = datos.fecha!;
        if (datos.tienda != null) _tiendaCtrl.text = datos.tienda!;
        if (datos.importe != null) _importeCtrl.text = datos.importe!.toStringAsFixed(2);
      });
    } catch (e) {
      // Si el OCR falla, el usuario simplemente rellena a mano.
      // No bloqueamos el flujo por un fallo de lectura automática.
    } finally {
      setState(() => _analizando = false);
    }
  }

  Future<void> _elegirDeGaleria() async {
    final picker = ImagePicker();
    final foto = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (foto == null) return;
    setState(() {
      _imagenTicket = File(foto.path);
      _analizando = true;
    });
    try {
      final datos = await _ocrService.analizarTicket(_imagenTicket!);
      setState(() {
        if (datos.fecha != null) _fechaCompra = datos.fecha!;
        if (datos.tienda != null) _tiendaCtrl.text = datos.tienda!;
        if (datos.importe != null) _importeCtrl.text = datos.importe!.toStringAsFixed(2);
      });
    } finally {
      setState(() => _analizando = false);
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final producto = Producto(
      nombre: _nombreCtrl.text.trim(),
      categoria: _categoria,
      tienda: _tiendaCtrl.text.trim(),
      fechaCompra: _fechaCompra,
      mesesGarantia: _mesesGarantia,
      importe: double.tryParse(_importeCtrl.text.replaceAll(',', '.')),
      rutaFotoTicket: _imagenTicket?.path,
      numeroSerie: _serieCtrl.text.trim().isEmpty ? null : _serieCtrl.text.trim(),
    );

    final guardado = await DBService.instance.crearProducto(producto);
    await NotificacionesService.instance.programarAvisosGarantia(guardado);

    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _ocrService.dispose();
    _nombreCtrl.dispose();
    _tiendaCtrl.dispose();
    _importeCtrl.dispose();
    _serieCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo producto')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _SelectorFoto(
              imagen: _imagenTicket,
              analizando: _analizando,
              onTomarFoto: _tomarFoto,
              onGaleria: _elegirDeGaleria,
            ),
            if (_analizando)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                    SizedBox(width: 10),
                    Text('Leyendo el ticket...', style: TextStyle(color: AppColors.greyText)),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nombreCtrl,
              decoration: const InputDecoration(labelText: 'Nombre del producto'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Obligatorio' : null,
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _categoria,
              decoration: const InputDecoration(labelText: 'Categoría'),
              items: categoriasProducto
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _categoria = v!),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _tiendaCtrl,
              decoration: const InputDecoration(labelText: 'Tienda'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Obligatorio' : null,
            ),
            const SizedBox(height: 14),
            InkWell(
              onTap: () async {
                final fecha = await showDatePicker(
                  context: context,
                  initialDate: _fechaCompra,
                  firstDate: DateTime(2015),
                  lastDate: DateTime.now(),
                );
                if (fecha != null) setState(() => _fechaCompra = fecha);
              },
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Fecha de compra'),
                child: Text('${_fechaCompra.day}/${_fechaCompra.month}/${_fechaCompra.year}'),
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<int>(
              initialValue: _mesesGarantia,
              decoration: const InputDecoration(labelText: 'Meses de garantía'),
              items: const [12, 24, 36, 48, 60]
                  .map((m) => DropdownMenuItem(value: m, child: Text('$m meses')))
                  .toList(),
              onChanged: (v) => setState(() => _mesesGarantia = v!),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _importeCtrl,
              decoration: const InputDecoration(labelText: 'Importe (€)'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _serieCtrl,
              decoration: const InputDecoration(labelText: 'Número de serie (opcional)'),
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: _guardar,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text('Guardar producto'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectorFoto extends StatelessWidget {
  final File? imagen;
  final bool analizando;
  final VoidCallback onTomarFoto;
  final VoidCallback onGaleria;

  const _SelectorFoto({
    required this.imagen,
    required this.analizando,
    required this.onTomarFoto,
    required this.onGaleria,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.greyBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.greyBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: imagen != null
          ? Stack(
              fit: StackFit.expand,
              children: [
                Image.file(imagen!, fit: BoxFit.cover),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: FloatingActionButton.small(
                    heroTag: 'cambiarFoto',
                    onPressed: onTomarFoto,
                    child: const Icon(Icons.refresh),
                  ),
                ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.receipt_long, size: 40, color: AppColors.greyText),
                const SizedBox(height: 12),
                const Text('Foto del ticket', style: TextStyle(color: AppColors.greyText)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: onTomarFoto,
                      icon: const Icon(Icons.camera_alt_outlined, size: 18),
                      label: const Text('Cámara'),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton.icon(
                      onPressed: onGaleria,
                      icon: const Icon(Icons.photo_library_outlined, size: 18),
                      label: const Text('Galería'),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
