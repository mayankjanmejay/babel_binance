import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

class BinanceBase {
  final String? apiKey;
  final String? apiSecret;
  final String baseUrl;

  BinanceBase({this.apiKey, this.apiSecret, required this.baseUrl});

  Future<Map<String, dynamic>> sendRequest(
    String method,
    String path, {
    Map<String, dynamic>? params,
  }) async {
    final url = Uri.parse('$baseUrl$path');
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (apiKey != null) {
      headers['X-MBX-APIKEY'] = apiKey!;
    }

    params ??= {};
    params['timestamp'] = DateTime.now().millisecondsSinceEpoch;

    if (apiSecret != null) {
      final query = Uri(queryParameters: params.map((key, value) => MapEntry(key, value.toString()))).query;
      final signature = Hmac(sha256, utf8.encode(apiSecret!)).convert(utf8.encode(query)).toString();
      params['signature'] = signature;
    }
    
    final finalUrl = url.replace(queryParameters: params.map((key, value) => MapEntry(key, value.toString())));

    http.Response response;
    if (method == 'GET') {
      response = await http.get(finalUrl, headers: headers);
    } else if (method == 'POST') {
      response = await http.post(finalUrl, headers: headers);
    } else {
      throw Exception('Unsupported HTTP method');
    }

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data: ${response.statusCode} ${response.body}');
    }
  }
}