import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../styles.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final int subject;
  final DateTime date;
  final bool myLocationEnabled;

  const MessageBubble({
    super.key,
    required this.message,
    required this.subject,
    required this.date,
    this.myLocationEnabled = false,
  });

  Map<String, String>? extractCoordinates(String msg) {
    if (msg.trim().startsWith("maps[")) {
      try {
        final start = msg.indexOf('[');
        final end = msg.indexOf(']');
        if (start != -1 && end != -1 && end > start) {
          final coordsString = msg.substring(start + 1, end);
          final coords = coordsString.split(',');
          if (coords.length >= 2) {
            Map<String, String> result = {
              "lat": coords[0].trim(),
              "lon": coords[1].trim()
            };
            if (coords.length >= 3) {
              result["name"] = coords[2].trim();
            }
            return result;
          }
        }
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    bool isLeft = subject == 1;
    Color bubbleColor = isLeft ? Colors.grey[200]! : ColorStyles.secondaryColor;
    String formattedTime = DateFormat('hh:mm a').format(date);

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
          const Text("Tú", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8.0),
          Text(
            formattedTime,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      );
    }

    final coords = extractCoordinates(message);
    Widget bubbleContent;

    if (isLeft && coords != null) {
      final double? lat = double.tryParse(coords["lat"]!);
      final double? lon = double.tryParse(coords["lon"]!);

      if (lat != null && lon != null) {
        final CameraPosition initialCameraPosition = CameraPosition(
          target: LatLng(lat, lon),
          zoom: 15,
        );
        final Marker marker = Marker(
          markerId: const MarkerId("ubicacion"),
          position: LatLng(lat, lon),
        );

        // Creamos un contenedor único que incluya el nombre (si existe) y el mapa.
        Widget mapAndNameBubble = Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (coords.containsKey("name"))
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    coords["name"]!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: ColorStyles.textColor
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              SizedBox(
                height: 250,
                width: MediaQuery.of(context).size.width * 0.7,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: GoogleMap(
                    initialCameraPosition: initialCameraPosition,
                    markers: {marker},
                    zoomControlsEnabled: false,
                    myLocationButtonEnabled: true,
                    myLocationEnabled: myLocationEnabled,
                    scrollGesturesEnabled: true,
                    zoomGesturesEnabled: true,
                    rotateGesturesEnabled: true,
                    tiltGesturesEnabled: true,
                    gestureRecognizers:
                    <Factory<OneSequenceGestureRecognizer>>{
                      Factory<OneSequenceGestureRecognizer>(
                              () => EagerGestureRecognizer()),
                    },
                  ),
                ),
              ),
            ],
          ),
        );

        final mapsUri = Uri.https('www.google.com', '/maps/search/', {
          'api': '1',
          'query': '$lat,$lon',
        });
        Widget locationButton = GestureDetector(
          onTap: () async {
            if (await canLaunchUrl(mapsUri)) {
              await launchUrl(
                mapsUri,
                mode: LaunchMode.externalApplication,
              );
            }
          },
          child: Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.location_on, color: Colors.white, size: 12),
                SizedBox(width: 8),
                Text(
                  'Ir a ubicación',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        );

        bubbleContent = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
          isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            mapAndNameBubble,
            const SizedBox(height: 5),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              child: locationButton,
            ),
            const SizedBox(height: 4),
            infoRow,
          ],
        );
      } else {
        bubbleContent = _buildMarkdownContent(bubbleColor, isLeft);
      }
    } else {
      bubbleContent = _buildMarkdownContent(bubbleColor, isLeft);
    }

    Widget bubbleWithConstraints = ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: MediaQuery.of(context).size.width * 0.1,
        maxWidth: MediaQuery.of(context).size.width * 0.7,
      ),
      child: IntrinsicWidth(child: bubbleContent),
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
            ? [avatar, const SizedBox(width: 8.0), bubbleWithConstraints]
            : [bubbleWithConstraints, const SizedBox(width: 8.0), avatar],
      ),
    );
  }

  Widget _buildMarkdownContent(Color bubbleColor, bool isLeft) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
      isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Container(
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
        ),
        const SizedBox(height: 4.0),
        isLeft
            ? Row(
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
        )
            : Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Tú", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8.0),
            Text(
              DateFormat('hh:mm a').format(date),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }
}
