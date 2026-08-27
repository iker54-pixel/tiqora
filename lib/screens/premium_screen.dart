import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Pantalla de venta de Tiqora Premium.
/// La conexión real con in_app_purchase (Google Play / App Store) se
/// completa cuando compiles el proyecto y tengas los productos dados
/// de alta en cada consola de desarrollador.
class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.close, color: AppColors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(color: AppColors.lime, borderRadius: BorderRadius.circular(18)),
                child: const Icon(Icons.bolt, color: AppColors.black, size: 32),
              ),
              const SizedBox(height: 20),
              const Text(
                'Tiqora Premium',
                style: TextStyle(color: AppColors.white, fontSize: 28, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              const Text(
                'Todo tu hogar protegido, sin límites.',
                style: TextStyle(color: AppColors.greyText, fontSize: 16),
              ),
              const SizedBox(height: 32),
              const _Beneficio(texto: 'Productos ilimitados'),
              const _Beneficio(texto: 'Comparte con tu familia'),
              const _Beneficio(texto: 'Exporta tus garantías a PDF'),
              const _Beneficio(texto: 'Reclamaciones de garantía ilimitadas'),
              const Spacer(),
              _PlanCard(
                titulo: 'Mensual',
                precio: '2,99 €/mes',
                onTap: () {}, // TODO: conectar in_app_purchase
              ),
              const SizedBox(height: 12),
              _PlanCard(
                titulo: 'Anual · ahorra 33%',
                precio: '23,99 €/año',
                destacado: true,
                onTap: () {}, // TODO: conectar in_app_purchase
              ),
              const SizedBox(height: 16),
              const Text(
                'Cancela cuando quieras desde el ajuste de suscripciones de tu tienda.',
                style: TextStyle(color: AppColors.greyText, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Beneficio extends StatelessWidget {
  final String texto;
  const _Beneficio({required this.texto});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.lime, size: 20),
          const SizedBox(width: 10),
          Text(texto, style: const TextStyle(color: AppColors.white, fontSize: 15)),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String titulo;
  final String precio;
  final bool destacado;
  final VoidCallback onTap;

  const _PlanCard({
    required this.titulo,
    required this.precio,
    required this.onTap,
    this.destacado = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: destacado ? AppColors.lime : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: destacado ? AppColors.lime : AppColors.greyText),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              titulo,
              style: TextStyle(
                color: destacado ? AppColors.black : AppColors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            Text(
              precio,
              style: TextStyle(
                color: destacado ? AppColors.black : AppColors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
