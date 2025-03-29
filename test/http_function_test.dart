import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:conin_ia/domain/models/messageModelApi.dart';
import 'package:conin_ia/infrastructure/network/http_manager.dart';
import 'package:conin_ia/presentation/application/services/http_general_service.dart';

void main() {
  group('Pruebas de API de mensajes', () {
    test('Enviar pregunta y recibir respuesta correcta', () async {
      // Simula la respuesta del servidor
      final mockClient = MockClient((request) async {
        // Verifica que la petición contiene la pregunta correcta
        if (request.method == 'POST') {
          final body = request.body;
          expect(body, contains('hackaton troyano 2025'));

          // Respuesta simulada del servidor
          return http.Response('''
          {
            "code": 200,
            "message": "Success",
            "data": {
              "question": "¿El vídeo para mi entrega del hackaton troyano 2025 puede ser subido a Tiktok?",
              "answer": "Sí, puedes subir tu video de entrega del Hackaton Troyano 2025 a TikTok, siempre que cumplas con las reglas del evento y los términos de servicio de la plataforma."
            }
          }
          ''', 200);
        }
        return http.Response('Error', 404);
      });

      // Sobrescribe la función para usar nuestro cliente mock
      final result = await httpFunction(
        type: 'POST',
        host: '192.168.35.160:3100',
        path: '/api/agente/question',
        body: {
          'question': '¿El vídeo para mi entrega del hackaton troyano 2025 puede ser subido a Tiktok?'
        },
        client: mockClient,
      );

      // Convertir la respuesta a nuestro modelo
      final messageResponse = messageApiFromJson(result!);

      // Verificaciones
      expect(messageResponse.code, 200);
      expect(messageResponse.message, 'Success');
      expect(messageResponse.data.question, '¿El vídeo para mi entrega del hackaton troyano 2025 puede ser subido a Tiktok?');
      expect(messageResponse.data.answer, contains('puedes subir tu video'));
    });

    test('Manejar error de API correctamente', () async {
      final mockClient = MockClient((request) async {
        return http.Response('{"code": 500, "message": "Error interno", "data": {"question": "", "answer": ""}}', 500);
      });

      final result = await httpFunction(
        type: 'POST',
        host: '192.168.35.160:3100',
        path: '/api/agente/question',
        body: {
          'question': '¿El vídeo para mi entrega del hackaton troyano 2025 puede ser subido a Tiktok?'
        },
        client: mockClient,
      );

      final messageResponse = messageApiFromJson(result!);

      expect(messageResponse.code, 500);
      expect(messageResponse.message, 'Error interno');
    });
  });
}