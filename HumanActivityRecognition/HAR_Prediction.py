import gradio as gr
import pandas as pd
import numpy as np
from sklearn.preprocessing import StandardScaler, LabelEncoder
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Conv1D, MaxPooling1D, LSTM, Dense, Dropout
from tensorflow.keras.utils import to_categorical
import tensorflow as tf

# Load the train and test datasets
TRAIN_CSV_PATH = "/content/sample_data/train_har.csv"
TEST_CSV_PATH = "/content/sample_data/test.csv"
train_df = pd.read_csv(TRAIN_CSV_PATH)
test_df = pd.read_csv(TEST_CSV_PATH)

# Prepare features and labels
feature_columns = [col for col in train_df.columns if col not in ['Activity', 'subject']]
X_train = train_df[feature_columns]
y_train = train_df['Activity']
X_test = test_df[feature_columns]
y_test = test_df['Activity']

# Encode labels
le = LabelEncoder()
y_train_enc = le.fit_transform(y_train)
y_test_enc = le.transform(y_test)

X_train = X_train.apply(pd.to_numeric, errors='coerce') 
X_test = X_test.apply(pd.to_numeric, errors='coerce')

X_train = X_train.fillna(X_train.mean())
X_test = X_test.fillna(X_train.mean())
# Scale features
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

# Create sequences for CNN+LSTM
WINDOW_SIZE = 5
NUM_FEATURES = X_train_scaled.shape[1]
def create_sequences(X, y, window_size=5):
    Xs, ys = [], []
    for i in range(len(X) - window_size + 1):
        Xs.append(X[i:(i + window_size)])
        ys.append(y[i + window_size - 1])
    return np.array(Xs), np.array(ys)

X_train_seq, y_train_seq = create_sequences(X_train_scaled, y_train_enc, WINDOW_SIZE)
X_test_seq, y_test_seq = create_sequences(X_test_scaled, y_test_enc, WINDOW_SIZE)

NUM_CLASSES = len(le.classes_)

# Build CNN+LSTM model
model = Sequential([
    Conv1D(filters=32, kernel_size=3, activation='relu', input_shape=(WINDOW_SIZE, NUM_FEATURES)),
    MaxPooling1D(pool_size=2),
    Dropout(0.4),
    LSTM(32, return_sequences=False ,dropout=0.3,recurrent_dropout=0.3 ),
    Dense(32, activation='relu'),
    Dropout(0.4),
    Dense(NUM_CLASSES, activation='softmax')
])

model.compile(optimizer='adam', loss='sparse_categorical_crossentropy', metrics=['accuracy'])
model.fit(X_train_seq, y_train_seq, epochs=20, batch_size=64, validation_data=(X_test_seq, y_test_seq))

# Save label classes for mapping
label_map = {i: label for i, label in enumerate(le.classes_)}

# Gradio prediction function
# Use the test set for random predictions
random_df = test_df.reset_index(drop=True)
random_X_scaled = scaler.transform(random_df[feature_columns])

def predict_random():
    if len(random_df) < WINDOW_SIZE:
        return "Not enough rows in the dataset to form a sequence of 5."
    start_idx = np.random.randint(0, len(random_df) - WINDOW_SIZE + 1)
    seq = random_X_scaled[start_idx:start_idx+WINDOW_SIZE]
    try:
        features = seq.reshape(1, WINDOW_SIZE, NUM_FEATURES)
    except Exception as e:
        return f"Error reshaping input: {e}\nFeature shape: {seq.shape}"
    pred = model.predict(features)
    pred_label = np.argmax(pred, axis=1)[0]
    pred_label_display = label_map.get(pred_label, pred_label)
    # Show the actual label and row number of the last row in the sequence
    last_row = random_df.iloc[start_idx+WINDOW_SIZE-1]
    original_label = last_row['Activity']
    row_number = last_row.name
    return (
        f"<div style='font-size:1.2em;'><b>Randomly selected row number:</b> <span style='color:#0077b6;'>{row_number}</span><br>"
        f"<b>Predicted Activity:</b> <span style='color:#43aa8b;'>{pred_label_display}</span><br>"
        f"<b>Actual Activity:</b> <span style='color:#f3722c;'>{original_label}</span></div>"
    )

with gr.Blocks(theme=gr.themes.Soft()) as demo:
    gr.Markdown("""
    # Human Activity Recognition (HAR) - CNN + LSTM
    Click **Predict** to select a random test sample (sequence of 5) and compare the model's prediction with the actual activity.
    """)
    output = gr.HTML()
    predict_btn = gr.Button("Predict", elem_id="predict-btn", variant="primary")
    predict_btn.click(fn=predict_random, outputs=output)

if __name__ == "__main__":
    print("Launching enhanced HAR Gradio app...")
    demo.launch()
