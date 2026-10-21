import 'package:flutter_test/flutter_test.dart';
import 'package:nexasoft_incidencias/model/incidencia.dart';
import 'package:nexasoft_incidencias/services/gestor_incidencias.dart';

void main() {
  test('Una incidencia antigua puede convertirse desde JSON', () {
    final registro = Incidencia.desdeJson({
      'id': 'INC-DEMO',
      'titulo': 'Prueba',
      'descripcion': 'Caso de ejemplo',
      'cliente': 'Cliente ficticio',
      'categoria': 'Redes',
      'estado': 'Pendiente',
      'fecha': '2026-10-12',
    });
    expect(registro.id, 'INC-DEMO');
    expect(registro.toJson()['estado'], 'Pendiente');
  });

  pruebasPrioridad();
  pruebasFiltros();
}

void pruebasPrioridad() {
  Map<String, dynamic> base() => {
        'id': 'INC-DEMO',
        'titulo': 'Prueba',
        'descripcion': 'Caso de ejemplo',
        'cliente': 'Cliente ficticio',
        'categoria': 'Redes',
        'estado': 'Pendiente',
        'fecha': '2026-10-12',
      };

  group('FEAT-001 prioridad', () {
    test('Un registro antiguo sin prioridad se abre con Media', () {
      final registro = Incidencia.desdeJson(base());
      expect(registro.prioridad, Prioridad.media);
    });

    test('Un valor vacio, nulo o no aprobado se convierte en Media', () {
      for (final crudo in [null, '', '   ', 'Urgente', 'ALTISIMA', 5]) {
        final datos = base()..['prioridad'] = crudo;
        expect(Incidencia.desdeJson(datos).prioridad, Prioridad.media);
      }
    });

    test('Los tres valores aprobados se conservan', () {
      for (final valor in Prioridad.valores) {
        final datos = base()..['prioridad'] = valor;
        expect(Incidencia.desdeJson(datos).prioridad, valor);
      }
    });

    test('Se normalizan espacios y mayusculas de los valores aprobados', () {
      final datos = base()..['prioridad'] = '  alta ';
      expect(Incidencia.desdeJson(datos).prioridad, Prioridad.alta);
    });

    test('La prioridad se guarda y se recupera con toJson/desdeJson', () {
      final registro = Incidencia.desdeJson(base())..prioridad = Prioridad.alta;
      final copia = Incidencia.desdeJson(registro.toJson());
      expect(copia.prioridad, Prioridad.alta);
    });

    test('Solo existen tres valores validos', () {
      expect(Prioridad.valores, ['Baja', 'Media', 'Alta']);
      expect(Prioridad.esValida('Alta'), isTrue);
      expect(Prioridad.esValida('Critica'), isFalse);
      expect(Prioridad.esValida(null), isFalse);
    });
  });
}

void pruebasFiltros() {
  Incidencia inc(String id, String titulo, String descripcion, String estado,
          String prioridad) =>
      Incidencia(
        id: id,
        titulo: titulo,
        descripcion: descripcion,
        cliente: 'Cliente ficticio',
        categoria: 'Redes',
        estado: estado,
        fecha: '2026-10-12',
        prioridad: prioridad,
      );

  final datos = [
    inc('A', 'WiFi intermitente', 'Se desconecta', 'Pendiente', 'Alta'),
    inc('B', 'Router lento', 'Falla el wifi del piso 2', 'Pendiente', 'Baja'),
    inc('C', 'Impresora', 'No imprime', 'En proceso', 'Alta'),
    inc('D', 'VPN', 'Tunel caido', 'Resuelta', 'Media'),
    inc('E', 'Correo', 'Llega tarde', 'Pendiente', 'Alta'),
  ];
  List<String> ids(List<Incidencia> l) => l.map((x) => x.id).toList();

  group('FEAT-002 filtros', () {
    test('Sin condiciones activas se devuelven todos los registros', () {
      expect(ids(GestorIncidencias.aplicarFiltros(datos)), ['A', 'B', 'C', 'D', 'E']);
    });

    test('Filtro por estado', () {
      final r = GestorIncidencias.aplicarFiltros(datos, estado: 'Pendiente');
      expect(ids(r), ['A', 'B', 'E']);
    });

    test('Filtro por prioridad', () {
      final r = GestorIncidencias.aplicarFiltros(datos, prioridad: 'Alta');
      expect(ids(r), ['A', 'C', 'E']);
    });

    test('Texto, estado y prioridad funcionan juntos', () {
      final r = GestorIncidencias.aplicarFiltros(datos,
          texto: ' WIFI ', estado: 'Pendiente', prioridad: 'Alta');
      expect(ids(r), ['A']);
    });

    test('El texto busca en titulo y descripcion', () {
      expect(ids(GestorIncidencias.aplicarFiltros(datos, texto: 'wifi')), ['A', 'B']);
    });

    test('Una combinacion sin coincidencias devuelve lista vacia', () {
      final r = GestorIncidencias.aplicarFiltros(datos,
          estado: 'Resuelta', prioridad: 'Alta');
      expect(r, isEmpty);
    });

    test('Restablecer (Todos, Todas, sin texto) recupera todos los registros', () {
      final r = GestorIncidencias.aplicarFiltros(datos,
          texto: '', estado: GestorIncidencias.todosEstados,
          prioridad: GestorIncidencias.todasPrioridades);
      expect(r.length, datos.length);
    });

    test('Las opciones de filtro coinciden con lo solicitado', () {
      expect(GestorIncidencias.opcionesEstado,
          ['Todos', 'Pendiente', 'En proceso', 'Resuelta']);
      expect(GestorIncidencias.opcionesPrioridad,
          ['Todas', 'Baja', 'Media', 'Alta']);
    });
  });
}
