import 'package:discount_card_wallet/providers/discount_cards_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardsAsync = ref.watch(discountCardsProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Мои дисконтные карты')),
      body: cardsAsync.when(
        data: (cards) => ListView.builder(
          itemCount: cards.length,
          itemBuilder: (context, index) {
            final card = cards[index];
            return ListTile(
              leading: card.storeLogoUrl.isNotEmpty
                  ? Image.network(card.storeLogoUrl, width: 40, height: 40)
                  : Icon(Icons.card_giftcard),
              title: Text(card.storeName),
              subtitle: Text(card.createdAt.toLocal().toString()),
              onTap: () {},
            );
          },
        ),
        loading: () => Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Ошибка загрузки: $e')),
      ),
    );
  }
}
