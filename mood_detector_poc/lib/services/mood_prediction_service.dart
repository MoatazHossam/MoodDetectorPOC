import 'dart:convert';

import 'package:http/http.dart' as http;

import 'web_service.dart';

/// Exception thrown when the mood prediction service fails to return a
/// successful response.
class MoodPredictionException implements Exception {
  MoodPredictionException(this.message, {this.statusCode, this.body});

  final String message;
  final int? statusCode;
  final String? body;

  @override
  String toString() {
    final buffer = StringBuffer('MoodPredictionException: ')
      ..write(message);
    if (statusCode != null) {
      buffer.write(' (statusCode: ');
      buffer.write(statusCode);
      buffer.write(')');
    }
    if (body != null) {
      buffer.write(' Response: ');
      buffer.write(body);
    }
    return buffer.toString();
  }
}

/// DTO returned by the remote mood prediction service.
class MoodPrediction {
  MoodPrediction({
    required this.input,
    required this.rawScore,
    required this.scaledScore,
  });

  final String input;
  final double rawScore;
  final double scaledScore;

  factory MoodPrediction.fromJson(Map<String, dynamic> json) {
    return MoodPrediction(
      input: json['input'] as String? ?? '',
      rawScore: (json['raw_score'] as num).toDouble(),
      scaledScore: (json['scaled_score'] as num).toDouble(),
    );
  }
}

/// Service responsible for sending text inputs to the prediction API and
/// parsing the response payload.
class MoodPredictionService {
  MoodPredictionService({WebService? webService})
      : _webService = webService ??
            WebService(baseUrl: _defaultBaseUrl, client: http.Client());

  static const String _defaultBaseUrl = 'http://101.46.64.59:8000';
  final WebService _webService;

  Future<MoodPrediction> predictMood(String text) async {
    final response = await _webService.post(
      '/api/predict',
      body: {'text': text},
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return MoodPrediction.fromJson(decoded);
      } on FormatException catch (error) {
        throw MoodPredictionException(
          'Failed to parse the prediction response: ${error.message}',
          statusCode: response.statusCode,
          body: response.body,
        );
      }
    }

    throw MoodPredictionException(
      'Mood prediction request failed',
      statusCode: response.statusCode,
      body: response.body,
    );
  }

  void dispose() {
    _webService.dispose();
  }
}
