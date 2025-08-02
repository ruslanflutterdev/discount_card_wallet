import 'package:discount_card_wallet/models/discount_card_model.dart';
import 'package:discount_card_wallet/providers/supabase_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final discountCardsProvider = FutureProvider<List<DiscountCardModel>>((
  ref,
) async {
  final supabase = ref.read(supabaseProvider);
  final response = await supabase
      .from('discount_cards')
      .select()
      .order('created_at', ascending: false);
  return (response as List)
      .map((json) => DiscountCardModel.fromJson(json))
      .toList();
});
