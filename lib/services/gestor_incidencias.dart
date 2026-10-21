import '../data/almacen_local.dart';
import '../model/incidencia.dart';

class GestorIncidencias {
  final AlmacenLocal datos = AlmacenLocal();
  List<Incidencia> incidencias = [];

  Future<void> iniciar() async {
    incidencias = await datos.leer();
  }

  /// Opciones de los filtros de la pantalla principal (FEAT-002).
  static const String todosEstados = 'Todos';
  static const String todasPrioridades = 'Todas';
  static const List<String> opcionesEstado = [
    todosEstados,
    'Pendiente',
    'En proceso',
    'Resuelta',
  ];
  static const List<String> opcionesPrioridad = [
    todasPrioridades,
    ...Prioridad.valores,
  ];

  /// Aplica a la vez todas las condiciones activas: texto (en titulo o
  /// descripcion, sin distinguir mayusculas ni espacios sobrantes), estado y
  /// prioridad. 'Todos' y 'Todas' no restringen.
  static List<Incidencia> aplicarFiltros(
    List<Incidencia> lista, {
    String texto = '',
    String estado = todosEstados,
    String prioridad = todasPrioridades,
  }) {
    final consulta = texto.trim().toLowerCase();
    return lista.where((x) {
      if (estado != todosEstados && x.estado != estado) return false;
      if (prioridad != todasPrioridades && x.prioridad != prioridad) {
        return false;
      }
      if (consulta.isEmpty) return true;
      return x.titulo.toLowerCase().contains(consulta) ||
          x.descripcion.toLowerCase().contains(consulta);
    }).toList();
  }

  List<Incidencia> filtrar({
    String texto = '',
    String estado = todosEstados,
    String prioridad = todasPrioridades,
  }) =>
      aplicarFiltros(incidencias,
          texto: texto, estado: estado, prioridad: prioridad);

  List<Incidencia> buscar(String texto) => filtrar(texto: texto);

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
