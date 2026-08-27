import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../models/producto.dart';

/// Gestiona las notificaciones locales: avisa 30 y 7 días antes
/// de que caduque la garantía de cada producto.
class NotificacionesService {
  static final NotificacionesService instance = NotificacionesService._init();
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _inicializado = false;

  NotificacionesService._init();

  Future<void> inicializar() async {
    if (_inicializado) return;
    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _plugin.initialize(settings);
    _inicializado = true;
  }

  /// Programa los avisos de un producto: 30 días y 7 días antes de caducar.
  Future<void> programarAvisosGarantia(Producto producto) async {
    if (producto.id == null) return;

    final fechaCaducidad = producto.fechaCaducidad;

    await _programarNotificacion(
      id: producto.id! * 10 + 1,
      titulo: 'Tu garantía caduca pronto',
      cuerpo: '${producto.nombre} pierde la garantía en 30 días. Revisa si todo está en orden.',
      fecha: fechaCaducidad.subtract(const Duration(days: 30)),
    );

    await _programarNotificacion(
      id: producto.id! * 10 + 2,
      titulo: '¡Última semana de garantía!',
      cuerpo: '${producto.nombre} pierde la garantía en 7 días.',
      fecha: fechaCaducidad.subtract(const Duration(days: 7)),
    );
  }

  Future<void> _programarNotificacion({
    required int id,
    required String titulo,
    required String cuerpo,
    required DateTime fecha,
  }) async {
    // No programar notificaciones en el pasado
    if (fecha.isBefore(DateTime.now())) return;

    const androidDetails = AndroidNotificationDetails(
      'tiqora_garantias',
      'Avisos de garantía',
      channelDescription: 'Notificaciones antes de que caduque una garantía',
      importance: Importance.high,
      priority: Priority.high,
      color: Color(0xFFC6FF00),
    );
    const details = NotificationDetails(android: androidDetails, iOS: DarwinNotificationDetails());

    await _plugin.zonedSchedule(
      id,
      titulo,
      cuerpo,
      tz.TZDateTime.from(fecha, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelarAvisos(int productoId) async {
    await _plugin.cancel(productoId * 10 + 1);
    await _plugin.cancel(productoId * 10 + 2);
  }
}
