import '../data/almacen_local.dart';
import '../model/incidencia.dart';

class GestorIncidencias {
  final AlmacenLocal datos = AlmacenLocal();
  List<Incidencia> incidencias = [];

  Future<void> iniciar() async {
    incidencias = await datos.leer();
  }

  List<Incidencia> buscar(String texto) {
    final consulta = texto.trim().toLowerCase();
    if (consulta.isEmpty) return incidencias;
    return incidencias
        .where((x) =>
            x.titulo.toLowerCase().contains(consulta) ||
            x.descripcion.toLowerCase().contains(consulta))
        .toList();
  }

  Incidencia? porId(String id) {
    for (var x in incidencias) {
      if (x.id == id) return x;
    }
    return null;
  }

  int contar(String estado) {
    return incidencias.where((x) => x.estado == estado).length;
  }

  Future<void> cambiarEstado(String id, String estado) async {
    final item = porId(id);
    if (item == null) return;
    final anterior = item.estado;
    item.estado = estado;
    try {
      await datos.guardar(incidencias);
    } catch (e) {
      item.estado = anterior;
      rethrow;
    }
  }

  /// Cambia la prioridad de una incidencia y la guarda. Si el valor no es uno
  /// de los tres aprobados se rechaza; si el guardado falla se restaura el
  /// valor anterior y se relanza el error.
  Future<void> cambiarPrioridad(String id, String prioridad) async {
    if (!Prioridad.esValida(prioridad)) {
      throw ArgumentError.value(prioridad, 'prioridad', 'Valor no permitido');
    }
    final item = porId(id);
    if (item == null) return;
    final anterior = item.prioridad;
    if (anterior == prioridad) return;
    item.prioridad = prioridad;
    try {
      await datos.guardar(incidencias);
    } catch (e) {
      item.prioridad = anterior;
      rethrow;
    }
  }

  Future<void> crear(String titulo, String descripcion, String cliente,
      String categoria,
      {String prioridad = Prioridad.porDefecto}) async {
    if (!Prioridad.esValida(prioridad)) {
      throw ArgumentError.value(prioridad, 'prioridad', 'Valor no permitido');
    }
    final nuevo = Incidencia(
      id: 'INC-${DateTime.now().microsecondsSinceEpoch}',
      titulo: titulo,
      descripcion: descripcion,
      cliente: cliente,
      categoria: categoria,
      estado: 'Pendiente',
      fecha: DateTime.now().toIso8601String().split('T').first,
      prioridad: prioridad,
    );
    incidencias.insert(0, nuevo);
    try {
      await datos.guardar(incidencias);
    } catch (e) {
      incidencias.remove(nuevo);
      rethrow;
    }
  }

  Future<void> reiniciarDemo() async {
    await datos.restaurarDatosDeEjemplo();
    await iniciar();
  }
}
