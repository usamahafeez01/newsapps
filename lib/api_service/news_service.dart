import 'dart:convert';
import 'package:http/http.dart' as http;

class NewsService {
  final String apiKey = '15cd6057c2fe4b069110dba533b457b7';
  final String baseUrl = 'https://newsapi.org/v2';

  Future<List<dynamic>> fetchNews(String category) async {
    final url = Uri.parse('$baseUrl/top-headlines?country=us&category=$category&apiKey=$apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['articles'];
    } else {
      throw Exception('Failed to load news');
    }
  }
}
