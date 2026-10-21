import 'package:flutter_test/flutter_test.dart';
import 'package:nexasoft_incidencias/model/incidencia.dart';

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
