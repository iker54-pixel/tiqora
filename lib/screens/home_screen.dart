import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/producto.dart';
import '../services/db_service.dart';
import 'anadir_producto_screen.dart';
import 'detalle_producto_screen.dart';
import 'premium_screen.dart';

const int LIMITE_PLAN_GRATIS = 5;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Producto> _productos = [];
  bool _esPremium = false; // TODO: conectar con el estado real de suscripción
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  Future<void> _cargarProductos() async {
    setState(() => _cargando = true);
    final productos = await DBService.instance.obtenerProductos();
    setState(() {
      _productos = productos;
      _cargando = false;
    });
  }

  void _irAAnadirProducto() {
    if (!_esPremium && _productos.length >= LIMITE_PLAN_GRATIS) {
      _mostrarLimiteAlcanzado();
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AnadirProductoScreen()),
    ).then((_) => _cargarProductos());
  }

  void _mostrarLimiteAlcanzado() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(28),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.lock_outline, color: AppColors.black, size: 32),
            const SizedBox(height: 12),
            const Text(
              'Has llegado a los 5 productos gratis',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pasa a Premium para guardar productos ilimitados, compartir con tu familia y generar reclamaciones de garantía.',
              style: TextStyle(color: AppColors.greyText, fontSize: 15),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumScreen()));
                },
                child: const Text('Ver Tiqora Premium'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tiqora'),
        actions: [
          if (!_esPremium)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: TextButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PremiumScreen()),
                ),
                icon: const Icon(Icons.bolt, color: AppColors.black, size: 18),
                label: const Text('Premium', style: TextStyle(color: AppColors.black)),
              ),
            ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator(color: AppColors.black))
          : _productos.isEmpty
              ? _EstadoVacio(onAnadir: _irAAnadirProducto)
              : RefreshIndicator(
                  onRefresh: _cargarProductos,
                  color: AppColors.black,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                    children: [
                      if (!_esPremium) _BarraLimite(usados: _productos.length),
                      const SizedBox(height: 8),
                      ..._productos.map((p) => _TarjetaProducto(
                            producto: p,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DetalleProductoScreen(producto: p),
                                ),
                              ).then((_) => _cargarProductos());
                            },
                          )),
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _irAAnadirProducto,
        icon: const Icon(Icons.add),
        label: const Text('Añadir producto', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _BarraLimite extends StatelessWidget {
  final int usados;
  const _BarraLimite({required this.usados});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.greyBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.inventory_2_outlined, size: 18, color: AppColors.greyText),
          const SizedBox(width: 8),
          Text(
            '$usados de $LIMITE_PLAN_GRATIS productos usados (plan gratis)',
            style: const TextStyle(color: AppColors.greyText, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _TarjetaProducto extends StatelessWidget {
  final Producto producto;
  final VoidCallback onTap;

  const _TarjetaProducto({required this.producto, required this.onTap});

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

  String _textoEstado() {
    if (producto.estado == 'caducada') return 'Garantía caducada';
    if (producto.estado == 'porCaducar') return 'Caduca en ${producto.diasRestantes} días';
    return 'Garantía activa · ${producto.diasRestantes} días';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.receipt_long, color: AppColors.lime),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      producto.nombre,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(color: _colorEstado(), shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _textoEstado(),
                            style: TextStyle(fontSize: 13, color: AppColors.greyText),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.greyText),
            ],
          ),
        ),
      ),
    );
  }
}

class _EstadoVacio extends StatelessWidget {
  final VoidCallback onAnadir;
  const _EstadoVacio({required this.onAnadir});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(color: AppColors.black, borderRadius: BorderRadius.circular(24)),
              child: const Icon(Icons.receipt_long, color: AppColors.lime, size: 40),
            ),
            const SizedBox(height: 24),
            const Text(
              'Aún no tienes productos guardados',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Haz una foto a tu próximo ticket y nunca más pierdas una garantía.',
              style: TextStyle(color: AppColors.greyText),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAnadir,
              icon: const Icon(Icons.add_a_photo_outlined),
              label: const Text('Añadir mi primer producto'),
            ),
          ],
        ),
      ),
    );
  }
}
