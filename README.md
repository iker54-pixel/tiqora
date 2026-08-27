# Tiqora

App para guardar tickets y facturas, no perder garantías, y reclamar cuando algo falla.

## Qué incluye este proyecto

- **Pantalla principal**: lista de productos con estado de garantía (activa / por caducar / caducada)
- **Añadir producto**: foto del ticket + lectura automática (OCR) de fecha, tienda e importe
- **Detalle del producto**: toda la información + botón de reclamación
- **Reclamación asistida**: genera el texto legal de reclamación citando la normativa española (Ley de Garantías, 3 años desde 2022), listo para enviar por email/WhatsApp
- **Notificaciones**: aviso automático 30 y 7 días antes de que caduque cada garantía
- **Paywall Premium**: gratis hasta 5 productos, de pago para ilimitados

Todo el diseño sigue tu paleta: negro + blanco + verde lima, estilo minimalista.

## ⚠️ Antes de compilar, necesitas hacer esto tú

Este código está completo y listo, pero hay 3 cosas que **no puedo hacer yo** porque necesitan tu ordenador o tus cuentas:

### 1. Instalar Flutter en tu ordenador
Si no lo tienes: https://docs.flutter.dev/get-started/install
Comprueba que funciona con `flutter doctor`.

### 2. Descargar las dependencias
Dentro de la carpeta del proyecto:
```
flutter pub get
```

### 3. Conectar las compras dentro de la app (Premium)
En `lib/screens/premium_screen.dart` hay dos botones marcados con `// TODO: conectar in_app_purchase`.
Para que funcionen de verdad, tienes que:
- Crear los productos de suscripción en Google Play Console y App Store Connect (con los mismos IDs en ambos, ej: `tiqora_premium_mensual`, `tiqora_premium_anual`)
- Usar el paquete `in_app_purchase` (ya está en el `pubspec.yaml`) para conectarlos — esto requiere tener las cuentas de desarrollador ya creadas (25$ un pago único en Google, 99$/año en Apple)

### 4. Icono de la app
Sustituye los iconos por defecto en `android/app/src/main/res/` y `ios/Runner/Assets.xcassets/` por el logo de Tiqora (negro + verde lima). Te puedo ayudar a diseñarlo cuando quieras.

## Cómo probarlo

Con un móvil conectado por USB (modo desarrollador activado) o un emulador:
```
flutter run
```

## Cómo generar el archivo para subir a las tiendas

**Android** (genera un `.aab`, el formato que pide Google Play):
```
flutter build appbundle --release
```
El archivo aparece en `build/app/outputs/bundle/release/app-release.aab`

**iPhone** (necesitas un Mac con Xcode instalado):
```
flutter build ios --release
```
Luego se sube a App Store Connect desde Xcode o con Transporter.

## Estructura del proyecto

```
lib/
  main.dart                    → arranque de la app
  theme/app_theme.dart         → colores y estilos
  models/producto.dart         → estructura de datos de un producto
  services/
    db_service.dart            → base de datos local (SQLite)
    ocr_service.dart           → lectura del ticket con la cámara
    notificaciones_service.dart→ avisos antes de que caduque la garantía
    reclamacion_service.dart   → genera el texto legal de reclamación
  screens/
    home_screen.dart           → lista de productos
    anadir_producto_screen.dart→ añadir producto nuevo
    detalle_producto_screen.dart → ver un producto
    reclamacion_screen.dart    → generar la reclamación
    premium_screen.dart        → pantalla de suscripción
```

## Aviso legal importante

El texto de reclamación en `reclamacion_service.dart` está basado en la normativa española vigente en el momento de escribir este código (Real Decreto-ley 7/2021). **Antes de publicar la app, pide a un profesional legal que revise este texto** para confirmar que sigue siendo correcto y aplicable — las leyes cambian, y un texto legal incorrecto en una app real puede generar problemas serios.
