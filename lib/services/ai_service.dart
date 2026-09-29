import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/ai_response.dart';
import '../models/health_profile.dart';

/// Thrown when there's no valid session to attach to a /chat request
/// (not signed in, or the session expired/was revoked server-side).
/// Callers should catch this separately from a generic network
/// failure so the UI can prompt "please sign in" instead of a vague
/// "couldn't reach the assistant" message.
class AuthRequiredException implements Exception {
  final String message;
  const AuthRequiredException([
    this.message = 'Please sign in to use AI Check-in.',
  ]);

  @override
  String toString() => message;
}

/// A file/image the user attached to a chat message, sent to the
/// backend as a base64 blob alongside the text. NOTE: the backend's
/// /chat endpoint must be updated to read `attachment` from the
/// request body for the AI to actually "see" this -- see the
/// developer guide. Until then this is delivered but may be ignored
/// server-side.
class ChatAttachment {
  final String fileName;
  final String mimeType;
  final String base64Data;
  const ChatAttachment({
    required this.fileName,
    required this.mimeType,
    required this.base64Data,
  });

  Map<String, dynamic> toJson() => {
    'file_name': fileName,
    'mime_type': mimeType,
    'data_base64': base64Data,
  };
}

class AiService {
  Future<AiResponse> sendMessage({
    required String message,
    required List<ConversationEntry> history,
    Map<String, dynamic>? profileContext,

    /// 'en' or 'ur' -- asks the assistant to reply in that language.
    /// NOTE: the backend must read `language` from the request body
    /// and use it to steer the AI's reply for this to take effect.
    String language = 'en',
    ChatAttachment? attachment,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    if (token == null) {
      throw const AuthRequiredException();
    }

    final uri = Uri.parse('${ApiConfig.baseUrl}/chat');
    final response = await http
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'message': message,
            'language': language,
            'history': history
                .map((e) => {'role': e.role, 'message': e.message})
                .toList(),
            // ignore: use_null_aware_elements
            if (profileContext != null) 'profile_context': profileContext,
            // ignore: use_null_aware_elements
            if (attachment != null) 'attachment': attachment.toJson(),
          }),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 401) {
      throw const AuthRequiredException(
        'Your session expired. Please sign in again.',
      );
    }

    if (response.statusCode != 200) {
      throw Exception(
        'Chat request failed (${response.statusCode}): ${response.body}',
      );
    }

    return AiResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}
