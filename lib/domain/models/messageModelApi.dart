// To parse this JSON data, do
//
//     final messageApi = messageApiFromJson(jsonString);

import 'dart:convert';

MessageModelApi messageApiFromJson(String str) => MessageModelApi.fromJson(json.decode(str));

String messageApiToJson(MessageModelApi data) => json.encode(data.toJson());

class MessageModelApi {
  int code;
  String message;
  Data data;

  MessageModelApi({
    required this.code,
    required this.message,
    required this.data,
  });

  factory MessageModelApi.fromJson(Map<String, dynamic> json) => MessageModelApi(
    code: json["code"],
    message: json["message"],
    data: Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "message": message,
    "data": data.toJson(),
  };
}

class Data {
  String question;
  String answer;

  Data({
    required this.question,
    required this.answer,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    question: json["question"],
    answer: json["answer"],
  );

  Map<String, dynamic> toJson() => {
    "question": question,
    "answer": answer,
  };
}
