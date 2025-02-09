import 'dart:convert';
import 'package:http/http.dart' as http;

class PollinationsService {
  static const String _baseUrl = 'https://api.pollinations.ai/v1';
  final http.Client _client;

  PollinationsService({http.Client? client}) : _client = client ?? http.Client();

  Future<String> generateText(String prompt) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/generate/text'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'prompt': prompt,
          'max_tokens': 100,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['text'] ?? '';
      } else {
        throw Exception('Failed to generate text: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error generating text: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}
