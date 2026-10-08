import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_finanzas/main.dart';

void main() {
  testWidgets('shows the financial overview with compact category cards', (
    tester,
  ) async {
    await tester.pumpWidget(
      MiAppFinanzasPro(
        escucharSesion: () => Stream.value(_sesionPrueba),
        escucharRol: (_) => Stream.value(null),
        escucharMovimientos: (_) => Stream.value(_movimientosBase),
        escucharPagos: (_) => Stream.value([]),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Resumen financiero'), findsOneWidget);
    expect(find.text('Conectado como user@example.com'), findsOneWidget);
    expect(find.byKey(const Key('available_balance')), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const Key('available_balance'))).data,
      '\$750.00',
    );
    expect(find.byKey(const Key('movement_sync_status')), findsNothing);
    expect(find.text('Ingresos'), findsOneWidget);
    expect(find.text('Gastos'), findsOneWidget);
    expect(find.text('Ahorro'), findsOneWidget);
    expect(find.text('Inversión'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('records a movement and updates the available balance', (
    tester,
  ) async {
    final movimientosController = StreamController<List<Movimiento>>();
    final movimientos = List<Movimiento>.of(_movimientosBase);
    movimientosController.add(movimientos);
    Movimiento? savedMovement;
    await tester.pumpWidget(
      MiAppFinanzasPro(
        escucharSesion: () => Stream.value(_sesionPrueba),
        escucharRol: (_) => Stream.value(null),
        escucharMovimientos: (uid) {
          expect(uid, _sesionPrueba.uid);
          return movimientosController.stream;
        },
        escucharPagos: (_) => Stream.value([]),
        guardarMovimiento: (uid, movement) async {
          expect(uid, _sesionPrueba.uid);
          savedMovement = movement;
          movimientos.add(movement);
          movimientosController.add(List<Movimiento>.of(movimientos));
        },
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Nuevo movimiento'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('movement_amount')), '125');
    await tester.tap(find.byType(DropdownButtonFormField<CategoriaMovimiento>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ingresos').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guardar movimiento'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('available_balance')), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const Key('available_balance'))).data,
      '\$875.00',
    );
    expect(find.text('Movimiento registrado correctamente'), findsOneWidget);
    expect(savedMovement?.monto, 125);
    expect(savedMovement?.categoria, CategoriaMovimiento.ingresos);
    expect(tester.takeException(), isNull);

    await movimientosController.close();
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('shows due-payment alert and opens the payments list', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1365, 768);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final pagos = [
      Pago(
        id: 'luz',
        titulo: 'Servicio de luz',
        monto: 85,
        fechaLimite: DateTime(tomorrow.year, tomorrow.month, tomorrow.day),
        estado: 'pendiente',
        montoPagado: 0,
      ),
      Pago(
        id: 'lejos',
        titulo: 'Pago futuro',
        monto: 120,
        fechaLimite: DateTime.now().add(const Duration(days: 5)),
        estado: 'pendiente',
        montoPagado: 0,
      ),
    ];
    await tester.pumpWidget(
      MiAppFinanzasPro(
        escucharSesion: () => Stream.value(_sesionPrueba),
        escucharRol: (_) => Stream.value(null),
        escucharMovimientos: (_) => Stream.value(_movimientosBase),
        escucharPagos: (uid) {
          expect(uid, _sesionPrueba.uid);
          return Stream.value(pagos);
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mis deudas'), findsOneWidget);
    expect(find.byKey(const Key('payment_alert_luz')), findsOneWidget);
    expect(find.text('Vence mañana'), findsOneWidget);
    expect(find.byKey(const Key('payment_alert_lejos')), findsNothing);
    await tester.tap(find.byKey(const Key('open_user_payments')));
    await tester.pumpAndSettle();
    expect(find.text('Pagos y recordatorios'), findsOneWidget);
    expect(find.text('Servicio de luz'), findsOneWidget);
    expect(find.text('Pago futuro'), findsOneWidget);
    expect(find.byKey(const Key('payment_add_button')), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('registers a debt and handles partial and full payments', (
    tester,
  ) async {
    final pagosController = StreamController<List<Pago>>();
    final pagos = <Pago>[];
    pagosController.add(pagos);
    Pago? pagoRegistrado;
    final abonos = <double>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: PantallaPagos(
          uid: _sesionPrueba.uid,
          escucharPagos: (_) => pagosController.stream,
          registrarPago: (uid, pago) async {
            expect(uid, _sesionPrueba.uid);
            pagoRegistrado = pago;
            pagos.add(
              Pago(
                id: 'internet',
                titulo: pago.titulo,
                monto: pago.monto,
                fechaLimite: pago.fechaLimite,
                estado: 'pendiente',
                montoPagado: 0,
              ),
            );
            pagosController.add(List<Pago>.of(pagos));
          },
          confirmarPago: (uid, id, monto, _) async {
            expect(uid, _sesionPrueba.uid);
            expect(id, 'internet');
            abonos.add(monto);
            final anterior = pagos.single;
            final total = double.parse(
              (anterior.montoPagado + monto).toStringAsFixed(2),
            );
            pagos[0] = Pago(
              id: anterior.id,
              titulo: anterior.titulo,
              monto: anterior.monto,
              fechaLimite: anterior.fechaLimite,
              estado: total >= anterior.monto ? 'pagado' : 'pendiente',
              montoPagado: total,
            );
            pagosController.add(List<Pago>.of(pagos));
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('payment_add_button')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('payment_title_input')),
      'Internet',
    );
    await tester.enterText(
      find.byKey(const Key('payment_amount_input')),
      '100',
    );
    await tester.tap(find.byKey(const Key('payment_due_date')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('payment_save_button')));
    await tester.pumpAndSettle();

    expect(pagoRegistrado?.titulo, 'Internet');
    expect(pagoRegistrado?.monto, 100);
    expect(find.text('Internet'), findsOneWidget);
    expect(find.text('Pago agregado a tus recordatorios.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('payment_pay_internet')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('payment_paid_amount_input')),
      '40',
    );
    await tester.tap(find.byKey(const Key('payment_confirm_button')));
    await tester.pumpAndSettle();
    expect(abonos, [40]);
    expect(find.textContaining('Abonado \$40.00 de \$100.00'), findsOneWidget);
    expect(
      tester
          .widget<Text>(find.byKey(const Key('payment_outstanding_total')))
          .data,
      '\$60.00',
    );

    await tester.tap(find.byKey(const Key('payment_pay_internet')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('payment_paid_amount_input')),
      '60',
    );
    await tester.tap(find.byKey(const Key('payment_confirm_button')));
    await tester.pumpAndSettle();
    expect(abonos, [40, 60]);
    expect(pagos.single.estado, 'pagado');
    await tester.pump();
    expect(find.textContaining('PAGADO'), findsOneWidget);
    expect(find.byKey(const Key('payment_pay_internet')), findsNothing);
    expect(tester.takeException(), isNull);

    await pagosController.close();
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('reports Firestore errors without updating the balance', (
    tester,
  ) async {
    await tester.pumpWidget(
      MiAppFinanzasPro(
        escucharSesion: () => Stream.value(_sesionPrueba),
        escucharRol: (_) => Stream.value(null),
        escucharMovimientos: (_) => Stream.value(_movimientosBase),
        escucharPagos: (_) => Stream.value([]),
        guardarMovimiento: (_, _) async {
          throw FirebaseException(
            plugin: 'cloud_firestore',
            message: 'Missing or insufficient permissions.',
          );
        },
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Nuevo movimiento'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('movement_amount')), '150');
    await tester.tap(find.text('Guardar movimiento'));
    await tester.pumpAndSettle();

    expect(
      tester.widget<Text>(find.byKey(const Key('available_balance'))).data,
      '\$750.00',
    );
    expect(
      find.textContaining('Missing or insufficient permissions.'),
      findsOneWidget,
    );
    expect(find.text('Movimiento registrado correctamente'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows listener errors and recovers when Firestore reconnects', (
    tester,
  ) async {
    final movimientosController = StreamController<List<Movimiento>>();
    movimientosController.add(_movimientosBase);

    await tester.pumpWidget(
      MiAppFinanzasPro(
        escucharSesion: () => Stream.value(_sesionPrueba),
        escucharRol: (_) => Stream.value(null),
        escucharMovimientos: (_) => movimientosController.stream,
        escucharPagos: (_) => Stream.value([]),
      ),
    );
    await tester.pumpAndSettle();

    movimientosController.addError(
      FirebaseException(
        plugin: 'cloud_firestore',
        message: 'Network unavailable.',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Network unavailable.'), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const Key('available_balance'))).data,
      '\$750.00',
    );

    movimientosController.add([
      ..._movimientosBase,
      Movimiento(
        categoria: CategoriaMovimiento.ahorro,
        monto: 150,
        descripcion: 'Ahorro sincronizado',
        fecha: DateTime(2026, 10, 7, 20),
      ),
    ]);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('movement_sync_status')), findsNothing);
    expect(
      tester.widget<Text>(find.byKey(const Key('available_balance'))).data,
      '\$600.00',
    );
    expect(find.text('Ahorro sincronizado'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await movimientosController.close();
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('shows login and validates credentials before authentication', (
    tester,
  ) async {
    var correoRecuperacion = '';
    await tester.pumpWidget(
      MiAppFinanzasPro(
        escucharSesion: () => Stream.value(null),
        recuperarContrasena: (correo) async {
          correoRecuperacion = correo;
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bienvenido de nuevo'), findsOneWidget);
    expect(find.byKey(const Key('auth_email')), findsOneWidget);
    expect(
      find.text(
        'Para cualquier información, contacto por:\n'
        'Teléfono: 0995220518\n'
        'Correo: alextravez29@gmail.com',
      ),
      findsOneWidget,
    );
    expect(find.byKey(const Key('auth_password')), findsOneWidget);
    await tester.tap(find.byKey(const Key('auth_submit')));
    await tester.pumpAndSettle();
    expect(find.text('Ingresa un correo electrónico válido'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('auth_email')),
      'test@example.com',
    );
    await tester.enterText(find.byKey(const Key('auth_password')), '123');
    await tester.tap(find.byKey(const Key('auth_submit')));
    await tester.pumpAndSettle();
    expect(
      find.text('La contraseña debe tener al menos 6 caracteres'),
      findsOneWidget,
    );

    await tester.ensureVisible(find.text('¿Olvidaste tu contraseña?'));
    await tester.tap(find.text('¿Olvidaste tu contraseña?'));
    await tester.pumpAndSettle();
    expect(find.text('Recuperar contraseña'), findsOneWidget);
    expect(
      tester
          .widget<TextFormField>(find.byKey(const Key('recovery_email')))
          .controller!
          .text,
      'test@example.com',
    );
    await tester.tap(find.byKey(const Key('recovery_submit')));
    await tester.pumpAndSettle();
    expect(correoRecuperacion, 'test@example.com');
    expect(find.byKey(const Key('auth_message')), findsOneWidget);

    await tester.tap(find.byKey(const Key('recovery_back')));
    await tester.pumpAndSettle();
    expect(find.text('Bienvenido de nuevo'), findsOneWidget);

    await tester.ensureVisible(find.text('¿Eres nuevo? Crea una cuenta'));
    await tester.tap(find.text('¿Eres nuevo? Crea una cuenta'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('registration_username')), findsOneWidget);
    await tester.tap(find.byKey(const Key('registration_back')));
    await tester.pumpAndSettle();
    expect(find.text('Bienvenido de nuevo'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('validates recovery email and reports Firebase errors', (
    tester,
  ) async {
    await tester.pumpWidget(
      MiAppFinanzasPro(
        escucharSesion: () => Stream.value(null),
        recuperarContrasena: (_) async {
          throw FirebaseAuthException(code: 'network-request-failed');
        },
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('¿Olvidaste tu contraseña?'));
    await tester.tap(find.text('¿Olvidaste tu contraseña?'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('recovery_submit')));
    await tester.pumpAndSettle();
    expect(find.text('Ingresa un correo electrónico válido'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('recovery_email')),
      'user@example.com',
    );
    await tester.tap(find.byKey(const Key('recovery_submit')));
    await tester.pumpAndSettle();
    expect(
      find.text('No hay conexión. Revisa tu internet e inténtalo de nuevo.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('signs in through Firebase Auth and opens the dashboard', (
    tester,
  ) async {
    final authController = StreamController<AuthenticatedSession?>();
    authController.add(null);
    var authenticatedEmail = '';
    await tester.pumpWidget(
      MiAppFinanzasPro(
        escucharSesion: () => authController.stream,
        escucharRol: (_) => Stream.value(null),
        iniciarSesion: (email, password) async {
          authenticatedEmail = email;
          expect(password, 'secure123');
          authController.add(_sesionPrueba);
        },
        cerrarSesion: () async => authController.add(null),
        escucharMovimientos: (_) => Stream.value(_movimientosBase),
        escucharPagos: (_) => Stream.value([]),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('auth_email')),
      'user@example.com',
    );
    await tester.enterText(find.byKey(const Key('auth_password')), 'secure123');
    await tester.tap(find.byKey(const Key('auth_submit')));
    await tester.pumpAndSettle();

    expect(authenticatedEmail, 'user@example.com');
    expect(find.text('Resumen financiero'), findsOneWidget);
    expect(find.byKey(const Key('sign_out')), findsOneWidget);

    await tester.tap(find.byKey(const Key('sign_out')));
    await tester.pumpAndSettle();
    expect(find.text('Bienvenido de nuevo'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await authController.close();
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('user can update profile phone and credentials securely', (
    tester,
  ) async {
    var storedUid = '';
    var storedPhone = '';
    var verifiedEmail = '';
    var updatedPassword = '';
    final reauthenticatedEmails = <String>[];
    final reauthenticatedPasswords = <String>[];
    await tester.pumpWidget(
      MiAppFinanzasPro(
        escucharSesion: () => Stream.value(_sesionPrueba),
        escucharRol: (_) => Stream.value(null),
        escucharMovimientos: (_) => Stream.value(_movimientosBase),
        escucharPagos: (_) => Stream.value([]),
        leerTelefonoPerfil: (uid) async {
          expect(uid, _sesionPrueba.uid);
          return '+593 99 111 2233';
        },
        guardarTelefonoPerfil: (uid, phone) async {
          storedUid = uid;
          storedPhone = phone;
        },
        reautenticarPerfil: (email, password) async {
          reauthenticatedEmails.add(email);
          reauthenticatedPasswords.add(password);
        },
        enviarCambioCorreoPerfil: (email) async {
          verifiedEmail = email;
        },
        actualizarContrasenaPerfil: (password) async {
          updatedPassword = password;
        },
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('open_user_profile')));
    await tester.pumpAndSettle();

    expect(find.text('Mi perfil'), findsOneWidget);
    expect(
      tester
          .widget<TextFormField>(find.byKey(const Key('profile_phone')))
          .controller!
          .text,
      '+593 99 111 2233',
    );
    await tester.enterText(
      find.byKey(const Key('profile_phone')),
      '+593 99 555 6677',
    );
    await tester.tap(find.byKey(const Key('profile_save_phone')));
    await tester.pumpAndSettle();
    expect(storedUid, _sesionPrueba.uid);
    expect(storedPhone, '+593 99 555 6677');
    expect(find.text('Teléfono actualizado en tu perfil.'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('profile_new_email')),
      'new@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('profile_email_password')),
      'old-password',
    );
    await tester.ensureVisible(
      find.byKey(const Key('profile_send_email_change')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('profile_send_email_change')));
    await tester.pumpAndSettle();
    expect(verifiedEmail, 'new@example.com');
    expect(reauthenticatedEmails, ['user@example.com']);
    expect(reauthenticatedPasswords, ['old-password']);
    expect(
      find.textContaining('Enviamos un enlace a new@example.com'),
      findsOneWidget,
    );

    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('profile_current_password')), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('profile_current_password')),
      'current-password',
    );
    await tester.enterText(
      find.byKey(const Key('profile_new_password')),
      'new-password-123',
    );
    await tester.ensureVisible(
      find.byKey(const Key('profile_update_password')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('profile_update_password')));
    await tester.pumpAndSettle();
    expect(updatedPassword, 'new-password-123');
    expect(reauthenticatedPasswords, ['old-password', 'current-password']);
    expect(find.text('Contraseña actualizada correctamente.'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('profile reports an incorrect password during reauthentication', (
    tester,
  ) async {
    await tester.pumpWidget(
      MiAppFinanzasPro(
        escucharSesion: () => Stream.value(_sesionPrueba),
        escucharRol: (_) => Stream.value(null),
        escucharMovimientos: (_) => Stream.value(_movimientosBase),
        escucharPagos: (_) => Stream.value([]),
        leerTelefonoPerfil: (_) async => '',
        reautenticarPerfil: (_, _) async {
          throw FirebaseAuthException(code: 'wrong-password');
        },
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('open_user_profile')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('profile_new_email')),
      'new@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('profile_email_password')),
      'incorrect-password',
    );
    await tester.ensureVisible(
      find.byKey(const Key('profile_send_email_change')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('profile_send_email_change')));
    await tester.pumpAndSettle();

    expect(find.text('Correo o contraseña incorrectos.'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('routes admins to a searchable user control panel', (
    tester,
  ) async {
    final authController = StreamController<AuthenticatedSession?>();
    authController.add(_sesionPrueba);
    final perfiles = [
      PerfilUsuario(
        uid: 'user-new',
        username: 'Sam Rivera',
        email: 'sam@example.com',
        telefono: '+593 99 123 4567',
        fechaRegistro: DateTime(2026, 10, 8, 10, 30),
      ),
      PerfilUsuario(
        uid: 'user-old',
        username: 'Alex Travez',
        email: 'alex@example.com',
        telefono: '',
        fechaRegistro: DateTime(2026, 10, 7, 14, 5),
      ),
    ];
    await tester.pumpWidget(
      MiAppFinanzasPro(
        escucharSesion: () => authController.stream,
        escucharRol: (uid) {
          expect(uid, _sesionPrueba.uid);
          return Stream.value('admin');
        },
        escucharUsuarios: () => Stream.value(perfiles),
        cerrarSesion: () async => authController.add(null),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Panel de administración'), findsOneWidget);
    expect(find.byKey(const Key('admin_user_count')), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('Sam Rivera'), findsOneWidget);
    expect(find.text('alex@example.com'), findsOneWidget);
    expect(find.text('Registrado 08/10/2026 · 10:30'), findsOneWidget);
    expect(find.text('user@example.com'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('admin_search')),
      'alex@EXAMPLE.com',
    );
    await tester.pumpAndSettle();
    expect(find.text('Alex Travez'), findsOneWidget);
    expect(find.text('Sam Rivera'), findsNothing);

    await tester.tap(find.byKey(const Key('admin_sign_out')));
    await tester.pumpAndSettle();
    expect(find.text('Bienvenido de nuevo'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await authController.close();
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'admin can inspect user movements and personal details read-only',
    (tester) async {
      final uid = 'very-long-firebase-user-identifier';
      final authController = StreamController<AuthenticatedSession?>();
      authController.add(_sesionPrueba);
      final movimientos = [
        Movimiento(
          categoria: CategoriaMovimiento.ingresos,
          monto: 1200,
          descripcion: 'Sueldo',
          fecha: DateTime(2026, 10, 8, 10, 30),
        ),
        Movimiento(
          categoria: CategoriaMovimiento.gastos,
          monto: 250,
          descripcion: 'Supermercado',
          fecha: DateTime(2026, 10, 9, 14, 5),
        ),
      ];
      final perfil = PerfilUsuario(
        uid: uid,
        username: 'Sam Rivera',
        email: 'sam@example.com',
        telefono: '+593 99 123 4567',
        fechaRegistro: DateTime(2026, 10, 8, 10, 30),
      );
      await tester.pumpWidget(
        MiAppFinanzasPro(
          escucharSesion: () => authController.stream,
          escucharRol: (_) => Stream.value('admin'),
          escucharUsuarios: () => Stream.value([perfil]),
          escucharMovimientosAdmin: (requestedUid) {
            expect(requestedUid, uid);
            return Stream.value(movimientos);
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(
        tester.widget<Text>(find.byKey(Key('admin_user_short_uid_$uid'))).data,
        'very-l…fier',
      );
      await tester.tap(find.byKey(Key('admin_user_$uid')));
      await tester.pumpAndSettle();

      expect(find.text('Resumen calculado · 2 movimientos'), findsOneWidget);
      expect(find.text('Sueldo'), findsOneWidget);
      expect(find.text('Supermercado'), findsOneWidget);
      expect(find.text('\$950.00'), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsNothing);
      expect(find.byIcon(Icons.delete), findsNothing);

      await tester.tap(find.byKey(const Key('admin_user_information_tab')));
      await tester.pumpAndSettle();
      expect(find.text('sam@example.com'), findsOneWidget);
      expect(find.text('+593 99 123 4567'), findsOneWidget);
      expect(find.text('very-l…fier'), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsNothing);
      expect(find.byIcon(Icons.delete), findsNothing);
      expect(tester.takeException(), isNull);

      await authController.close();
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('admin sees an empty-state message for users without movements', (
    tester,
  ) async {
    final authController = StreamController<AuthenticatedSession?>();
    authController.add(_sesionPrueba);
    final perfil = PerfilUsuario(
      uid: 'empty-user',
      username: 'Sin movimientos',
      email: 'empty@example.com',
      telefono: '',
      fechaRegistro: null,
    );
    await tester.pumpWidget(
      MiAppFinanzasPro(
        escucharSesion: () => authController.stream,
        escucharRol: (_) => Stream.value('admin'),
        escucharUsuarios: () => Stream.value([perfil]),
        escucharMovimientosAdmin: (_) => Stream.value([]),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('admin_user_empty-user')));
    await tester.pumpAndSettle();

    expect(
      find.text('Este usuario todavía no ha registrado movimientos.'),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('admin_user_information_tab')));
    await tester.pumpAndSettle();
    expect(find.text('No registrado'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await authController.close();
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('creates an account and opens its authenticated dashboard', (
    tester,
  ) async {
    final authController = StreamController<AuthenticatedSession?>();
    authController.add(null);
    var createdEmail = '';
    var createdUsername = '';
    var createdPhone = '';
    await tester.pumpWidget(
      MiAppFinanzasPro(
        escucharSesion: () => authController.stream,
        escucharRol: (_) => Stream.value(null),
        registrarCuenta: (username, email, phone, password) async {
          createdUsername = username;
          createdEmail = email;
          createdPhone = phone;
          expect(password, 'secure123');
          authController.add(_sesionPrueba);
        },
        escucharMovimientos: (_) => Stream.value(_movimientosBase),
        escucharPagos: (_) => Stream.value([]),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('¿Eres nuevo? Crea una cuenta'));
    await tester.tap(find.text('¿Eres nuevo? Crea una cuenta'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('registration_username')),
      'Alex Travez',
    );
    await tester.enterText(
      find.byKey(const Key('registration_email')),
      'new@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('registration_phone')),
      '+593 99 123 4567',
    );
    await tester.enterText(
      find.byKey(const Key('registration_password')),
      'secure123',
    );
    await tester.ensureVisible(
      find.byKey(const Key('registration_confirmation')),
    );
    await tester.enterText(
      find.byKey(const Key('registration_confirmation')),
      'different123',
    );
    await tester.ensureVisible(find.byKey(const Key('registration_submit')));
    await tester.tap(find.byKey(const Key('registration_submit')));
    await tester.pumpAndSettle();
    expect(find.text('Las contraseñas no coinciden'), findsOneWidget);
    expect(createdEmail, isEmpty);

    await tester.enterText(
      find.byKey(const Key('registration_confirmation')),
      'secure123',
    );
    await tester.ensureVisible(find.byKey(const Key('registration_submit')));
    await tester.tap(find.byKey(const Key('registration_submit')));
    await tester.pumpAndSettle();

    expect(createdUsername, 'Alex Travez');
    expect(createdEmail, 'new@example.com');
    expect(createdPhone, '+593 99 123 4567');
    expect(find.text('Resumen financiero'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await authController.close();
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('shows a clear message when Firebase rejects login', (
    tester,
  ) async {
    await tester.pumpWidget(
      MiAppFinanzasPro(
        escucharSesion: () => Stream.value(null),
        iniciarSesion: (_, _) async {
          throw FirebaseAuthException(code: 'invalid-credential');
        },
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('auth_email')),
      'user@example.com',
    );
    await tester.enterText(find.byKey(const Key('auth_password')), 'secret1');
    await tester.tap(find.byKey(const Key('auth_submit')));
    await tester.pumpAndSettle();

    expect(find.text('Correo o contraseña incorrectos.'), findsOneWidget);
    expect(find.text('Bienvenido de nuevo'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

final _movimientosBase = [
  Movimiento(
    categoria: CategoriaMovimiento.ingresos,
    monto: 1500,
    descripcion: 'Ingreso inicial',
    fecha: DateTime(2026, 10, 1),
  ),
  Movimiento(
    categoria: CategoriaMovimiento.gastos,
    monto: 450,
    descripcion: 'Gasto inicial',
    fecha: DateTime(2026, 10, 2),
  ),
  Movimiento(
    categoria: CategoriaMovimiento.ahorro,
    monto: 200,
    descripcion: 'Ahorro inicial',
    fecha: DateTime(2026, 10, 3),
  ),
  Movimiento(
    categoria: CategoriaMovimiento.inversion,
    monto: 100,
    descripcion: 'Inversión inicial',
    fecha: DateTime(2026, 10, 4),
  ),
];

const _sesionPrueba = AuthenticatedSession(
  uid: 'usuario-prueba',
  correo: 'user@example.com',
);
