import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/producto.dart';
import '../services/db_service.dart';
import '../services/notificaciones_service.dart';
import 'reclamacion_screen.dart';

class DetalleProductoScreen extends StatelessWidget {
  final Producto producto;
  const DetalleProductoScreen({super.key, required this.producto});

  Color _colorEstado() {
    switch (producto.estado) {
      case 'caducada':
        return AppColors.danger;
      case 'porCaducar':
        return AppColors.warning;
      default:
        return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatoFecha = DateFormat('dd MMM yyyy', 'es_ES');

    return Scaffold(
      appBar: AppBar(
        title: Text(producto.nombre),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final confirmar = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('¿Eliminar producto?'),
                  content: const Text('Esta acción no se puede deshacer.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
                  ],
                ),
              );
              if (confirmar == true && producto.id != null) {
                await DBService.instance.eliminarProducto(producto.id!);
                await NotificacionesService.instance.cancelarAvisos(producto.id!);
                if (context.mounted) Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (producto.rutaFotoTicket != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                File(producto.rutaFotoTicket!),
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          const SizedBox(height: 20),

          // Estado de la garantía, bien visible
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.black,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(color: _colorEstado(), shape: BoxShape.circle),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        producto.estado == 'caducada'
                            ? 'Garantía caducada'
                            : '${producto.diasRestantes} días de garantía restantes',
                        style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.w700, fontSize: 16),
                      ),
                      Text(
                        'Caduca el ${formatoFecha.format(producto.fechaCaducidad)}',
                        style: const TextStyle(color: AppColors.greyText, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          _FilaDato(etiqueta: 'Categoría', valor: producto.categoria),
          _FilaDato(etiqueta: 'Tienda', valor: producto.tienda),
          _FilaDato(etiqueta: 'Fecha de compra', valor: formatoFecha.format(producto.fechaCompra)),
          if (producto.importe != null)
            _FilaDato(etiqueta: 'Importe', valor: '${producto.importe!.toStringAsFixed(2)} €'),
          if (producto.numeroSerie != null)
            _FilaDato(etiqueta: 'Número de serie', valor: producto.numeroSerie!),

          const SizedBox(height: 28),

          // Botón de la función estrella: reclamación asistida
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ReclamacionScreen(producto: producto)),
              );
            },
            icon: const Icon(Icons.description_outlined),
            label: const Text('Reclamar esta garantía'),
          ),
          const SizedBox(height: 8),
          const Text(
            'Genera automáticamente el escrito de reclamación citando tu derecho legal.',
            style: TextStyle(color: AppColors.greyText, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _FilaDato extends StatelessWidget {
  final String etiqueta;
  final String valor;
  const _FilaDato({required this.etiqueta, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(etiqueta, style: const TextStyle(color: AppColors.greyText)),
          Text(valor, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
