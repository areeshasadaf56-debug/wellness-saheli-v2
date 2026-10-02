import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

/// MODULE: services/eligibility_api_service.dart
/// ROLE: Talks to the backend's contraceptive-eligibility endpoints
/// (GET /conditions, GET /methods_reference, GET /effectiveness,
/// POST /eligibility). Used by screens/protection_screen.dart.

/// A single selectable medical condition, as returned by GET /conditions.
class Condition {
  final String id;
  final String label;

  Condition({required this.id, required this.label});

  factory Condition.fromJson(Map<String, dynamic> json) {
    return Condition(id: json['id'] as String, label: json['label'] as String);
  }
}

/// A single contraceptive method, as returned by GET /methods_reference.
class MethodInfo {
  final String id;
  final String label;

  MethodInfo({required this.id, required this.label});

  factory MethodInfo.fromJson(Map<String, dynamic> json) {
    return MethodInfo(id: json['id'] as String, label: json['label'] as String);
  }
}

/// The eligibility result for one method, as returned by POST /eligibility.
///
/// `category` is NULLABLE: the backend sends `category: null` (with
/// `pending_review` and a `note` explaining why) when the WHO MEC matrix
/// has no rating yet for this method + the selected condition(s). That
/// is a normal, expected result -- not a parse error -- so it must be
/// handled as data, not thrown away.
class MethodResult {
  final String methodLabel;
  final int? category;
  final bool pendingReview;
  final String? note;

  MethodResult({
    required this.methodLabel,
    required this.category,
    this.pendingReview = false,
    this.note,
  });

  /// Tolerant parser: accepts a few likely key names for the label, and
  /// reads the category whether it arrives as int, num, string ("4"),
  /// or null (not yet assessed).
  factory MethodResult.fromJson(Map<String, dynamic> json) {
    final label =
        json['method_label'] ??
        json['methodLabel'] ??
        json['label'] ??
        json['method'] ??
        json['method_name'] ??
        json['name'];

    final rawCategory =
        json['category'] ?? json['rating'] ?? json['result'] ?? json['value'];

    int? category;
    if (rawCategory == null) {
      category = null;
    } else if (rawCategory is int) {
      category = rawCategory;
    } else if (rawCategory is num) {
      category = rawCategory.toInt();
    } else if (rawCategory is String) {
      final match = RegExp(r'\d+').firstMatch(rawCategory);
      category = match != null ? int.tryParse(match.group(0)!) : null;
    }

    if (label == null) {
      throw FormatException(
        'Unexpected eligibility item (keys: ${json.keys.toList()}): $json',
      );
    }

    final pendingReview = json['pending_review'] == true;
    final note = json['note'] as String?;

    return MethodResult(
      methodLabel: label.toString(),
      category: category,
      pendingReview: pendingReview,
      note: note,
    );
  }
}

/// One row of the effectiveness comparison, as returned by GET /effectiveness.
class EffectivenessEntry {
  final String method;
  final num typicalUseFailurePercent;
  final String? note;

  EffectivenessEntry({
    required this.method,
    required this.typicalUseFailurePercent,
    this.note,
  });

  factory EffectivenessEntry.fromJson(Map<String, dynamic> json) {
    return EffectivenessEntry(
      method: json['method'] as String,
      typicalUseFailurePercent: json['typical_use_failure_percent'] as num,
      note: json['note'] as String?,
    );
  }
}

class EligibilityApiService {
  Future<List<Condition>> fetchConditions() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/conditions'),
    );
    if (response.statusCode != 200) {
      throw Exception('Could not load conditions (${response.statusCode})');
    }
    final List<dynamic> data = jsonDecode(response.body);
    return data
        .map((e) => Condition.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<MethodInfo>> fetchMethodsReference() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/methods_reference'),
    );
    if (response.statusCode != 200) {
      throw Exception('Could not load methods (${response.statusCode})');
    }
    final List<dynamic> data = jsonDecode(response.body);
    return data
        .map((e) => MethodInfo.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<EffectivenessEntry>> fetchEffectiveness() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/effectiveness'),
    );
    if (response.statusCode != 200) {
      throw Exception(
        'Could not load effectiveness data (${response.statusCode})',
      );
    }
    final List<dynamic> data = jsonDecode(response.body);
    return data
        .map((e) => EffectivenessEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<MethodResult>> checkEligibility(List<String> conditionIds) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/eligibility'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'condition_ids': conditionIds}),
    );

    if (response.statusCode != 200) {
      String message = 'Could not check eligibility (${response.statusCode})';
      try {
        final body = jsonDecode(response.body);
        if (body is Map && body['detail'] != null) {
          message = body['detail'].toString();
        }
      } catch (_) {}
      throw Exception(message);
    }

    final decoded = jsonDecode(response.body);

    // Accept either a plain list or an object wrapping the list.
    List<dynamic> data;
    if (decoded is List) {
      data = decoded;
    } else if (decoded is Map) {
      final inner =
          decoded['results'] ??
          decoded['methods'] ??
          decoded['data'] ??
          decoded['eligibility'];
      if (inner is List) {
        data = inner;
      } else {
        throw FormatException(
          'Unexpected eligibility response: ${response.body}',
        );
      }
    } else {
      throw FormatException(
        'Unexpected eligibility response: ${response.body}',
      );
    }

    return data
        .map((e) => MethodResult.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}
