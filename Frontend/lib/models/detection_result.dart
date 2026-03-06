/// A single bounding box detection from YOLO
class BoundingBox {
  final double x;
  final double y;
  final double width;
  final double height;
  final double x1;
  final double y1;
  final double x2;
  final double y2;

  const BoundingBox({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
  });

  factory BoundingBox.fromJson(Map<String, dynamic> json) {
    return BoundingBox(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      x1: (json['x1'] as num).toDouble(),
      y1: (json['y1'] as num).toDouble(),
      x2: (json['x2'] as num).toDouble(),
      y2: (json['y2'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'x': x,
        'y': y,
        'width': width,
        'height': height,
        'x1': x1,
        'y1': y1,
        'x2': x2,
        'y2': y2,
      };
}

/// Tracking statistics for primary detection
class TrackingStats {
  final int occurrenceCount;
  final int totalFrames;
  final double occurrencePercentage;
  final bool isStable;

  const TrackingStats({
    required this.occurrenceCount,
    required this.totalFrames,
    required this.occurrencePercentage,
    required this.isStable,
  });

  factory TrackingStats.fromJson(Map<String, dynamic> json) {
    return TrackingStats(
      occurrenceCount: json['occurrence_count'] as int,
      totalFrames: json['total_frames'] as int,
      occurrencePercentage: (json['occurrence_percentage'] as num).toDouble(),
      isStable: json['is_stable'] as bool,
    );
  }
}

/// A single detection from the model
class Detection {
  final int classId;
  final String className;
  final double confidence;
  final BoundingBox boundingBox;
  final TrackingStats? trackingStats;

  const Detection({
    required this.classId,
    required this.className,
    required this.confidence,
    required this.boundingBox,
    this.trackingStats,
  });

  factory Detection.fromJson(Map<String, dynamic> json) {
    return Detection(
      classId: json['class_id'] as int,
      className: json['class_name'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      boundingBox: BoundingBox.fromJson(json['bounding_box']),
      trackingStats: json['tracking_stats'] != null
          ? TrackingStats.fromJson(json['tracking_stats'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'class_id': classId,
        'class_name': className,
        'confidence': confidence,
        'bounding_box': boundingBox.toJson(),
      };

  /// Formatted confidence string (e.g., "87.5%")
  String get confidencePercent => '${(confidence * 100).toStringAsFixed(1)}%';

  /// Severity color helper based on class name
  String get severityHint {
    final lower = className.toLowerCase();
    if (lower.contains('healthy') || lower.contains('leaf') && !lower.contains('blight') && !lower.contains('spot') && !lower.contains('rot') && !lower.contains('rust') && !lower.contains('mold') && !lower.contains('virus') && !lower.contains('mites') && !lower.contains('mildew') && !lower.contains('bacterial')) {
      return 'healthy';
    }
    return 'diseased';
  }
}

/// Full detection response from the API
class DetectionResult {
  final bool success;
  final String? detectionId;
  final List<Detection> detections;
  final Detection? primaryDetection;
  final Map<String, dynamic>? diagnosis;
  final Map<String, int>? imageSize;
  final Map<String, double>? timing;
  final String? error;

  const DetectionResult({
    required this.success,
    this.detectionId,
    this.detections = const [],
    this.primaryDetection,
    this.diagnosis,
    this.imageSize,
    this.timing,
    this.error,
  });

  factory DetectionResult.fromJson(Map<String, dynamic> json) {
    return DetectionResult(
      success: json['success'] as bool,
      detectionId: json['detection_id'] as String?,
      detections: (json['detections'] as List<dynamic>?)
              ?.map((d) => Detection.fromJson(d as Map<String, dynamic>))
              .toList() ??
          [],
      primaryDetection: json['primary_detection'] != null
          ? Detection.fromJson(json['primary_detection'] as Map<String, dynamic>)
          : null,
      diagnosis: json['diagnosis'] as Map<String, dynamic>?,
      imageSize: json['image_size'] != null
          ? Map<String, int>.from(
              (json['image_size'] as Map).map((k, v) => MapEntry(k, (v as num).toInt())))
          : null,
      timing: json['timing'] != null
          ? Map<String, double>.from(
              (json['timing'] as Map).map((k, v) => MapEntry(k, (v as num).toDouble())))
          : null,
      error: json['error'] as String?,
    );
  }

  /// Whether any diseases were found
  bool get hasDetections => detections.isNotEmpty;

  /// Whether a primary detection exists
  bool get hasPrimary => primaryDetection != null;

  /// Whether the plant is healthy
  bool get isHealthy =>
      hasPrimary && primaryDetection!.severityHint == 'healthy';
}
