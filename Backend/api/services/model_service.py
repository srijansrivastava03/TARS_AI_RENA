"""
AgriScan Backend - YOLO Model Service
Handles plant disease detection using YOLO model with primary detection tracking
"""

import time
import base64
import io
import numpy as np
from PIL import Image
from pathlib import Path
import sys
from collections import Counter

# Add parent directory to path
sys.path.append(str(Path(__file__).parent.parent))

from config import config


class YOLOModelService:
    """Service for YOLO model inference with primary detection tracking"""
    
    def __init__(self):
        """Initialize YOLO model"""
        self.model = None
        self.class_names = []
        self.load_model()
        self.load_labels()
        
        # Primary detection tracking (for continuous detection scenarios)
        self.detection_history = []  # Store recent detection results
        self.history_size = 45  # Track last 45 frames/images
    
    def load_model(self):
        """Load YOLO model"""
        try:
            from ultralytics import YOLO
            from ultralytics.nn.tasks import DetectionModel
            import torch
            
            if not config.MODEL_PATH.exists():
                raise FileNotFoundError(f"Model not found at {config.MODEL_PATH}")
            
            # Fix for PyTorch 2.6 - allow loading ultralytics models
            # IMPORTANT: Pass the actual class object, not a string!
            torch.serialization.add_safe_globals([DetectionModel])
            
            self.model = YOLO(str(config.MODEL_PATH))
            print(f"✅ Model loaded from {config.MODEL_PATH}")
            
        except Exception as e:
            print(f"❌ Error loading model: {e}")
            self.model = None
    
    def load_labels(self):
        """Load class labels"""
        try:
            if config.LABELS_PATH.exists():
                with open(config.LABELS_PATH, 'r') as f:
                    self.class_names = [line.strip() for line in f.readlines()]
                print(f"✅ Loaded {len(self.class_names)} class labels")
            else:
                print(f"⚠️  Labels file not found at {config.LABELS_PATH}")
                
        except Exception as e:
            print(f"❌ Error loading labels: {e}")
    
    def preprocess_image(self, image_data):
        """
        Preprocess image for model inference
        Args:
            image_data: base64 string or PIL Image or numpy array
        Returns:
            PIL Image
        """
        try:
            if isinstance(image_data, str):
                # Base64 string
                if image_data.startswith('data:image'):
                    # Remove data URL prefix
                    image_data = image_data.split(',')[1]
                
                image_bytes = base64.b64decode(image_data)
                image = Image.open(io.BytesIO(image_bytes))
                
            elif isinstance(image_data, bytes):
                # Raw bytes
                image = Image.open(io.BytesIO(image_data))
                
            elif isinstance(image_data, np.ndarray):
                # Numpy array
                image = Image.fromarray(image_data)
                
            elif isinstance(image_data, Image.Image):
                # Already a PIL Image
                image = image_data
                
            else:
                raise ValueError(f"Unsupported image type: {type(image_data)}")
            
            # Convert to RGB if necessary
            if image.mode != 'RGB':
                image = image.convert('RGB')
            
            return image
            
        except Exception as e:
            raise ValueError(f"Error preprocessing image: {e}")
    
    def detect(self, image_data, confidence_threshold=None, iou_threshold=None, track_primary=True):
        """
        Detect plant diseases in image with primary detection tracking
        Args:
            image_data: Image data (base64, PIL, numpy, bytes)
            confidence_threshold: Minimum confidence score (default from config)
            iou_threshold: IoU threshold for NMS (default from config)
            track_primary: Enable primary detection tracking (default True)
        Returns:
            dict: Detection results with primary detection highlighted
        """
        if self.model is None:
            return {
                'success': False,
                'error': 'Model not loaded',
                'detections': [],
                'primary_detection': None
            }
        
        try:
            # Preprocess image
            start_time = time.time()
            image = self.preprocess_image(image_data)
            preprocess_time = time.time() - start_time
            
            # Set thresholds
            conf = confidence_threshold or config.CONFIDENCE_THRESHOLD
            iou = iou_threshold or config.IOU_THRESHOLD
            
            # Run inference
            inference_start = time.time()
            results = self.model(
                image,
                conf=conf,
                iou=iou,
                imgsz=config.IMG_SIZE,
                verbose=False
            )
            inference_time = time.time() - inference_start
            
            # Format results
            detections = self.format_results(results[0], image.size)
            
            # Track primary detection if enabled
            primary_detection = None
            if track_primary and detections:
                primary_detection = self.update_primary_detection(detections)
            
            total_time = time.time() - start_time
            
            return {
                'success': True,
                'detections': detections,
                'primary_detection': primary_detection,
                'image_size': {
                    'width': image.size[0],
                    'height': image.size[1]
                },
                'timing': {
                    'preprocess': round(preprocess_time, 3),
                    'inference': round(inference_time, 3),
                    'total': round(total_time, 3)
                },
                'model_config': {
                    'confidence_threshold': conf,
                    'iou_threshold': iou,
                    'image_size': config.IMG_SIZE
                }
            }
            
        except Exception as e:
            return {
                'success': False,
                'error': str(e),
                'detections': [],
                'primary_detection': None
            }
    
    def update_primary_detection(self, detections):
        """
        Track and identify primary detection (most frequently detected disease)
        Args:
            detections: List of current frame detections
        Returns:
            dict: Primary detection with occurrence statistics
        """
        # Add current detections to history
        current_classes = [det['class_id'] for det in detections]
        self.detection_history.append(current_classes)
        
        # Keep only recent history
        if len(self.detection_history) > self.history_size:
            self.detection_history.pop(0)
        
        # Count occurrences of each class
        class_counter = Counter()
        for frame_classes in self.detection_history:
            for cls_id in frame_classes:
                class_counter[cls_id] += 1
        
        # Determine primary detection (most frequent)
        if not class_counter:
            return None
        
        primary_class_id, occurrence_count = class_counter.most_common(1)[0]
        
        # Find the primary detection in current frame
        primary_detection = None
        for det in detections:
            if det['class_id'] == primary_class_id:
                primary_detection = det.copy()
                break
        
        if primary_detection:
            # Add tracking statistics
            primary_detection['tracking_stats'] = {
                'occurrence_count': occurrence_count,
                'total_frames': len(self.detection_history),
                'occurrence_percentage': round((occurrence_count / sum(class_counter.values())) * 100, 2),
                'is_stable': occurrence_count >= 5  # Stable if detected in 5+ frames
            }
        
        return primary_detection
    
    def reset_tracking(self):
        """Reset primary detection tracking history"""
        self.detection_history = []
    
    def format_results(self, result, image_size):
        """
        Format YOLO results for API response
        Args:
            result: YOLO result object
            image_size: (width, height) tuple
        Returns:
            list: Formatted detections
        """
        detections = []
        
        if result.boxes is None or len(result.boxes) == 0:
            return detections
        
        img_width, img_height = image_size
        
        for box in result.boxes:
            # Get box coordinates (xyxy format)
            x1, y1, x2, y2 = box.xyxy[0].tolist()
            
            # Convert to normalized coordinates (0-1 range)
            # For AR overlay in Flutter
            x_center = ((x1 + x2) / 2) / img_width
            y_center = ((y1 + y2) / 2) / img_height
            width = (x2 - x1) / img_width
            height = (y2 - y1) / img_height
            
            # Get class and confidence
            class_id = int(box.cls[0])
            confidence = float(box.conf[0])
            
            # Get class name
            class_name = self.class_names[class_id] if class_id < len(self.class_names) else f"Class_{class_id}"
            
            detection = {
                'class_id': class_id,
                'class_name': class_name,
                'confidence': round(confidence, 4),
                'bounding_box': {
                    # Normalized coordinates (0-1) for Flutter AR overlay
                    'x': round(x_center, 4),
                    'y': round(y_center, 4),
                    'width': round(width, 4),
                    'height': round(height, 4),
                    # Pixel coordinates (for reference)
                    'x1': round(x1, 2),
                    'y1': round(y1, 2),
                    'x2': round(x2, 2),
                    'y2': round(y2, 2)
                }
            }
            
            detections.append(detection)
        
        # Sort by confidence (highest first)
        detections.sort(key=lambda x: x['confidence'], reverse=True)
        
        return detections
    
    def get_model_info(self):
        """Get model information"""
        if self.model is None:
            return {'loaded': False}
        
        return {
            'loaded': True,
            'model_path': str(config.MODEL_PATH),
            'num_classes': len(self.class_names),
            'class_names': self.class_names,
            'image_size': config.IMG_SIZE,
            'confidence_threshold': config.CONFIDENCE_THRESHOLD,
            'iou_threshold': config.IOU_THRESHOLD
        }


# Singleton instance
model_service = YOLOModelService()
