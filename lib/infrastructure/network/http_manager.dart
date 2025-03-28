import 'dart:convert';
import 'package:flutter/Material.dart';
import 'package:http/http.dart' as http;



Future<String?> httpFunction(
    {required String type,
      required String path,
      Object? body,
      Map<String, String>? headers,
      Map<String, String>? params,
      bool log = false,
      bool successMessage = false,
      bool authorization = false}) async {
  http.Response response = http.Response("", 500);
  try {
    // Verifica conexion a internet
    //if (await InternetConnectionChecker().hasConnection) {
    //Url de petición
    Uri url = Uri.http("");
    /*bool isHttps = FlavorConfig.instance.variables["useHttps"] as bool;
    String baseUrl = FlavorConfig.instance.variables["baseUrl"].toString();*/

 /*   if (isHttps) {
      url = Uri.https(baseUrl, path, params);
    } else {
      url = Uri.http(baseUrl, path, params);
    }

    printRich("REQUEST: $url", bold: true, foreground: Colors.blue);*/

    //Agregar encabezados si no están presentes
    headers ??= {};
    headers["Content-type"] = "application/json";
    headers["Accept"] = "*/*";

    //Agregar encabezados personalizados
    if (authorization) {
      //String? token = (await storage.read(key: "tokenAuth"));
      //headers["Authorization"] = 'Bearer $token';
    }

    body = json.encode(body);

    //Protocolo de petición
    late String data;
    switch (type) {
      case "POST":
        response = await http.post(url, body: body, headers: headers);
        data = response.body;
        break;
      case "PUT":
        response = await http.put(url, body: body, headers: headers);
        data = response.body;
        break;
      case "GET":
        response = await http.get(url, headers: headers);
        data = response.body;
        break;
      case "DELETE":
        response = await http.delete(url, body: body, headers: headers);
        data = response.body;
        break;
    }

    // Verificación de respuesta
    if (response.statusCode == 200) {
    /*  printRich("RESPONSE: ${response.statusCode}",
          bold: true, foreground: Colors.green);*/
      // Opcional mensaje de exito
      if (successMessage) {}
      return data;
    } else {
     /* printRich("RESPONSE: ${response.statusCode}",
          bold: true, foreground: Colors.amber);
      // Error
      NotificationUI.instance.notificationError();*/
      return null;
    }
    /*
    } else {
      // No internet
      NotificationUI.instance.notificationNoInternet();
      return null;
    }
       */
  } catch (e) {
    //Error
    /*NotificationUI.instance.notificationError();
    printRich(e, bold: true, foreground: Colors.red);*/
    return null;
  }
}
