import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat Demo',
      theme: ThemeData.light(), // Se usa siempre el tema claro
      home: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();

  // Lista de mensajes: cada mensaje tiene 'sender', 'text' y 'timestamp'
  final List<Map<String, dynamic>> _messages = [
    {
      'sender': 'Asistente',
      'text': 'Hola! Soy tu asistente virtual. ¿En qué puedo ayudarte hoy?',
      'timestamp': DateTime.now(),
    },
  ];

  bool _isTyping = false;

  // Agrega un mensaje a la lista.
  void _addMessage(String sender, String text) {
    setState(() {
      _messages.add({
        'sender': sender,
        'text': text,
        'timestamp': DateTime.now(),
      });
    });
  }

  // Envía un mensaje de texto.
  void _sendTextMessage() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      _addMessage('Usuario', text);
      _controller.clear();
      _simulateAssistantResponse();
    }
  }

  // Envía un mensaje de audio (simulado).
  void _sendAudioMessage() {
    _addMessage('Usuario', 'Mensaje de audio enviado');
    _simulateAssistantResponse();
  }

  // Envía un archivo adjunto (simulado).
  void _sendFileMessage() {
    _addMessage('Usuario', 'Archivo adjunto enviado');
    _simulateAssistantResponse();
  }

  // Simula que el asistente está escribiendo durante 2 segundos.
  void _simulateAssistantResponse() {
    setState(() {
      _isTyping = true;
    });
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _addMessage('Asistente', 'Esta es una respuesta automática.');
        _isTyping = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Demo'),
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
                        // Dejamos espacio para la barra de entrada (8% + 80 píxeles extra)
                        bottom: screenHeight * 0.08 + 80,
                      ),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        final bool isAssistant =
                            message['sender'] == 'Asistente';
                        final formattedTime =
                        DateFormat('hh:mm a').format(message['timestamp']);

                        return Container(
                          alignment: isAssistant
                              ? Alignment.centerLeft
                              : Alignment.centerRight,
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Column(
                            crossAxisAlignment: isAssistant
                                ? CrossAxisAlignment.start
                                : CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                  color: isAssistant
                                      ? Colors.grey[300]
                                      : Colors.blue[100],
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Text(
                                  message['text'],
                                  style: const TextStyle(fontSize: 16),
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
                  // Indicador de "Escribiendo..." justo encima de la barra de entrada.
                  if (_isTyping)
                    Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: const Text('Asistente está escribiendo...'),
                    ),
                ],
              ),
            ),
            // Barra de entrada (botones + TextField)
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
                      // Botón para enviar mensaje de audio.
                      IconButton(
                        icon: const Icon(Icons.mic),
                        onPressed: _sendAudioMessage,
                      ),
                      // Botón para enviar archivo adjunto.
                      IconButton(
                        icon: const Icon(Icons.attach_file),
                        onPressed: _sendFileMessage,
                      ),
                      // Campo de texto.
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: const InputDecoration(
                            hintText: 'Escribe tu mensaje...',
                            border: InputBorder.none,
                          ),
                          onSubmitted: (_) => _sendTextMessage(),
                        ),
                      ),
                      // Botón para enviar mensaje de texto.
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
