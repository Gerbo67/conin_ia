import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'package:conin_ia/domain/models/messageModel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/providers/messageProvider.dart';
import '../application/controllers/chat_controller.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ChatController _chatController = ChatController();
  bool _isTyping = false;

  void _sendTextMessage() async {
    if (_controller.text.trim().isEmpty) return;

    // Guardar el texto del usuario
    final userMessage = messageModel(
      message: _controller.text,
      subject: 2, // 2 representa al usuario
      date: DateTime.now(),
    );

    // Añadir mensaje del usuario a la lista
    ref.read(messageProvider.notifier).addMessage(userMessage);

    // Limpiar el campo de texto
    final userQuestion = _controller.text;
    _controller.clear();

    // Mostrar indicador de escritura
    setState(() {
      _isTyping = true;
    });

    try {
      // Enviar pregunta a la API y esperar respuesta
      final assistantMessage = await _chatController.enviarPregunta(userQuestion);

      // Ocultar indicador de escritura
      setState(() {
        _isTyping = false;
      });

      // Añadir respuesta si es válida
      if (assistantMessage != null) {
        ref.read(messageProvider.notifier).addMessage(assistantMessage);
      } else {
        // Manejar error - mostrar mensaje de error como respuesta
        final errorMessage = messageModel(
          message: "Lo siento, no pude obtener una respuesta. Inténtalo de nuevo.",
          subject: 1, // 1 representa al asistente
          date: DateTime.now(),
        );
        ref.read(messageProvider.notifier).addMessage(errorMessage);
      }
    } catch (e) {
      setState(() {
        _isTyping = false;
      });
      print("Error al enviar mensaje: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(messageProvider);
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ConinIA Chat'),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SizedBox(
        child: Column(
          children: [
            Expanded(
              flex: 6,
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.only(
                        top: 8.0,
                        left: 8.0,
                        right: 8.0,
                        bottom: screenHeight * 0.08 + 80,
                      ),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final bool isAssistant = message.subject == 1;
                        final formattedTime = DateFormat('hh:mm a').format(message.date);

                        return Container(
                          alignment: isAssistant ? Alignment.centerLeft : Alignment.centerRight,
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Column(
                            crossAxisAlignment: isAssistant ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                  color: isAssistant ? Colors.grey[300] : Colors.blue[100],
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: MarkdownBody(
                                  data: message.message,
                                  styleSheet: MarkdownStyleSheet(
                                    p: TextStyle(fontSize: 16),
                                    // Puedes personalizar más estilos aquí
                                  ),
                                  selectable: true,
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                formattedTime,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  if (_isTyping)
                    Container(
                      alignment: Alignment.centerLeft,
                      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: const Text('ConinIA está escribiendo...'),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 6.0,
                  ),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 30.0,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: const BorderRadius.all(Radius.circular(40)),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.mic),
                        onPressed: () {}, // Funcionalidad de micrófono para futura implementación
                      ),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: const InputDecoration(
                            hintText: 'Escribe tu pregunta...',
                            border: InputBorder.none,
                          ),
                          onSubmitted: (_) => _sendTextMessage(),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: _sendTextMessage,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}