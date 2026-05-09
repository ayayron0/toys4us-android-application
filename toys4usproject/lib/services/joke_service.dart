import 'dart:convert';

import 'package:http/http.dart' as http;

class ToyJoke {
  const ToyJoke({required this.setup, required this.punchline});

  final String setup;
  final String punchline;
}

class JokeService {
  static const String jokeUrl =
      'https://official-joke-api.appspot.com/random_joke';

  Future<ToyJoke> fetchJoke() async {
    final response = await http
        .get(Uri.parse(jokeUrl))
        .timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) {
      throw Exception('Joke API returned ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;

    return ToyJoke(
      setup: json['setup']?.toString() ?? 'Why did the toy smile?',
      punchline: json['punchline']?.toString() ?? 'Because playtime started.',
    );
  }
}
