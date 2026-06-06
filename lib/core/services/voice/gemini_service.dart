import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  late final Dio _dio;
  late final String _apiKey;

  GeminiService() {
    _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
    ));
  }

  Future<Map<String, dynamic>?> processVoiceCommand(String audioPath) async {
    try {
      final prompt = '''
You are an intelligent voice assistant embedded inside a Flutter mobile application for ride-sharing/delivery drivers (called Zona X).
The driver is speaking to you in Arabic (most likely Egyptian dialect) or English in the attached audio.
Listen carefully, transcribe what they said, understand their intent, and map it to one of the allowed actions in the app.

Here are the app capabilities and rules:
1. Demand Grid / Hotspots (فين الزحمة؟ / عايز شغل): Action `demand_grid`
2. Find best zone / Route to high demand (وديني اكتر مكان فيه شغل / اعلى ربح): Action `find_best_zone`
3. Earnings (أرباحي كام؟ / عملت كام النهاردة؟): Action `earnings`
4. Profile (ملفي الشخصي / عايز اعدل بياناتي): Action `profile`
5. Trips / Accept Trip (اقبل الرحلة / رحلاتي): Action `trips`

If the user asks something completely unrelated to driving, earnings, trips, or the app (e.g., "أحجزلي طيارة", "شغل أغنية", "مين فاز في الماتش"), you must politely refuse.

You must respond ONLY with a raw JSON object in the following format (no markdown, no backticks):
{
  "is_supported": true/false,
  "intent": "demand_grid | find_best_zone | earnings | profile | trips | unknown",
  "action": "navigate_to_demand | find_best_zone | navigate_to_earnings | navigate_to_profile | navigate_to_trips | none",
  "transcription": "The exact text the user said in Egyptian Arabic",
  "message_ar": "الرد اللي هيتقال للسواق بصوت طبيعي باللغة العربية بلهجة مصرية"
}
''';

      // Read audio file and encode to base64
      final audioFile = File(audioPath);
      final bytes = await audioFile.readAsBytes();
      final base64Audio = base64Encode(bytes);

      // Determine mime type from extension
      final extension = audioPath.split('.').last.toLowerCase();
      String mimeType = 'audio/wav';
      if (extension == 'm4a') mimeType = 'audio/mp4';
      if (extension == 'aac') mimeType = 'audio/aac';
      if (extension == 'mp3') mimeType = 'audio/mp3';

      // Build REST API request
      final url =
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent';

      final requestBody = {
        'contents': [
          {
            'parts': [
              {'text': prompt},
              {
                'inlineData': {
                  'mimeType': mimeType,
                  'data': base64Audio,
                }
              }
            ]
          }
        ]
      };

      print('GeminiService: Sending audio (${bytes.length} bytes, $mimeType) to Gemini...');

      final response = await _dio.post(
        url,
        data: requestBody,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'x-goog-api-key': _apiKey,
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final candidates = response.data['candidates'] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'];
          final parts = content['parts'] as List?;
          if (parts != null && parts.isNotEmpty) {
            String rawJson = parts[0]['text']?.toString().trim() ?? '';

            // Clean up markdown if the model accidentally includes it
            if (rawJson.startsWith('```json')) {
              rawJson = rawJson.substring(7);
            }
            if (rawJson.startsWith('```')) {
              rawJson = rawJson.substring(3);
            }
            if (rawJson.endsWith('```')) {
              rawJson = rawJson.substring(0, rawJson.length - 3);
            }
            rawJson = rawJson.trim();

            print('GeminiService: Response: $rawJson');
            return jsonDecode(rawJson);
          }
        }
      }
    } on DioException catch (e) {
      print('GeminiService DioError: ${e.response?.statusCode}');
      print('GeminiService DioError Body: ${e.response?.data}');
      print('GeminiService DioError Message: ${e.message}');
    } catch (e) {
      print('GeminiService Error: $e');
    }
    return null;
  }
}
