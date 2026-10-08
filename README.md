# Control Financiero Pro

Aplicación Flutter adaptable a móvil y escritorio para consultar ingresos,
gastos, ahorro e inversión en un panel financiero.

## Ejecutar en Chrome

```powershell
flutter pub get
flutter run -d chrome
```

## Publicar automáticamente los cambios en Hosting

Para que cada guardado de código se publique en Firebase Hosting, ejecuta
desde PowerShell:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tool\hosting_watch.ps1
```

Deja esa terminal abierta mientras trabajas. Los cambios en `lib`, `web`,
`assets`, `pubspec.yaml`, `pubspec.lock` o `firebase.json` activan una
compilación web y, si termina correctamente, publican **solo Hosting**. Después
de que aparezca el mensaje `Listo`, recarga la página pública con `F5`; no hace
falta reiniciar Chrome. Cada publicación queda inmediatamente disponible para
cualquier persona que visite el enlace. Pulsa `Ctrl+C` en la terminal para
detener el observador.

## Funcionalidad actual

- Balance disponible calculado como ingresos menos gastos, ahorro e inversión.
- Resumen visual con tarjetas compactas para las cuatro categorías.
- Registro de movimientos con monto, categoría y descripción opcional.
- Actualización del balance y actividad reciente al guardar un movimiento.
- Perfiles y movimientos sincronizados con Firebase y consultables en el panel
  administrativo, que es de solo lectura.
- Registro privado de pagos y deudas, abonos parciales, saldo pendiente y
  avisos dentro de la aplicación para vencimientos próximos o atrasados.
- Interfaz adaptable a pantallas pequeñas y grandes.

Los movimientos y pagos se guardan en Firestore dentro del perfil de cada
usuario. Los avisos de vencimiento se muestran dentro de la aplicación; no son
notificaciones push del sistema.

## Verificaciones

```powershell
flutter test test\widget_test.dart
dart analyze lib\main.dart test\widget_test.dart
```
