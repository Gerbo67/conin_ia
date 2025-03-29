import 'package:conin_ia/domain/models/messageModel.dart';
import 'package:conin_ia/domain/models/messageModelApi.dart';
import 'package:conin_ia/presentation/application/services/http_general_service.dart';

class ChatController {
  static const String agentePath = '/api/agente/question';

  Future<messageModel?> enviarPregunta(String question) async {
    try {
      // Enviar pregunta a la API
      final response = await HttpGeneralService.httpPost(
          path: agentePath,
          body: {'message': question}
      );

      // Convertir respuesta a MessageModelApi
      final apiResponse = messageApiFromJson(response);

      // Convertir MessageModelApi a messageModel para mostrar en chat
      return messageModel(
        message: apiResponse.data.answer,
        subject: 1, // 1 representa al asistente
        date: DateTime.now(),
      );
          return null;
    } catch (e) {
      print("Error al enviar pregunta: $e");
      return null;
    }
  }
}