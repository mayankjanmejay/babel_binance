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
    params ??= {};
    if (apiSecret != null) {
      params['timestamp'] = DateTime.now().millisecondsSinceEpoch;
      final query = Uri(queryParameters: params.map((key, value) => MapEntry(key, value.toString()))).query;
      final signature = Hmac(sha256, utf8.encode(apiSecret!)).convert(utf8.encode(query)).toString();
      params['signature'] = signature;
    }

    final uri = Uri.parse('$baseUrl$path').replace(
      queryParameters:
          params.map((key, value) => MapEntry(key, value.toString())),
    );

    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (apiKey != null) 'X-MBX-APIKEY': apiKey!,
    };

    http.Response response;
    switch (method.toUpperCase()) {
      case 'GET':
        response = await http.get(uri, headers: headers);
        break;
      case 'POST':
        response = await http.post(uri, headers: headers);
        break;
      case 'DELETE':
        response = await http.delete(uri, headers: headers);
        break;
      case 'PUT':
        response = await http.put(uri, headers: headers);
        break;
      default:
        throw Exception('Unsupported HTTP method: $method');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data: ${response.statusCode} ${response.body}');
    }
  }
}