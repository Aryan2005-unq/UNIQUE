// ActivityPredictionScreen.js
import React, { useState } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  ScrollView,
  Alert,
  ActivityIndicator
} from 'react-native';
import { LineChart } from 'react-native-chart-kit';

const ActivityPredictionScreen = () => {
  const [isGenerating, setIsGenerating] = useState(false);
  const [syntheticData, setSyntheticData] = useState(null);
  const [predictions, setPredictions] = useState(null);
  const [loading, setLoading] = useState(false);

  // Backend API endpoint
  const API_BASE_URL = 'http://your-backend-url.com/api';

  const generateAndPredict = async () => {
    try {
      setLoading(true);
      setIsGenerating(true);

      // Step 1: Generate synthetic sensor data
      console.log('🔄 Generating synthetic sensor data...');
      const generateResponse = await fetch(`${API_BASE_URL}/generate-data`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          num_samples: 5,
          simulate_device: true
        })
      });

      if (!generateResponse.ok) {
        throw new Error('Failed to generate synthetic data');
      }

      const generatedData = await generateResponse.json();
      setSyntheticData(generatedData.sensor_data);

      console.log('✅ Synthetic data generated:', generatedData.sensor_data);

      // Step 2: Predict activities from synthetic data
      console.log('🎯 Predicting activities...');
      const predictResponse = await fetch(`${API_BASE_URL}/predict-activities`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          sensor_data: generatedData.sensor_data
        })
      });

      if (!predictResponse.ok) {
        throw new Error('Failed to predict activities');
      }

      const predictionResults = await predictResponse.json();
      setPredictions(predictionResults.predictions);

      console.log('✅ Predictions made:', predictionResults.predictions);

      Alert.alert(
        'Success!',
        `Generated ${generatedData.sensor_data.length} sensor samples and predicted activities!`,
        [{ text: 'OK' }]
      );

    } catch (error) {
      console.error('Error:', error);
      Alert.alert(
        'Error',
        'Failed to generate data or predict activities. Please try again.',
        [{ text: 'OK' }]
      );
    } finally {
      setLoading(false);
      setIsGenerating(false);
    }
  };

  const renderSensorData = () => {
    if (!syntheticData) return null;

    return (
      <View style={styles.dataContainer}>
        <Text style={styles.sectionTitle}>📱 Generated Sensor Data</Text>
        <Text style={styles.subtitle}>
          (Simulating data from wearable device)
        </Text>
        
        <ScrollView horizontal style={styles.dataScroll}>
          <View style={styles.dataTable}>
            {/* Table headers */}
            <View style={styles.tableRow}>
              <Text style={[styles.tableHeader, styles.timestampCol]}>Timestamp</Text>
              <Text style={[styles.tableHeader, styles.dataCol]}>Acc_X</Text>
              <Text style={[styles.tableHeader, styles.dataCol]}>Acc_Y</Text>
              <Text style={[styles.tableHeader, styles.dataCol]}>Acc_Z</Text>
              <Text style={[styles.tableHeader, styles.dataCol]}>Gyro_X</Text>
              <Text style={[styles.tableHeader, styles.dataCol]}>Gyro_Y</Text>
              <Text style={[styles.tableHeader, styles.dataCol]}>Gyro_Z</Text>
            </View>
            
            {/* Data rows */}
            {syntheticData.map((row, index) => (
              <View key={index} style={styles.tableRow}>
                <Text style={[styles.tableCell, styles.timestampCol]}>
                  {new Date(row.timestamp).toLocaleTimeString()}
                </Text>
                <Text style={[styles.tableCell, styles.dataCol]}>
                  {row.acc_x?.toFixed(3) || 'N/A'}
                </Text>
                <Text style={[styles.tableCell, styles.dataCol]}>
                  {row.acc_y?.toFixed(3) || 'N/A'}
                </Text>
                <Text style={[styles.tableCell, styles.dataCol]}>
                  {row.acc_z?.toFixed(3) || 'N/A'}
                </Text>
                <Text style={[styles.tableCell, styles.dataCol]}>
                  {row.gyro_x?.toFixed(3) || 'N/A'}
                </Text>
                <Text style={[styles.tableCell, styles.dataCol]}>
                  {row.gyro_y?.toFixed(3) || 'N/A'}
                </Text>
                <Text style={[styles.tableCell, styles.dataCol]}>
                  {row.gyro_z?.toFixed(3) || 'N/A'}
                </Text>
              </View>
            ))}
          </View>
        </ScrollView>
      </View>
    );
  };

  const renderPredictions = () => {
    if (!predictions) return null;

    return (
      <View style={styles.predictionsContainer}>
        <Text style={styles.sectionTitle}>🎯 Activity Predictions</Text>
        <Text style={styles.subtitle}>
          (CNN-LSTM Hybrid Model Results)
        </Text>
        
        {predictions.map((prediction, index) => (
          <View key={index} style={styles.predictionCard}>
            <View style={styles.predictionHeader}>
              <Text style={styles.predictionTime}>
                Sample {index + 1}
              </Text>
              <Text style={styles.confidenceScore}>
                {(prediction.confidence * 100).toFixed(1)}%
              </Text>
            </View>
            
            <Text style={styles.activityName}>
              {prediction.predicted_activity}
            </Text>
            
            <View style={styles.confidenceBar}>
              <View 
                style={[
                  styles.confidenceFill, 
                  { width: `${prediction.confidence * 100}%` }
                ]} 
              />
            </View>
          </View>
        ))}
        
        {/* Summary */}
        <View style={styles.summaryContainer}>
          <Text style={styles.summaryTitle}>📊 Summary</Text>
          <Text style={styles.summaryText}>
            Most Common Activity: {getMostCommonActivity()}
          </Text>
          <Text style={styles.summaryText}>
            Average Confidence: {getAverageConfidence()}%
          </Text>
        </View>
      </View>
    );
  };

  const getMostCommonActivity = () => {
    if (!predictions) return 'N/A';
    
    const activityCounts = {};
    predictions.forEach(p => {
      activityCounts[p.predicted_activity] = (activityCounts[p.predicted_activity] || 0) + 1;
    });
    
    return Object.keys(activityCounts).reduce((a, b) => 
      activityCounts[a] > activityCounts[b] ? a : b
    );
  };

  const getAverageConfidence = () => {
    if (!predictions) return 0;
    
    const avgConfidence = predictions.reduce((sum, p) => sum + p.confidence, 0) / predictions.length;
    return (avgConfidence * 100).toFixed(1);
  };

  return (
    <ScrollView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>🤖 HAR System Demo</Text>
        <Text style={styles.description}>
          Generate synthetic sensor data and predict activities using our trained models
        </Text>
      </View>

      {/* Generate Data Button */}
      <TouchableOpacity
        style={[styles.generateButton, loading && styles.buttonDisabled]}
        onPress={generateAndPredict}
        disabled={loading}
      >
        {loading ? (
          <View style={styles.loadingContainer}>
            <ActivityIndicator size="small" color="#fff" />
            <Text style={styles.buttonText}>
              {isGenerating ? 'Generating Data...' : 'Predicting...'}
            </Text>
          </View>
        ) : (
          <Text style={styles.buttonText}>
            🎲 Generate Data & Predict Activities
          </Text>
        )}
      </TouchableOpacity>

      {/* Results */}
      {renderSensorData()}
      {renderPredictions()}

      <View style={styles.footer}>
        <Text style={styles.footerText}>
          💡 This simulates real-time data from a wearable device
        </Text>
      </View>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  header: {
    padding: 20,
    backgroundColor: '#fff',
    marginBottom: 10,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 5,
  },
  description: {
    fontSize: 14,
    color: '#666',
    lineHeight: 20,
  },
  generateButton: {
    backgroundColor: '#007AFF',
    marginHorizontal: 20,
    marginVertical: 10,
    paddingVertical: 15,
    paddingHorizontal: 20,
    borderRadius: 10,
    alignItems: 'center',
  },
  buttonDisabled: {
    backgroundColor: '#ccc',
  },
  buttonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
  },
  loadingContainer: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  dataContainer: {
    backgroundColor: '#fff',
    margin: 10,
    padding: 15,
    borderRadius: 10,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 5,
  },
  subtitle: {
    fontSize: 12,
    color: '#666',
    marginBottom: 15,
  },
  dataScroll: {
    maxHeight: 200,
  },
  dataTable: {
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 5,
  },
  tableRow: {
    flexDirection: 'row',
    borderBottomWidth: 1,
    borderBottomColor: '#eee',
  },
  tableHeader: {
    backgroundColor: '#f8f8f8',
    fontWeight: 'bold',
    padding: 8,
    fontSize: 10,
    textAlign: 'center',
  },
  tableCell: {
    padding: 8,
    fontSize: 10,
    textAlign: 'center',
  },
  timestampCol: {
    width: 80,
  },
  dataCol: {
    width: 60,
  },
  predictionsContainer: {
    backgroundColor: '#fff',
    margin: 10,
    padding: 15,
    borderRadius: 10,
  },
  predictionCard: {
    backgroundColor: '#f9f9f9',
    padding: 12,
    borderRadius: 8,
    marginBottom: 10,
  },
  predictionHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 8,
  },
  predictionTime: {
    fontSize: 12,
    color: '#666',
  },
  confidenceScore: {
    fontSize: 12,
    color: '#007AFF',
    fontWeight: 'bold',
  },
  activityName: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 8,
  },
  confidenceBar: {
    height: 4,
    backgroundColor: '#eee',
    borderRadius: 2,
  },
  confidenceFill: {
    height: '100%',
    backgroundColor: '#007AFF',
    borderRadius: 2,
  },
  summaryContainer: {
    backgroundColor: '#e8f4f8',
    padding: 12,
    borderRadius: 8,
    marginTop: 10,
  },
  summaryTitle: {
    fontSize: 14,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 8,
  },
  summaryText: {
    fontSize: 12,
    color: '#666',
    marginBottom: 4,
  },
  footer: {
    padding: 20,
    alignItems: 'center',
  },
  footerText: {
    fontSize: 12,
    color: '#999',
    fontStyle: 'italic',
  },
});

export default ActivityPredictionScreen;
