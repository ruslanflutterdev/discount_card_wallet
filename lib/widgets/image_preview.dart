import 'dart:io';
import 'package:flutter/material.dart';

class ImagePreview extends StatelessWidget {
  final File? file;
  final String? imageUrl;
  final String label;
  final VoidCallback onClear;

  const ImagePreview({
    super.key,
    this.file,
    this.imageUrl,
    required this.label,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;
    if (file != null) {
      imageWidget = Image.file(file!, fit: BoxFit.cover);
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      imageWidget = Image.network(imageUrl!, fit: BoxFit.cover);
    } else {
      imageWidget = Container(
        alignment: Alignment.center,
        child: Text('Нет изображения'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 5),
        SizedBox(
          height: 180,
          width: double.infinity,
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(color: Colors.grey[300], child: imageWidget),
              ),
              if (file != null || (imageUrl != null && imageUrl!.isNotEmpty))
                Positioned(
                  top: 5,
                  right: 5,
                  child: IconButton(
                    icon: Icon(Icons.cancel, color: Colors.red),
                    onPressed: onClear,
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
