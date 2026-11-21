import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIService {
  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  static const _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/openai/chat/completions';

  static const _models = [
    'gemini-3.8-flash',
    'gemini-flash-latest',
    'gemini-2.0-flash',
  ];

  static const _systemPrompt = '''
You are SmartAID, a first-aid guidance assistant for university students in Zimbabwe.
Your job is to provide clear, calm, step-by-step FIRST-AID guidance for injuries and emergencies.

STRICT RULES:
1. You are NOT a doctor. Never diagnose. Never prescribe medication.
2. START your response with a triage line: "🚨 CALL EMERGENCY SERVICES NOW" or "✅ This can likely be managed with first aid".
3. Skip ALL background/medical explanations. Go STRAIGHT to actionable numbered steps.
4. Give at most 5 numbered steps. One line per step. Be concise.
5. If life-threatening (unconscious, heavy bleeding, difficulty breathing, suspected fracture, burns over large area, poisoning), tell the user to call emergency services immediately and give only the most critical steps.
6. End every response with: "⚠️ This is preliminary guidance only. Seek professional medical help if unsure or if symptoms worsen."
7. Keep the ENTIRE response under 150 words.
8. NEVER end mid-sentence. If running out of space, shorten the steps to fit.
''';

  /// Custom HTTP client that forces Google DNS (8.8.8.8 / 8.8.4.4)
  /// This bypasses broken/misconfigured DNS on the phone's network.
  static HttpClient _buildHttpClient() {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 20);
    client.findProxy = (uri) => 'DIRECT';

    // Force connection to use our own DNS by overriding the lookup.
    // This uses Google's DNS servers directly, bypassing the OS DNS.
    client.connectionFactory = (uri, proxyHost, proxyPort) {
      return _resolveWithGoogleDns(uri.host).then((addresses) {
        if (addresses.isEmpty) {
          throw const SocketException('DNS lookup failed');
        }
        return Socket.startConnect(addresses.first, uri.port);
      });
    };

    return client;
  }

  /// Resolves a hostname using Google's public DNS (8.8.8.8).
  /// Simple A-record query implemented via raw UDP DNS.
  static Future<List<InternetAddress>> _resolveWithGoogleDns(
    String host,
  ) async {
    // Try DNS over HTTPS first (more reliable than raw UDP in some networks)
    try {
      final dnsClient = HttpClient();
      dnsClient.connectionTimeout = const Duration(seconds: 10);

      final request = await dnsClient.getUrl(
        Uri.parse('https://dns.google/resolve?name=$host&type=A'),
      );
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      final data = jsonDecode(body);
      final answers = data['Answer'] as List?;
      if (answers != null && answers.isNotEmpty) {
        final ips = answers
            .where((a) => a['type'] == 1) // A record
            .map((a) => a['data'] as String)
            .toList();
        return ips.map((ip) => InternetAddress(ip)).toList();
      }
    } catch (_) {
      // Fall through to system DNS
    }

    // Fallback: system resolver
    return InternetAddress.lookup(host);
  }

  static Future<String> getFirstAidGuidance(String userMessage) async {
    if (_apiKey.isEmpty) {
      throw Exception('API key missing. Add GEMINI_API_KEY to your .env file.');
    }

    Exception? lastError;

    for (final model in _models) {
      for (int attempt = 1; attempt <= 2; attempt++) {
        try {
          return await _callModel(model, userMessage);
        } catch (e) {
          lastError = e is Exception ? e : Exception(e.toString());
          await Future.delayed(Duration(seconds: attempt));
        }
      }
    }

    throw lastError ?? Exception('All AI models are currently unavailable.');
  }

  static Future<String> _callModel(String model, String userMessage) async {
    final client = _buildHttpClient();

    try {
      final request = await client.postUrl(Uri.parse(_baseUrl));
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Authorization', 'Bearer $_apiKey');
      request.add(
        utf8.encode(
          jsonEncode({
            'model': model,
            'messages': [
              {'role': 'system', 'content': _systemPrompt},
              {'role': 'user', 'content': userMessage},
            ],
            'temperature': 0.3,
            'max_tokens': 1000,
          }),
        ),
      );

      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        final data = jsonDecode(body);
        final choice = data['choices'][0];
        final content = choice['message']['content'] as String;
        final finishReason = choice['finish_reason'];

        if (finishReason == 'length') {
          return '$content\n\n⚠️ (Response was cut off. Try asking a shorter question or ask for fewer steps.)';
        }
        return content;
      }

      if (response.statusCode == 404 || response.statusCode == 503) {
        throw Exception('Model $model unavailable (${response.statusCode})');
      }

      throw Exception('AI error (${response.statusCode}): $body');
    } finally {
      client.close();
    }
  }
}
