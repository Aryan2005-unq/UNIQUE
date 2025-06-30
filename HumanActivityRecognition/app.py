#app.py
from flask import Flask, request, jsonify
from flask_cors import CORS
import pandas as pd
import numpy as np
import joblib
import json
from datetime import datetime, timedelta
import tensorflow as tf
from ctgan import CTGAN
import logging

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)
CORS(app)  # Enable CORS for React Native

# Global variables to hold loaded models
ctgan_model = None
hybrid_model = None
scaler = None
label_encoder = None
feature_columns = None

def load_models():
    """Load all trained models and preprocessors"""
    global ctgan_model, hybrid_model, scaler, label_encoder, feature_columns
    
    try:
        # Load GAN model
        ctgan_model = CTGAN.load('models/ctgan_model.pkl')
        logger.info("✅ GAN model loaded successfully")
        
        # Load hybrid model
        hybrid_model = tf.keras.models.load_model('models/hybrid_model.h5')
        logger.info("✅ Hybrid model loaded successfully")
        
        # Load preprocessors
        scaler = joblib.load('models/scaler.pkl')
        label_encoder = joblib.load('models/label_encoder.pkl')
        logger.info("✅ Preprocessors loaded successfully")
        
        # Load feature columns
        with open('models/feature_columns.json', 'r') as f:
            feature_columns = json.load(f)
        logger.info("✅ Feature columns loaded successfully")
        
        return True
        
    except Exception as e:
        logger.error(f"❌ Error loading models: {str(e)}")
        return False

@app.route('/api/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.now().isoformat(),
        'models_loaded': all([
            ctgan_model is not None,
            hybrid_model is not None,
            scaler is not None,
            label_encoder is not None,
            feature_columns is not None
        ])
    })

@app.route('/api/generate-data', methods=['POST'])
def generate_synthetic_data():
    """
    Generate synthetic sensor data using trained GAN
    This simulates data coming from a wearable device
    """
    try:
        if ctgan_model is None:
            return jsonify({'error': 'GAN model not loaded'}), 500
            
        # Get parameters from request
        data = request.get_json()
        num_samples = data.get('num_samples', 5)
        simulate_device = data.get('simulate_device', True)
        
        logger.info(f"🔄 Generating {num_samples} synthetic sensor samples...")
        
        # Generate synthetic sensor data (NO Activity column)
        synthetic_data = ctgan_model.sample(num_samples)
        
        # Convert to list of dictionaries for JSON response
        sensor_data = []
        
        for i in range(len(synthetic_data)):
            # Create timestamp (simulating real-time data)
            timestamp = datetime.now() + timedelta(milliseconds=i*100)  # 10Hz
            
            # Create sample dictionary
            sample = {
                'timestamp': timestamp.isoformat(),
                'sample_id': i + 1
            }
            
            # Add sensor features
            for col in feature_columns:
                if col in synthetic_data.columns:
                    value = synthetic
