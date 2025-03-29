import 'package:http/http.dart' as http;
import '../../../infrastructure/network/http_manager.dart';
import '../../../domain/models/messageModelApi.dart';

class HttpGeneralService {
  static const String defaultHost = '192.168.35.160:3100';


  static Future<String> httpGet({
    String host = defaultHost,
    required String path,
    bool authorization = false,
    Map<String, String>? params,
    http.Client? client}) async {

    String? response = await httpFunction(
        type: "GET",
        host: host,
        path: path,
        authorization: authorization,
        params: params,
        client: client,
        log: true);

    return response ?? "";
  }

  static Future<String> httpPost({
    String host = defaultHost,
    required String path,
    bool authorization = false,
    required Map<String, dynamic> body,
    http.Client? client}) async {

    String? response = await httpFunction(
        type: "POST",
        host: host,
        path: path,
        authorization: authorization,
        body: body,
        client: client,
        log: true);

    return response ?? "";
  }
}