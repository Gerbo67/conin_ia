import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:conin_ia/infrastructure/network/http_manager.dart';

void main() {
  test('HTTP GET request returns weather data', () async {
    final client = MockClient((request) async {
      return http.Response('{"location": {"name": "London"}, "current": {"temp_c": 14.0}}', 200);
    });

    final result = await httpFunction(
      type: 'GET',
      host: 'api.weatherapi.com',
      path: '/v1/current.json',
      params: {'key': '55265a345ffb482588410550252903', 'q': 'London'},
      client: client,
    );

    print('Result: $result');

    expect(result, isNotNull);
    expect(result, contains('location'));
    expect(result, contains('current'));
  });

  test('HTTP POST request returns data', () async {
    final client = MockClient((request) async {
      return http.Response('{"key": "value"}', 200);
    });

    final result = await httpFunction(
      type: 'POST',
      host: 'www.weatherapi.com',
      path: '/path',
      body: {'key': 'value'},
      client: client,
    );

    print('Result: $result');

    expect(result, isNotNull);
    expect(result, contains('key'));
  });

  // Agrega más pruebas para otros métodos HTTP y casos de error
}