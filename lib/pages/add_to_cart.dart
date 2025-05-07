import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> addToCart(
    BuildContext context,
    int productId,
    int? parametrId,
    ) async {
  final supabase = Supabase.instance.client;

  try {

    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Вы не авторизованы'),
        ),
      );
      return;
    }


    var query = supabase
        .from('Cart')
        .select('CartItemID, Quantity')
        .eq('ProductID', productId)
        .eq('ClientID', userId);

    if (parametrId != null) {
      query = query.eq('ParametrID', parametrId);
    }

    final existingCartItem = await query.maybeSingle();

    if (existingCartItem != null) {

      final newQuantity = existingCartItem['Quantity'] + 1;

      await supabase
          .from('Cart')
          .update({'Quantity': newQuantity})
          .eq('CartItemID', existingCartItem['CartItemID']);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Количество товара в корзине увеличено'),
        ),
      );
    } else {

      await supabase.from('Cart').insert({
        'ProductID': productId,
        'ClientID': userId,
        'Quantity': 1,
        'ParametrID': parametrId,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Товар успешно добавлен в корзину'),
        ),
      );
    }
  } catch (error) {
    // проверка текста ошибки от БД
    if (
        error.toString().contains('Запрашиваемое количество')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('В наличии больше нет'),

        ),
      );
    } else {
      // Все остальные ошибки
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при добавлении в корзину: $error'),

        ),
      );
      print('Неизвестная ошибка: $error');
    }
  }
}