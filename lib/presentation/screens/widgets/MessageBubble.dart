import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import '../styles.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final int subject;
  final DateTime date;

  const MessageBubble({
    super.key,
    required this.message,
    required this.subject,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    bool isLeft = subject == 1;
    Color bubbleColor = isLeft ? Colors.grey[200]! : ColorStyles.secondaryColor;
    String formattedTime = DateFormat('hh:mm a').format(date);

    Widget messageContent = Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: MarkdownBody(
        data: message,
        styleSheet: MarkdownStyleSheet(
          p: TextStyle(
            fontSize: 16,
            color: isLeft ? ColorStyles.textColor : Colors.white,
          ),
        ),
        selectable: true,
      ),
    );

    Widget infoRow;
    if (isLeft) {
      infoRow = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/image/shine.png',
            width: 16,
            height: 16,
            color: Colors.purple,
            colorBlendMode: BlendMode.srcIn,
          ),
          const SizedBox(width: 4.0),
          const Text(
            "Conin IA",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: ColorStyles.primaryColor,
            ),
          ),
        ],
      );
    } else {
      infoRow = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Tú",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8.0),
          Text(
            formattedTime,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      );
    }

    Widget bubbleColumn = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
      isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        messageContent,
        const SizedBox(height: 4.0),
        infoRow,
      ],
    );

    Widget bubbleWithConstraints = ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: MediaQuery.of(context).size.width * 0.1,
        maxWidth: MediaQuery.of(context).size.width * 0.7,
      ),
      child: IntrinsicWidth(child: bubbleColumn),
    );

    Widget avatar = CircleAvatar(
      radius: 16,
      backgroundImage: AssetImage(
        isLeft ? 'assets/image/conin.png' : 'assets/image/user.png',
      ),
    );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
        isLeft ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: isLeft
            ? [
          avatar,
          const SizedBox(width: 8.0),
          bubbleWithConstraints,
        ]
            : [
          bubbleWithConstraints,
          const SizedBox(width: 8.0),
          avatar,
        ],
      ),
    );
  }
}
