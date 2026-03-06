"""
AgriScan Backend - Database Service
Handles SQLite database operations for offline support
"""

import sqlite3
import json
import uuid
from datetime import datetime
from pathlib import Path
import sys

sys.path.append(str(Path(__file__).parent.parent))

from config import config


class DatabaseService:
    """Service for database operations"""
    
    def __init__(self):
        """Initialize database connection"""
        self.db_path = config.DATABASE_PATH
        self.init_database()
    
    def get_connection(self):
        """Get database connection"""
        conn = sqlite3.connect(self.db_path)
        conn.row_factory = sqlite3.Row  # Return rows as dictionaries
        return conn
    
    def init_database(self):
        """Initialize database schema"""
        conn = self.get_connection()
        cursor = conn.cursor()
        
        try:
            # Detections table
            cursor.execute('''
                CREATE TABLE IF NOT EXISTS detections (
                    id TEXT PRIMARY KEY,
                    user_id TEXT,
                    image_path TEXT,
                    image_base64 TEXT,
                    detections TEXT,
                    diagnosis TEXT,
                    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
                    location TEXT,
                    notes TEXT
                )
            ''')
            
            # Diseases table (cached RAG responses)
            cursor.execute('''
                CREATE TABLE IF NOT EXISTS diseases (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    name TEXT UNIQUE,
                    scientific_name TEXT,
                    description TEXT,
                    symptoms TEXT,
                    treatment TEXT,
                    severity TEXT,
                    prevention TEXT,
                    last_updated DATETIME DEFAULT CURRENT_TIMESTAMP
                )
            ''')
            
            # Users table
            cursor.execute('''
                CREATE TABLE IF NOT EXISTS users (
                    id TEXT PRIMARY KEY,
                    name TEXT,
                    language TEXT DEFAULT 'en',
                    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
                )
            ''')
            
            conn.commit()
            print(f"✅ Database initialized at {self.db_path}")
            
        except Exception as e:
            print(f"❌ Error initializing database: {e}")
            conn.rollback()
        finally:
            conn.close()
    
    def save_detection(self, user_id, detections, image_base64=None, image_path=None, 
                      diagnosis=None, location=None, notes=None):
        """
        Save detection to history
        Args:
            user_id: User ID
            detections: List of detection objects
            image_base64: Base64 encoded image (for offline access)
            image_path: Path to saved image
            diagnosis: Diagnosis information
            location: GPS coordinates
            notes: User notes
        Returns:
            str: Detection ID
        """
        conn = self.get_connection()
        cursor = conn.cursor()
        
        try:
            detection_id = str(uuid.uuid4())
            
            cursor.execute('''
                INSERT INTO detections 
                (id, user_id, image_path, image_base64, detections, diagnosis, location, notes)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            ''', (
                detection_id,
                user_id,
                image_path,
                image_base64,
                json.dumps(detections),
                json.dumps(diagnosis) if diagnosis else None,
                location,
                notes
            ))
            
            conn.commit()
            return detection_id
            
        except Exception as e:
            conn.rollback()
            raise Exception(f"Error saving detection: {e}")
        finally:
            conn.close()
    
    def get_detection(self, detection_id):
        """Get detection by ID"""
        conn = self.get_connection()
        cursor = conn.cursor()
        
        try:
            cursor.execute('''
                SELECT * FROM detections WHERE id = ?
            ''', (detection_id,))
            
            row = cursor.fetchone()
            if row:
                return dict(row)
            return None
            
        finally:
            conn.close()
    
    def get_user_history(self, user_id, limit=50, offset=0):
        """Get user's detection history"""
        conn = self.get_connection()
        cursor = conn.cursor()
        
        try:
            cursor.execute('''
                SELECT id, user_id, image_path, detections, diagnosis, 
                       timestamp, location, notes
                FROM detections 
                WHERE user_id = ?
                ORDER BY timestamp DESC
                LIMIT ? OFFSET ?
            ''', (user_id, limit, offset))
            
            rows = cursor.fetchall()
            return [dict(row) for row in rows]
            
        finally:
            conn.close()
    
    def delete_detection(self, detection_id):
        """Delete detection from history"""
        conn = self.get_connection()
        cursor = conn.cursor()
        
        try:
            cursor.execute('''
                DELETE FROM detections WHERE id = ?
            ''', (detection_id,))
            
            conn.commit()
            return cursor.rowcount > 0
            
        except Exception as e:
            conn.rollback()
            raise Exception(f"Error deleting detection: {e}")
        finally:
            conn.close()
    
    def cache_disease(self, name, scientific_name, description, symptoms, 
                     treatment, severity, prevention):
        """
        Cache disease information for offline access
        Args:
            name: Disease name
            scientific_name: Scientific name
            description: Description
            symptoms: List of symptoms
            treatment: Treatment dictionary
            severity: Severity level
            prevention: List of prevention measures
        """
        conn = self.get_connection()
        cursor = conn.cursor()
        
        try:
            cursor.execute('''
                INSERT OR REPLACE INTO diseases 
                (name, scientific_name, description, symptoms, treatment, severity, prevention, last_updated)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            ''', (
                name,
                scientific_name,
                description,
                json.dumps(symptoms),
                json.dumps(treatment),
                severity,
                json.dumps(prevention),
                datetime.now().isoformat()
            ))
            
            conn.commit()
            
        except Exception as e:
            conn.rollback()
            raise Exception(f"Error caching disease: {e}")
        finally:
            conn.close()
    
    def get_disease(self, name):
        """Get cached disease information"""
        conn = self.get_connection()
        cursor = conn.cursor()
        
        try:
            cursor.execute('''
                SELECT * FROM diseases WHERE name = ?
            ''', (name,))
            
            row = cursor.fetchone()
            if row:
                disease = dict(row)
                # Parse JSON fields
                disease['symptoms'] = json.loads(disease['symptoms'])
                disease['treatment'] = json.loads(disease['treatment'])
                disease['prevention'] = json.loads(disease['prevention']) if disease.get('prevention') else []
                return disease
            return None
            
        finally:
            conn.close()
    
    def get_all_diseases(self):
        """Get all cached diseases"""
        conn = self.get_connection()
        cursor = conn.cursor()
        
        try:
            cursor.execute('''
                SELECT name, scientific_name, severity FROM diseases
                ORDER BY name
            ''')
            
            rows = cursor.fetchall()
            return [dict(row) for row in rows]
            
        finally:
            conn.close()
    
    def create_or_get_user(self, user_id, name=None, language='en'):
        """Create or get user"""
        conn = self.get_connection()
        cursor = conn.cursor()
        
        try:
            # Check if user exists
            cursor.execute('SELECT * FROM users WHERE id = ?', (user_id,))
            user = cursor.fetchone()
            
            if user:
                return dict(user)
            
            # Create new user
            cursor.execute('''
                INSERT INTO users (id, name, language)
                VALUES (?, ?, ?)
            ''', (user_id, name, language))
            
            conn.commit()
            
            return {
                'id': user_id,
                'name': name,
                'language': language,
                'created_at': datetime.now().isoformat()
            }
            
        except Exception as e:
            conn.rollback()
            raise Exception(f"Error creating user: {e}")
        finally:
            conn.close()


# Singleton instance
db_service = DatabaseService()
