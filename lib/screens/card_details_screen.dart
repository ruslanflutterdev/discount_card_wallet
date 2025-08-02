import 'package:discount_card_wallet/models/discount_card_model.dart';
import 'package:flutter/material.dart';

class CardDetailsScreen extends StatelessWidget {
  final DiscountCardModel card;

  const CardDetailsScreen({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(card.storeName)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (card.frontImageUrl.isNotEmpty)
              Image.network(
                card.frontImageUrl,
                width: double.infinity,
                fit: BoxFit.fitWidth,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              ),
            if (card.backImageUrl.isNotEmpty) SizedBox(height: 16),
            if (card.backImageUrl.isNotEmpty)
              Image.network(
                card.backImageUrl,
                width: double.infinity,
                fit: BoxFit.fitWidth,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                card.notes.isNotEmpty ? card.notes : 'Нет заметок',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
