import 'dart:io';

import 'package:flutter/material.dart';

class ImagePreview extends StatelessWidget {
  final File? file;
  final String label;
  final VoidCallback onClear;

  const ImagePreview({
    super.key,
    required this.file,
    required this.label,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style:  TextStyle(fontWeight: FontWeight.bold)),
         SizedBox(height: 5),
        if (file != null)
          Stack(
            children: [
              Image.file(
                file!,
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
              ),
              Positioned(
                top: 5,
                right: 5,
                child: IconButton(
                  icon:  Icon(Icons.cancel, color: Colors.red),
                  onPressed: onClear,
                ),
              ),
            ],
          )
        else
          Container(
            height: 180,
            width: double.infinity,
            color: Colors.grey[300],
            alignment: Alignment.center,
            child:  Text('Нет изображения'),
          ),
         SizedBox(height: 10),
      ],
    );
  }
}
