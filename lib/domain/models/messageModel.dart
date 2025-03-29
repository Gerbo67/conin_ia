class messageModel {
  final String message;
  final int subject;
  final DateTime date;

  messageModel({
    required this.message,
    required this.subject,
    required this.date,
  });

  // Método para convertir un objeto JSON a una instancia de MessageModel
  factory messageModel.fromJson(Map<String, dynamic> json) {
    return messageModel(
      message: json['message'],
      subject: json['subject'],
      date: DateTime.parse(json['date']),
    );
  }

  // Método para convertir una instancia de MessageModel a un objeto JSON
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'subject': subject,
      'date': date.toIso8601String(),
    };
  }
}