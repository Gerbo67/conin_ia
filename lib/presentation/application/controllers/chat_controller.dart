import 'dart:math';

import 'package:conin_ia/domain/models/messageModel.dart';

/// Un controlador sencillo para gestionar operaciones básicas
class ChatController{

  Future<List<MessageModel>> obtenerDatos() async {
    final random = Random();
    return List.generate(10, (index) {
      return MessageModel(
        message: "Mensaje $index",
        subject: random.nextInt(2), // Genera un valor aleatorio entre 0 y 1
        date: DateTime.now().subtract(Duration(minutes: index)),
      );
    });
  }
}