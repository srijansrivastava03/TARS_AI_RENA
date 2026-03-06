"""
AgriScan Backend - RAG Service
Handles disease diagnosis and treatment recommendations
Supports both offline (knowledge base) and online (LLM) modes
"""

import json
import os
from pathlib import Path
import sys

sys.path.append(str(Path(__file__).parent.parent))

from config import config
from services.db_service import db_service


class RAGService:
    """Service for Retrieval-Augmented Generation (diagnosis)"""
    
    def __init__(self):
        """Initialize RAG service"""
        self.knowledge_base = self.load_knowledge_base()
        self.use_online = config.USE_ONLINE_RAG
    
    def load_knowledge_base(self):
        """Load local disease knowledge base"""
        try:
            if config.KNOWLEDGE_BASE_PATH.exists():
                # Use utf-8-sig to handle UTF-8 BOM if present
                with open(config.KNOWLEDGE_BASE_PATH, 'r', encoding='utf-8-sig') as f:
                    return json.load(f)
            else:
                print(f"⚠️  Knowledge base not found at {config.KNOWLEDGE_BASE_PATH}")
                return {}
        except Exception as e:
            print(f"❌ Error loading knowledge base: {e}")
            return {}
    
    def get_diagnosis(self, disease_name, language='en', use_cache=True):
        """
        Get disease diagnosis and treatment
        Args:
            disease_name: Name of the disease
            language: Language code (en, hi, kn)
            use_cache: Use cached data if available
        Returns:
            dict: Diagnosis information
        """
        # For non-English languages, ALWAYS use online LLM (knowledge base is English-only)
        # This ensures multilingual responses
        if language.lower() != 'en':
            print(f"🌐 [RAG] Non-English language requested ({language}), skipping English-only sources")
            
            # Try online RAG for multilingual support (check both Gemini and OpenAI keys)
            if self.use_online and (config.GEMINI_API_KEY or config.OPENAI_API_KEY):
                try:
                    print(f"🔄 [RAG] Calling online LLM for {language} translation...")
                    diagnosis = self.get_online_diagnosis(disease_name, language)
                    
                    # Cache for offline use (will be in requested language)
                    db_service.cache_disease(
                        name=disease_name,
                        scientific_name=diagnosis.get('scientific_name', ''),
                        description=diagnosis.get('description', ''),
                        symptoms=diagnosis.get('symptoms', []),
                        treatment=diagnosis.get('treatment', {}),
                        severity=diagnosis.get('severity', 'medium'),
                        prevention=diagnosis.get('prevention', [])
                    )
                    
                    return {
                        'success': True,
                        'disease': diagnosis,
                        'source': 'online_llm',
                        'language': language
                    }
                    
                except Exception as e:
                    print(f"❌ Online RAG failed for {language}: {e}")
                    # Fall through to English sources as fallback
                    print(f"⚠️  Falling back to English sources...")
        
        # For English OR as fallback: Try cache first (offline support)
        if use_cache:
            cached = db_service.get_disease(disease_name)
            if cached:
                return {
                    'success': True,
                    'disease': {
                        'name': cached['name'],
                        'scientific_name': cached['scientific_name'],
                        'description': cached['description'],
                        'symptoms': cached['symptoms'],
                        'treatment': cached['treatment'],
                        'prevention': cached['prevention'],
                        'severity': cached['severity']
                    },
                    'source': 'cache',
                    'language': language
                }
        
        # Try local knowledge base (English only)
        if disease_name in self.knowledge_base:
            diagnosis = self.knowledge_base[disease_name]
            
            # Cache for offline use
            db_service.cache_disease(
                name=disease_name,
                scientific_name=diagnosis.get('scientific_name', ''),
                description=diagnosis.get('description', ''),
                symptoms=diagnosis.get('symptoms', []),
                treatment=diagnosis.get('treatment', {}),
                severity=diagnosis.get('severity', 'medium'),
                prevention=diagnosis.get('prevention', [])
            )
            
            return {
                'success': True,
                'disease': diagnosis,
                'source': 'knowledge_base',
                'language': language
            }
        
        # Try online RAG if enabled (check both Gemini and OpenAI keys)
        if self.use_online and (config.GEMINI_API_KEY or config.OPENAI_API_KEY):
            try:
                diagnosis = self.get_online_diagnosis(disease_name, language)
                
                # Cache for offline use
                db_service.cache_disease(
                    name=disease_name,
                    scientific_name=diagnosis.get('scientific_name', ''),
                    description=diagnosis.get('description', ''),
                    symptoms=diagnosis.get('symptoms', []),
                    treatment=diagnosis.get('treatment', {}),
                    severity=diagnosis.get('severity', 'medium'),
                    prevention=diagnosis.get('prevention', [])
                )
                
                return {
                    'success': True,
                    'disease': diagnosis,
                    'source': 'online_llm',
                    'language': language
                }
                
            except Exception as e:
                print(f"❌ Online RAG failed: {e}")
        
        # No information found
        return {
            'success': False,
            'error': f'No information found for disease: {disease_name}',
            'disease': None,
            'source': 'none'
        }
    
    def get_online_diagnosis(self, disease_name, language='en'):
        """
        Get diagnosis from Gemini or OpenAI API
        Args:
            disease_name: Name of the disease
            language: Language code (en, hi, kn)
        Returns:
            dict: Diagnosis information
        """
        # Map language codes to full language names for better LLM understanding
        language_map = {
            'en': 'English',
            'hi': 'Hindi',
            'kn': 'Kannada'
        }
        language_name = language_map.get(language.lower(), 'English')
        
        print(f"🌐 [RAG] Getting diagnosis in {language_name} (code: {language})")
        
        # Try Gemini first (Google) with model fallback
        try:
            import google.generativeai as genai
            
            # Configure Gemini - use config value (from .env file)
            gemini_key = config.GEMINI_API_KEY or config.OPENAI_API_KEY
            
            if gemini_key and not gemini_key.startswith('sk-'):  # Not OpenAI key
                genai.configure(api_key=gemini_key)
                
                # Try multiple models in order of preference (current available models)
                primary_models = [
                    'models/gemini-2.5-flash',
                    'models/gemini-2.0-flash',
                    'models/gemini-flash-latest',
                    'models/gemini-2.5-pro'
                ]
                
                model = None
                last_error = None
                
                # Test each model with a simple prompt
                for model_name in primary_models:
                    try:
                        test_model = genai.GenerativeModel(model_name)
                        # Quick validation test
                        test_response = test_model.generate_content('Return token OK').text
                        if test_response:
                            model = test_model
                            print(f"✅ Using Gemini model: {model_name}")
                            break
                    except Exception as e:
                        last_error = e
                        continue
                
                if not model:
                    raise Exception(f"All Gemini models failed: {last_error}")
                
                prompt = f"""You are a plant pathology expert. Provide detailed information about the plant disease: {disease_name}

🌐 CRITICAL LANGUAGE REQUIREMENT:
You MUST write ALL content in **{language_name}** language. This is NON-NEGOTIABLE.
Language code: {language}
Language name: {language_name}

The farmer needs information in their native {language_name} language.

Please respond in JSON format with the following structure:
{{
    "name": "{disease_name}",
    "scientific_name": "scientific name in Latin",
    "description": "detailed description - WRITE IN {language_name} ONLY - use bold markdown **for key terms**",
    "symptoms": ["symptom 1 - WRITE IN {language_name}", "symptom 2 - WRITE IN {language_name}", "symptom 3 - WRITE IN {language_name}"],
    "treatment": {{
        "organic": ["organic method 1 - WRITE IN {language_name}", "organic method 2 - WRITE IN {language_name}"],
        "chemical": ["chemical method 1 - WRITE IN {language_name}", "chemical method 2 - WRITE IN {language_name}"],
        "cultural": ["cultural practice 1 - WRITE IN {language_name}", "cultural practice 2 - WRITE IN {language_name}"]
    }},
    "prevention": ["prevention 1 - WRITE IN {language_name}", "prevention 2 - WRITE IN {language_name}", "prevention 3 - WRITE IN {language_name}"],
    "care_recommendations": ["care tip 1 - WRITE IN {language_name} - use **bold** for action words", "care tip 2 - WRITE IN {language_name}", "care tip 3 - WRITE IN {language_name}", "care tip 4 - WRITE IN {language_name}"],
    "severity": "low|medium|high",
    "affected_plants": ["plant 1", "plant 2", ...]
}}

STRICT REQUIREMENTS:
1. 🚨 EVERY text field (description, symptoms, treatment, prevention, care_recommendations) MUST be written in {language_name}
2. 🚨 Only keep "name" and "scientific_name" in English/Latin - everything else MUST be {language_name}
3. Use **bold markdown** for important keywords
4. Provide EXACTLY 4 care_recommendations
5. Make content practical for farmers
6. DO NOT translate field names (like "description", "symptoms") - only translate the VALUES

Example for Hindi: symptoms should be ["पत्तियों पर भूरे धब्बे", "तने में सड़न", ...] not ["symptoms 1", "symptoms 2"]
Example for Kannada: symptoms should be ["ಎಲೆಗಳ ಮೇಲೆ ಕಂದು ಬಣ್ಣದ ಕಲೆಗಳು", "ಕಾಂಡದಲ್ಲಿ ಕೊಳೆತ", ...] not ["symptoms 1", "symptoms 2"]"""

                response = model.generate_content(prompt)
                diagnosis_text = response.text
                
                # Extract JSON from response (Gemini sometimes adds markdown)
                if '```json' in diagnosis_text:
                    diagnosis_text = diagnosis_text.split('```json')[1].split('```')[0]
                elif '```' in diagnosis_text:
                    diagnosis_text = diagnosis_text.split('```')[1].split('```')[0]
                
                diagnosis = json.loads(diagnosis_text.strip())
                return diagnosis
                
        except Exception as e:
            print(f"Gemini diagnosis failed: {e}, trying OpenAI...")
        
        # Fallback to OpenAI
        try:
            from openai import OpenAI
            
            client = OpenAI(api_key=config.OPENAI_API_KEY)
            
            prompt = f"""You are a plant pathology expert. Provide detailed information about the plant disease: {disease_name}

🌐 CRITICAL LANGUAGE REQUIREMENT:
You MUST write ALL content in **{language_name}** language. This is NON-NEGOTIABLE.
Language code: {language}
Language name: {language_name}

Please respond in JSON format with the following structure:
{{
    "name": "{disease_name}",
    "scientific_name": "scientific name in Latin",
    "description": "detailed description - WRITE IN {language_name} ONLY - use bold markdown **for key terms**",
    "symptoms": ["symptom 1 - WRITE IN {language_name}", "symptom 2 - WRITE IN {language_name}", "symptom 3 - WRITE IN {language_name}"],
    "treatment": {{
        "organic": ["organic method 1 - WRITE IN {language_name}", "organic method 2 - WRITE IN {language_name}"],
        "chemical": ["chemical method 1 - WRITE IN {language_name}", "chemical method 2 - WRITE IN {language_name}"],
        "cultural": ["cultural practice 1 - WRITE IN {language_name}", "cultural practice 2 - WRITE IN {language_name}"]
    }},
    "prevention": ["prevention 1 - WRITE IN {language_name}", "prevention 2 - WRITE IN {language_name}"],
    "care_recommendations": ["care tip 1 - WRITE IN {language_name} - use **bold** for action words", "care tip 2 - WRITE IN {language_name}", "care tip 3 - WRITE IN {language_name}", "care tip 4 - WRITE IN {language_name}"],
    "severity": "low|medium|high",
    "affected_plants": ["plant 1", "plant 2", ...]
}}

STRICT REQUIREMENTS:
1. 🚨 EVERY text field MUST be written in {language_name}
2. Only keep field names and "name"/"scientific_name" in English - all other content in {language_name}
3. Use **bold markdown** for important keywords
4. Provide EXACTLY 4 care_recommendations"""

            response = client.chat.completions.create(
                model="gpt-4",
                messages=[
                    {"role": "system", "content": f"You are a plant pathology expert. You MUST respond in {language_name} language for ALL content fields."},
                    {"role": "user", "content": prompt}
                ],
                temperature=0.7,
                max_tokens=1500
            )
            
            diagnosis_text = response.choices[0].message.content
            diagnosis = json.loads(diagnosis_text)
            
            return diagnosis
            
        except Exception as e:
            raise Exception(f"Online diagnosis failed: {e}")
    
    def get_all_diseases(self):
        """Get list of all available diseases"""
        # From knowledge base
        kb_diseases = list(self.knowledge_base.keys())
        
        # From cache
        cached_diseases = [d['name'] for d in db_service.get_all_diseases()]
        
        # Combine and deduplicate
        all_diseases = list(set(kb_diseases + cached_diseases))
        all_diseases.sort()
        
        return all_diseases
    
    def search_diseases(self, query):
        """
        Search diseases by keyword
        Args:
            query: Search query
        Returns:
            list: Matching disease names
        """
        query = query.lower()
        matches = []
        
        # Search in knowledge base
        for disease_name in self.knowledge_base.keys():
            if query in disease_name.lower():
                matches.append(disease_name)
        
        # Search in cache
        for disease in db_service.get_all_diseases():
            if query in disease['name'].lower() and disease['name'] not in matches:
                matches.append(disease['name'])
        
        return matches


# Singleton instance
rag_service = RAGService()
