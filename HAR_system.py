#HAR_system.py
import pandas as pd
import numpy as np
from ctgan import CTGAN
from sklearn.preprocessing import StandardScaler, LabelEncoder
from sklearn.model_selection import train_test_split
import tensorflow as tf
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Conv1D, MaxPooling1D, LSTM, Dense, Dropout
from tensorflow.keras.utils import to_categorical
import joblib
import json
from datetime import datetime

class HARSystem:
    def __init__(self):
        self.ctgan = None
        self.hybrid_model = None
        self.scaler = StandardScaler()
        self.label_encoder = LabelEncoder()
        self.feature_columns = None
        
    def prepare_data(self, csv_path):
        """Load and prepare data for training"""
        print("Loading and preparing data...")
        df = pd.read_csv(csv_path)
        
        # Remove subject column if present
        if 'subject' in df.columns:
            df = df.drop(columns=['subject'])
            
        # Separate features and target
        self.feature_columns = [col for col in df.columns if col != 'Activity']
        X = df[self.feature_columns]  # Only sensor features
        y = df['Activity']  # Target variable
        
        return X, y
    
    def train_gan(self, X, epochs=300):
        """Train GAN on sensor features only (no target variable)"""
        print("Training GAN on sensor features...")
        
        self.ctgan = CTGAN(
            epochs=epochs,
            batch_size=500,
            generator_dim=(256, 256),
            discriminator_dim=(256, 256),
            generator_lr=2e-4,
            discriminator_lr=2e-4
        )
        
        # Train GAN only on sensor features (NO Activity column)
        self.ctgan.fit(X)
        print("GAN training completed!")
        
    def create_hybrid_model(self, input_shape, num_classes):
        """Create CNN-LSTM hybrid model"""
        model = Sequential([
            # CNN layers for feature extraction
            Conv1D(64, 3, activation='relu', input_shape=input_shape),
            MaxPooling1D(2),
            Conv1D(128, 3, activation='relu'),
            MaxPooling1D(2),
            Conv1D(64, 3, activation='relu'),
            
            # LSTM layers for temporal dependencies
            LSTM(100, return_sequences=True),
            LSTM(50),
            
            # Dense layers for classification
            Dense(50, activation='relu'),
            Dropout(0.3),
            Dense(num_classes, activation='softmax')
        ])
        
        model.compile(
            optimizer='adam',
            loss='categorical_crossentropy',
            metrics=['accuracy']
        )
        
        return model
    
    def train_hybrid_model(self, X, y, validation_split=0.2, epochs=100):
        """Train the hybrid model for activity recognition"""
        print("Preparing data for hybrid model training...")
        
        # Encode labels
        y_encoded = self.label_encoder.fit_transform(y)
        y_categorical = to_categorical(y_encoded)
        
        # Scale features
        X_scaled = self.scaler.fit_transform(X)
        
        # Reshape for CNN-LSTM (samples, time_steps, features)
        # For this example, treating each sample as a single time step
        X_reshaped = X_scaled.reshape((X_scaled.shape[0], 1, X_scaled.shape[1]))
        
        # Split data
        X_train, X_val, y_train, y_val = train_test_split(
            X_reshaped, y_categorical, 
            test_size=validation_split, 
            random_state=42,
            stratify=y_encoded
        )
        
        # Create model
        input_shape = (X_reshaped.shape[1], X_reshaped.shape[2])
        num_classes = len(np.unique(y_encoded))
        
        self.hybrid_model = self.create_hybrid_model(input_shape, num_classes)
        
        print("Training hybrid model...")
        
        # Callbacks
        callbacks = [
            tf.keras.callbacks.EarlyStopping(patience=15, restore_best_weights=True),
            tf.keras.callbacks.ReduceLROnPlateau(patience=7, factor=0.5),
        ]
        
        # Train model
        history = self.hybrid_model.fit(
            X_train, y_train,
            validation_data=(X_val, y_val),
            epochs=epochs,
            batch_size=32,
            callbacks=callbacks,
            verbose=1
        )
        
        print("Hybrid model training completed!")
        return history
    
    def generate_synthetic_data(self, num_samples=5):
        """Generate synthetic sensor data (simulating device input)"""
        if self.ctgan is None:
            raise ValueError("GAN not trained yet!")
            
        print(f"Generating {num_samples} synthetic sensor samples...")
        
        # Generate only sensor features (no Activity column)
        synthetic_data = self.ctgan.sample(num_samples)
        
        # Add realistic timestamps
        synthetic_data['timestamp'] = pd.date_range(
            start=datetime.now(), 
            periods=num_samples, 
            freq='100ms'  # 10Hz sampling rate
        )
        
        # Reorder columns to match original feature order
        column_order = ['timestamp'] + self.feature_columns
        synthetic_data = synthetic_data[column_order]
        
        return synthetic_data
    
    def predict_activities(self, synthetic_data):
        """Predict activities from synthetic sensor data"""
        if self.hybrid_model is None:
            raise ValueError("Hybrid model not trained yet!")
            
        print("Making activity predictions...")
        
        # Remove timestamp for prediction
        sensor_data = synthetic_data.drop(columns=['timestamp'])
        
        # Ensure column order matches training data
        sensor_data = sensor_data[self.feature_columns]
        
        # Scale data
        scaled_data = self.scaler.transform(sensor_data)
        
        # Reshape for model input
        input_data = scaled_data.reshape((scaled_data.shape[0], 1, scaled_data.shape[1]))
        
        # Make predictions
        predictions = self.hybrid_model.predict(input_data, verbose=0)
        predicted_classes = np.argmax(predictions, axis=1)
        confidence_scores = np.max(predictions, axis=1)
        
        # Convert back to activity names
        predicted_activities = self.label_encoder.inverse_transform(predicted_classes)
        
        # Create results dataframe
        results = pd.DataFrame({
            'timestamp': synthetic_data['timestamp'],
            'predicted_activity': predicted_activities,
            'confidence': confidence_scores
        })
        
        return results, synthetic_data
    
    def simulate_device_prediction(self, num_samples=5):
        """Complete workflow: Generate data → Predict activities"""
        print("=== Simulating Device Data and Prediction ===")
        
        # Step 1: Generate synthetic sensor data (like from wearable device)
        synthetic_sensor_data = self.generate_synthetic_data(num_samples)
        
        print("\n📱 Generated Synthetic Sensor Data (simulating device):")
        print(synthetic_sensor_data)
        
        # Step 2: Predict activities using hybrid model
        predictions, sensor_data = self.predict_activities(synthetic_sensor_data)
        
        print("\n🎯 Activity Predictions:")
        print(predictions)
        
        return predictions, sensor_data
    
    def save_models(self, save_dir='models'):
        """Save all trained models and preprocessors"""
        import os
        os.makedirs(save_dir, exist_ok=True)
        
        # Save GAN
        if self.ctgan:
            self.ctgan.save(f"{save_dir}/ctgan_model.pkl")
            
        # Save hybrid model
        if self.hybrid_model:
            self.hybrid_model.save(f"{save_dir}/hybrid_model.h5")
            
        # Save preprocessors
        joblib.dump(self.scaler, f"{save_dir}/scaler.pkl")
        joblib.dump(self.label_encoder, f"{save_dir}/label_encoder.pkl")
        
        # Save feature columns
        with open(f"{save_dir}/feature_columns.json", 'w') as f:
            json.dump(self.feature_columns, f)
            
        print(f"All models saved to {save_dir}/")

# Example usage
if __name__ == "__main__":
    # Initialize system
    har_system = HARSystem()
    
    # Load and prepare data
    X, y = har_system.prepare_data('HAR_test.csv')
    
    # Train GAN (on sensor features only)
    har_system.train_gan(X, epochs=50)  # Reduced for demo
    
    # Train hybrid model (for activity prediction)
    har_system.train_hybrid_model(X, y, epochs=20)  # Reduced for demo
    
    # Save models
    har_system.save_models()
    
    print("\n" + "="*50)
    print("🚀 SYSTEM READY!")
    print("="*50)
    
    # Simulate user clicking "Generate Data" button
    print("\n👆 User clicks 'Generate Data' button...")
    predictions, sensor_data = har_system.simulate_device_prediction(num_samples=5)
    
    print("\n📊 Summary:")
    activity_counts = predictions['predicted_activity'].value_counts()
    print(f"Predicted activities: {dict(activity_counts)}")
    print(f"Average confidence: {predictions['confidence'].mean():.2f}")
