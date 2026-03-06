import 'detection_result.dart';

/// A detection history record
class HistoryItem {
  final String id;
  final String userId;
  final List<Detection> detections;
  final Map<String, dynamic>? diagnosis;
  final String? imagePath;
  final String? imageBase64;
  final DateTime timestamp;
  final String? location;
  final String? notes;

  const HistoryItem({
    required this.id,
    required this.userId,
    this.detections = const [],
    this.diagnosis,
    this.imagePath,
    this.imageBase64,
    required this.timestamp,
    this.location,
    this.notes,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    List<Detection> detections = [];
    if (json['detections'] is List) {
      detections = (json['detections'] as List)
          .map((d) => Detection.fromJson(d as Map<String, dynamic>))
          .toList();
    }

    return HistoryItem(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      detections: detections,
      diagnosis: json['diagnosis'] as Map<String, dynamic>?,
      imagePath: json['image_path'] as String?,
      imageBase64: json['image_base64'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      location: json['location'] as String?,
      notes: json['notes'] as String?,
    );
  }

  /// The primary/top detection name
  String get primaryDisease {
    if (detections.isEmpty) return 'Unknown';
    return detections.first.className;
  }

  /// The primary confidence
  String get primaryConfidence {
    if (detections.isEmpty) return '—';
    return detections.first.confidencePercent;
  }

  /// Formatted timestamp
  String get formattedDate {
    final d = timestamp;
    return '${d.day}/${d.month}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}
