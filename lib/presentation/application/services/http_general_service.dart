import '../../../infrastructure/network/http_manager.dart';

class HttpGeneralService {
  static Future<String> httpGet(
      {required String url,
        bool authorization = false,
        Map<String, String>? params}) async {
    String? response = await httpFunction(
        type: "GET", host: "api.example.com", path: url, authorization: authorization, params: params);
    return (response != null) ? response : "";
  }
  static Future<String> httpPost(
      {required String url,
        bool authorization = false,
        required Map<String, dynamic> body}) async {
    String? response = await httpFunction(
        type: "POST", host: "api.example.com", path: url, authorization: authorization, body: body);
    return (response != null) ? response : "";
  }
}