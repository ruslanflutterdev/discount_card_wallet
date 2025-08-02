import 'package:discount_card_wallet/models/discount_card_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/discount_cards_provider.dart';
import '../providers/supabase_provider.dart';
import 'add_card_screen.dart';

class CardDetailsScreen extends ConsumerWidget {
  final DiscountCardModel card;

  const CardDetailsScreen({super.key, required this.card});

  Future<void> _deleteCard(BuildContext context, WidgetRef ref) async {
    final supabase = ref.read(supabaseProvider);
    try {
      if (card.frontImageUrl.isNotEmpty) {
        final frontImagePath = card.frontImageUrl.split('user_uploads/')[1];
        await supabase.storage.from('cards').remove([
          'user_uploads/$frontImagePath',
        ]);
      }
      if (card.backImageUrl.isNotEmpty) {
        final backImagePath = card.backImageUrl.split('user_uploads/')[1];
        await supabase.storage.from('cards').remove([
          'user_uploads/$backImagePath',
        ]);
      }
      if (card.storeLogoUrl.isNotEmpty) {
        final logoPath = card.storeLogoUrl.split('user_uploads/')[1];
        await supabase.storage.from('cards').remove(['user_uploads/$logoPath']);
      }

      await supabase.from('discount_cards').delete().eq('id', card.id);

      if (!context.mounted) return;
      ref.invalidate(discountCardsProvider);
      Navigator.of(context).pop();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка удаления карты: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Подтвердить удаление'),
          content: Text(
            'Вы уверены, что хотите удалить карту "${card.storeName}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteCard(context, ref);
              },
              child: Text('Удалить'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(card.storeName),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddCardScreen(cardToEdit: card),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => _showDeleteConfirmationDialog(context, ref),
          ),
        ],
      ),
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
                  return Center(child: CircularProgressIndicator());
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
                  return Center(child: CircularProgressIndicator());
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
