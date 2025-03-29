import 'package:conin_ia/presentation/screens/styles.dart';
import 'package:conin_ia/presentation/screens/widgets/MessageBubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:conin_ia/domain/models/messageModel.dart';
import 'package:line_icons/line_icons.dart';
import 'package:shimmer/shimmer.dart';
import '../application/providers/messageProvider.dart';
import '../application/controllers/chat_controller.dart';

import '../application/services/http_general_service.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> with WidgetsBindingObserver {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _baseUrlController = TextEditingController();
  final ChatController _chatController = ChatController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Inicializamos el controlador con el valor actual de la URL base.
    _baseUrlController.text = HttpGeneralService.defaultHost;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    _baseUrlController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    // Se detecta el cambio de dimensiones (por ejemplo, al abrir el teclado) y se hace el scroll de golpe.
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  // Método para mostrar el diálogo que permite editar la URL base.
  void _showBaseUrlDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Configurar URL Base'),
          content: TextField(
            controller: _baseUrlController,
            decoration: const InputDecoration(
              labelText: 'URL base',
              hintText: 'Ingresa la URL base, ej: 192.168.35.160:3100',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  // Se elimina "http://" o "https://" si están presentes.
                  final inputUrl = _baseUrlController.text.trim();
                  HttpGeneralService.defaultHost = inputUrl.replaceAll(RegExp(r'^https?://'), '');
                });
                Navigator.of(context).pop();
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _sendTextMessage() async {
    if (_controller.text.trim().isEmpty) return;
    final userMessage = messageModel(
      message: _controller.text,
      subject: 2,
      date: DateTime.now(),
    );
    ref.read(messageProvider.notifier).addMessage(userMessage);
    _controller.clear();
    setState(() {
      _isTyping = true;
    });
    _scrollToBottom();
    try {
      final assistantMessage = await _chatController.enviarPregunta(
        userMessage.message,
      );
      setState(() {
        _isTyping = false;
      });
      if (assistantMessage != null) {
        ref.read(messageProvider.notifier).addMessage(assistantMessage);
      } else {
        final errorMessage = messageModel(
          message: "Lo siento, no pude obtener una respuesta. Inténtalo de nuevo.",
          subject: 1,
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
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(messageProvider);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text(
          'ChatBot',
          style: TextStyle(
            color: ColorStyles.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        backgroundColor: ColorStyles.blankColor,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: ColorStyles.blankColor,
          statusBarIconBrightness: Brightness.dark,
        ),
        leading: Icon(Icons.arrow_back, color: ColorStyles.primaryColor),
        leadingWidth: 60,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: ColorStyles.primaryColor),
            onPressed: _showBaseUrlDialog,
          ),
        ],
      ),
      backgroundColor: ColorStyles.blankColor,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            Expanded(
              flex: 6,
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.only(
                  top: 8.0,
                  left: 8.0,
                  right: 8.0,
                  bottom: 16.0,
                ),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  return TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 300),
                    tween: Tween(begin: 0, end: 1),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(
                            (message.subject == 2 ? 1 - value : value - 1) * 50,
                            0
                        ),
                        child: Opacity(
                          opacity: value,
                          child: child,
                        ),
                      );
                    },
                    child: MessageBubble(
                      message: message.message,
                      subject: message.subject,
                      date: message.date,
                    ),
                  );
                },
              ),
            ),
            if (_isTyping)
              Container(
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.symmetric(
                  vertical: 2.0,
                  horizontal: 16.0,
                ),
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Shimmer.fromColors(
                  baseColor: Colors.purple[700]!,
                  highlightColor: Colors.purple[300]!,
                  child: const Text(
                    'ConinIA está escribiendo...',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            Container(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 16.0,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(LineIcons.paperclip),
                      onPressed: () {},
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
                      icon: const Icon(
                        Icons.send,
                        color: ColorStyles.primaryColor,
                      ),
                      onPressed: _sendTextMessage,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
