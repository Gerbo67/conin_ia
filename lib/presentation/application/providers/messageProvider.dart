import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:conin_ia/domain/models/messageModel.dart';

class MessageNotifier extends StateNotifier<List<messageModel>> {
  MessageNotifier() : super([]) {
    _initializeMessages();
  }

  void _initializeMessages() {
    final welcomeMessage = messageModel(
      message: "¡Bienvenido al chat!",
      subject: 1,
      date: DateTime.now(),
    );
    state = [welcomeMessage];
  }

  void addMessage(messageModel message) {
    state = [...state, message];
  }
}

final messageProvider = StateNotifierProvider<MessageNotifier, List<messageModel>>((ref) {
  return MessageNotifier();
});