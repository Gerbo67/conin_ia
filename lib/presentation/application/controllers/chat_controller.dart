import 'package:conin_ia/domain/models/messageModel.dart';
import 'package:conin_ia/domain/models/messageModelApi.dart';
import 'package:conin_ia/presentation/application/services/http_general_service.dart';

class ChatController {
  static const String agentePath = '/api/agente/question';
  static String? _sessionId;

  Future<messageModel?> enviarPregunta(String question) async {
    try {
      Map<String, dynamic> body = {'message': question};
      if (_sessionId != null && _sessionId!.isNotEmpty) {
        body['sessionId'] = _sessionId;
      }
      final response = await HttpGeneralService.httpPost(
          path: agentePath, body: body);
      final apiResponse = messageApiFromJson(response);
      if (apiResponse.data.sessionId.isNotEmpty) {
        if (_sessionId != apiResponse.data.sessionId) {
          _sessionId = apiResponse.data.sessionId;
        }
      }
      return messageModel(
        message: apiResponse.data.answer,
        subject: 1,
        date: DateTime.now(),
      );
    } catch (e) {
      return null;
    }
  }
}
