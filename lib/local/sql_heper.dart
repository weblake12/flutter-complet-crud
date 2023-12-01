import 'dart:async';
import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:sqflite_crud/local/models.dart';
import 'package:sqflite_crud/network_handler.dart';

class SQLHelper {
  static Future<int> createItem(Item item) async {
    int result = 0;
    var response = await NetworkHandler.post('items', {'title': item.title, 'description': item.description});
    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      result = responseBody['data']['insertId'];
    }
    return result;
  }

  static Future<int> updateItem(Item item) async {
    int result = 0;
    var response = await NetworkHandler.put('items', item.id!, {'id': '${item.id}', 'title': item.title, 'description': item.description});
    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      result = responseBody['data']['insertId'];
    }
    return result;
  }

  static Future<List<Item>> getItems() async {
    Logger().i('!! getItems');
    List<Item> result = [];
    var response = await NetworkHandler.get('items');
    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      Logger().i(responseBody);
      result = responseBody['data'].map<Item>((json) => Item.fromJson(json)).toList();
    }
    return result;
  }

  static FutureOr<bool> deleteItem(int id) async {
    bool result = false;
    var response = await NetworkHandler.delete('items', id);
    if (response.statusCode == 200) {
      result = true;
    }
    return result;
  }
}
