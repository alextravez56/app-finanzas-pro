class PerfilUsuario {
  const PerfilUsuario({
    required this.uid,
    required this.username,
    required this.email,
    required this.telefono,
    required this.fechaRegistro,
  });

  final String uid;
  final String username;
  final String email;
  final String telefono;
  final DateTime? fechaRegistro;
}
