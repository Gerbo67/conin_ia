import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<String?> httpFunction({
  required String type,
  required String host,
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
  client ??= http.Client();

  try {
    bool isHttps = false; // Cambiado a false para usar http://
    Uri url;
    if (isHttps) {
      url = Uri.https(host, path, params);
    } else {
      url = Uri.https(host, path, params);
    }

    if (log) {
      debugPrint("REQUEST: $url");
    }

    headers ??= {};
    headers["Content-type"] = "application/json";
    headers["Accept"] = "*/*";

    if (authorization) {
      // String? token = (await storage.read(key: "tokenAuth"));
      // headers["Authorization"] = 'Bearer $token';
    }

    String? encodedBody;
    if (body != null && type.toUpperCase() != "GET") {
      encodedBody = json.encode(body);
      if (log) {
        debugPrint("BODY: $encodedBody");
      }
    }

    String data = "";

    switch (type.toUpperCase()) {
      case "POST":
        response = await client.post(url, body: encodedBody, headers: headers);
        data = response.body;
        break;
      case "PUT":
        response = await client.put(url, body: encodedBody, headers: headers);
        data = response.body;
        break;
      case "GET":
        response = await client.get(url, headers: headers);
        data = response.body;
        break;
      case "DELETE":
        response = await client.delete(url, body: encodedBody, headers: headers);
        data = response.body;
        break;
      default:
        throw Exception("Método HTTP no soportado: $type");
    }

    if (log) {
      debugPrint("RESPONSE: ${response.statusCode} - ${response.body}");
    }

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
    debugPrint("Excepción durante la petición HTTP: $e");
    return null;
  } finally {
    client.close();
  }
}