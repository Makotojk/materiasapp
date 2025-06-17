class Materia {
  final int id;
  final String codigo;
  final String nombre;
  final int creditos;
  final String requisito;
  final String estado;

  Materia({
    required this.id,
    required this.codigo,
    required this.nombre,
    required this.creditos,
    required this.requisito,
    required this.estado,
  });

  factory Materia.fromJson(Map<String, dynamic> json) {
    return Materia(
      id: json['id'],
      codigo: json['codigo'],
      nombre: json['nombre'],
      creditos: json['creditos'],
      requisito: json['requisito'],
      estado: json['estado'],
    );
  }
}
