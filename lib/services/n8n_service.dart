import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/project_analysis_model.dart';

class N8nService {
  static final N8nService _instance = N8nService._internal();
  factory N8nService() => _instance;
  N8nService._internal();

  // Test (ephemeral) webhook: must click "Listen for test event" before each call.
  static const String n8nTestWebhookUrl =
      'https://your-n8n-instance.com/webhook-test/scrum-master';
  // Production (persistent) webhook: requires workflow Active toggle ON.
  static const String n8nProdWebhookUrl =
      'https://your-n8n-instance.com/webhook/scrum-master';

  // Developer override: set to true to force test URL.
  bool useTestUrl = false;

  Uri _currentWebhookUri() =>
      Uri.parse(useTestUrl ? n8nTestWebhookUrl : n8nProdWebhookUrl);

  Future<http.Response> _postToWebhook(Uri uri, Map<String, dynamic> payload) {
    return http.post(
      uri,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
  }

  /// Send prompt to n8n for AI analysis
  /// Returns ProjectAnalysis with milestones, subtasks, APIs, etc.
  Future<ProjectAnalysis> analyzeProjectPrompt({
    required String projectId,
    required String projectName,
    required String prompt,
    required String userId,
  }) async {
    try {
      final payload = {
        'projectId': projectId,
        'projectName': projectName,
        'prompt': prompt,
        'userId': userId,
        'timestamp': DateTime.now().toIso8601String(),
      };

      final uri = _currentWebhookUri();
      http.Response response = await _postToWebhook(uri, payload).timeout(
        const Duration(minutes: 5),
        onTimeout: () {
          throw Exception('n8n request timeout');
        },
      );

      // If production URL returns 404 (inactive) attempt test URL automatically.
      if (!useTestUrl &&
          uri.toString().contains('/webhook/') &&
          response.statusCode == 404 &&
          response.body.contains('not registered')) {
        final testUri = Uri.parse(n8nTestWebhookUrl);
        response = await _postToWebhook(testUri, payload).timeout(
          const Duration(minutes: 5),
          onTimeout: () {
            throw Exception('n8n request timeout (test fallback)');
          },
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final data = jsonDecode(response.body);

          // Check if response contains actual data or just a "started" message
          if (data['message'] != null && data['milestones'] == null) {
            throw Exception(
              'Webhook returned too early. Please set Webhook node "Respond" to "When Last Node Finishes" in n8n.',
            );
          }

          // Validate that we have actual analysis data
          if (data['milestones'] == null && data['requiredApis'] == null) {
            throw Exception('N8n response missing analysis data');
          }

          return ProjectAnalysis.fromMap({
            'projectId': projectId,
            'projectName': projectName,
            'prompt': prompt,
            'milestones': data['milestones'] ?? [],
            'requiredApis': data['requiredApis'] ?? [],
            'schedules': data['schedules'] ?? [],
            'reminders': data['reminders'] ?? [],
            'processedAt': DateTime.now().toIso8601String(),
          });
        } catch (parseError) {
          throw Exception('Failed to parse n8n response: $parseError');
        }
      } else if (response.statusCode == 404) {
        throw Exception('N8n webhook not registered / workflow inactive.');
      } else {
        throw Exception(
          'Failed to analyze prompt: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('N8n analysis error: $e');
    }
  }
}
