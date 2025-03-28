import 'package:flutter/material.dart';

/// Un controlador sencillo para gestionar operaciones básicas
class ChatController{

  Future<List<String>> obtenerDatos() async {
    // Simulamos una consulta asíncrona
    await Future.delayed(const Duration(seconds: 1));

    // Datos de ejemplo
    return ['Elemento 1', 'Elemento 2', 'Elemento 3'];
  }

  Future<Map<String, dynamic>> enviarDatos(String nombre, int edad, bool activo) async {
    await Future.delayed(const Duration(seconds: 1));

    // Creamos una respuesta simulada
    return {
      'estado': 'exitoso',
      'mensaje': 'Datos procesados correctamente',
      'datos': {
        'nombre': nombre,
        'edad': edad,
        'activo': activo,
        'fechaProcesamiento': DateTime.now().toIso8601String(),
      }
    };
  }
}