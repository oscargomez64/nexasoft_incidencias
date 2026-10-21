import 'package:flutter/material.dart';

/// Color asociado a cada prioridad (compartido por lista y detalle).
Color colorPrioridad(String prioridad) {
  switch (prioridad) {
    case 'Alta':
      return const Color(0xFFB3261E);
    case 'Baja':
      return const Color(0xFF5F6B7A);
    default:
      return const Color(0xFF174C83);
  }
}

/// Etiqueta compacta con el texto "Prioridad: X" para mostrar el valor actual.
class EtiquetaPrioridad extends StatelessWidget {
  final String prioridad;
  const EtiquetaPrioridad({super.key, required this.prioridad});

  @override
  Widget build(BuildContext context) {
    final color = colorPrioridad(prioridad);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Prioridad: $prioridad',
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
