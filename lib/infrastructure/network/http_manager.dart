import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<String?> httpFunction({
  required String type,
  required String host, // Ejemplo: "api.ejemplo.com"
  required String path,
  http.Client? client,
  Object? body,
  Map<String, String>? headers,
  Map<String, String>? params,
  bool log = false,
  bool successMessage = false,
  bool authorization = false,
}) async {
  http.Response response = http.Response("", 500);
  Uri url = Uri.http(host, path, params);
  client ??= http.Client();

  try {
    // Construcción de la URL. Si usas HTTPS, ajusta la variable isHttps de acuerdo a tu
    // lógica o configuración (por ejemplo, mediante FlavorConfig)
    bool isHttps = true; // Cambia a true si utilizas HTTPS
    Uri url;
    if (isHttps) {
      url = Uri.https(host, path, params);
    } else {
      url = Uri.http(host, path, params);
    }
    if (log) {
      debugPrint("REQUEST: $url");
    }

    // Agregar encabezados si no están presentes
    headers ??= {};
    headers["Content-type"] = "application/json";
    headers["Accept"] = "*/*";

    // Agregar encabezados personalizados
    if (authorization) {
      // String? token = (await storage.read(key: "tokenAuth"));
      // headers["Authorization"] = 'Bearer $token';
    }

    String? encodedBody;
    if (body != null && type.toUpperCase() != "GET") {
      encodedBody = json.encode(body);
    }

    String data = "";

    // Protocolo de petición
    switch (type.toUpperCase()) {
      case "POST":
        response = await http.post(url, body: encodedBody, headers: headers);
        data = response.body;
        break;
      case "PUT":
        response = await http.put(url, body: encodedBody, headers: headers);
        data = response.body;
        break;
      case "GET":
        response = await http.get(url, headers: headers);
        data = response.body;
        break;
      case "DELETE":
        response = await http.delete(url, body: encodedBody, headers: headers);
        data = response.body;
        break;
      default:
      // Si se pasa un método no soportado, lanza una excepción.
        throw Exception("Método HTTP no soportado: $type");
    }

    // Verificación de respuesta
    if (response.statusCode == 200) {
      if (successMessage) {
        debugPrint("Operación exitosa: ${response.statusCode}");
      }
      return data;
    } else {
      debugPrint("Error en la respuesta: ${response.statusCode}");
      return null;
    }
  } catch (e) {
    // Manejo de error general
    debugPrint("Excepción durante la petición HTTP: $e");
    return null;
  }
}