/// Valores de prioridad aprobados para una incidencia (FEAT-001).
class Prioridad {
  Prioridad._();

  static const String baja = 'Baja';
  static const String media = 'Media';
  static const String alta = 'Alta';

  /// Unica lista de valores permitidos, en orden de menor a mayor.
  static const List<String> valores = [baja, media, alta];

  /// Valor inicial para registros antiguos que no tienen prioridad.
  static const String porDefecto = media;

  static bool esValida(String? valor) => valores.contains(valor);

  /// Convierte un dato crudo (posiblemente nulo, vacio o con otro formato)
  /// en uno de los tres valores aprobados. Si no se reconoce, devuelve Media.
  static String normalizar(Object? crudo) {
    if (crudo == null) return porDefecto;
    final texto = crudo.toString().trim().toLowerCase();
    for (final v in valores) {
      if (v.toLowerCase() == texto) return v;
    }
    return porDefecto;
  }
}

class Incidencia {
  String id;
  String titulo;
  String descripcion;
  String cliente;
  String categoria;
  String estado;
  String fecha;
  String prioridad;

  Incidencia({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.cliente,
    required this.categoria,
    required this.estado,
    required this.fecha,
    this.prioridad = Prioridad.porDefecto,
  });

  factory Incidencia.desdeJson(Map<String, dynamic> m) {
    return Incidencia(
      id: m['id']?.toString() ?? '',
      titulo: m['titulo']?.toString() ?? '',
      descripcion: m['descripcion']?.toString() ?? '',
      cliente: m['cliente']?.toString() ?? '',
      categoria: m['categoria']?.toString() ?? 'Software',
      estado: m['estado']?.toString() ?? 'Pendiente',
      fecha: m['fecha']?.toString() ?? '',
      // Los registros anteriores a FEAT-001 no traen este campo.
      prioridad: Prioridad.normalizar(m['prioridad']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'cliente': cliente,
      'categoria': categoria,
      'estado': estado,
      'fecha': fecha,
      'prioridad': prioridad,
    };
  }
}
