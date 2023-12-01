import 'dart:convert';
import 'package:http/http.dart' as http;

import 'env.dart';

class NetworkHandler {
  static Future<http.Response> get(String url) async {
    var response = await http.get(
      Uri.parse(formater(url)),
    );
    return response;
  }

  static Future<http.Response> getData(String url, dynamic data) async {
    var response = await http.get(
      Uri.http(formater(url), data),
    );
    return response;
  }

  static Future<http.Response> post(String url, Map<String, String> body) async {
    var response = await http.post(
      Uri.parse(formater(url)),
      body: (body),
    );
    return response;
  }

  static Future<http.Response> put(String url, int id, Map<String, String> body) async {
    var response = await http.put(
      Uri.parse(formater('$url/$id')),
      body: (body),
    );
    return response;
  }

  static Future<http.Response> delete(String url, int id) async {
    var response = await http.delete(
      Uri.parse(formater('$url/$id')),
      body: ({'id': '$id'}),
    );
    return response;
  }

  static String formater(String url) {
    return '${Constant.apiUrl}/$url';
  }
}
