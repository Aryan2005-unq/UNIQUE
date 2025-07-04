
# --- Enhanced HAR Gradio App with Prediction History, Interactive Sequence Selection, and More EDA ---
import gradio as gr
import pandas as pd
import numpy as np
from sklearn.preprocessing import StandardScaler, LabelEncoder
from sklearn.metrics import confusion_matrix, accuracy_score
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Conv1D, MaxPooling1D, LSTM, Dense, Dropout
import matplotlib.pyplot as plt
import io
from PIL import Image

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
    Conv1D(filters=64, kernel_size=3, activation='relu', input_shape=(WINDOW_SIZE, NUM_FEATURES)),
    MaxPooling1D(pool_size=2),
    Dropout(0.4),
    LSTM(64, return_sequences=False),
    Dense(64, activation='relu'),
    Dropout(0.4),
    Dense(NUM_CLASSES, activation='softmax')
])

model.compile(optimizer='adam', loss='sparse_categorical_crossentropy', metrics=['accuracy'])
model.fit(X_train_seq, y_train_seq, epochs=10, batch_size=64, validation_data=(X_test_seq, y_test_seq), verbose=2)

# Save label classes for mapping
label_map = {i: label for i, label in enumerate(le.classes_)}

# Gradio prediction history
prediction_history = []

# Use the test set for random predictions
random_df = test_df.reset_index(drop=True)
random_X_scaled = scaler.transform(random_df[feature_columns])

def predict_random():
    if len(random_df) < WINDOW_SIZE:
        return "Not enough rows in the dataset to form a sequence of 5.", pd.DataFrame()
    start_idx = np.random.randint(0, len(random_df) - WINDOW_SIZE + 1)
    return predict_by_index(start_idx)

def predict_by_index(start_idx):
    if start_idx < 0 or start_idx > len(random_df) - WINDOW_SIZE:
        return f"Invalid start index: {start_idx}", pd.DataFrame()
    seq = random_X_scaled[start_idx:start_idx+WINDOW_SIZE]
    try:
        features = seq.reshape(1, WINDOW_SIZE, NUM_FEATURES)
    except Exception as e:
        return f"Error reshaping input: {e}\nFeature shape: {seq.shape}", pd.DataFrame()
    pred = model.predict(features)
    pred_label = np.argmax(pred, axis=1)[0]
    pred_label_display = label_map.get(pred_label, pred_label)
    confidence = float(np.max(pred)) * 100
    last_row = random_df.iloc[start_idx+WINDOW_SIZE-1]
    original_label = last_row['Activity']
    row_number = last_row.name

    # Update prediction history (keep last 10)
    prediction_history.append({
        "Row": row_number,
        "Predicted": pred_label_display,
        "Confidence (%)": confidence,
        "Actual": original_label
    })
    if len(prediction_history) > 10:
        del prediction_history[0]

    html = (
        f"<div style='font-size:1.2em;'><b>Selected row number:</b> <span style='color:#0077b6;'>{row_number}</span><br>"
        f"<b>Predicted Activity:</b> <span style='color:#43aa8b;'>{pred_label_display}</span> "
        f"<b>(Confidence:</b> <span style='color:#f9c846;'>{confidence:.2f}%</span>)<br>"
        f"<b>Actual Activity:</b> <span style='color:#f3722c;'>{original_label}</span></div>"
    )
    hist_df = pd.DataFrame(prediction_history)
    hist_df = hist_df.astype({
        "Row": str,
        "Predicted": str,
        "Actual": str
    })
    return html, hist_df[::-1]  # show most recent first

# --- Exploratory Data Analysis (EDA) ---
def plot_activity_distribution():
    plt.figure(figsize=(8,4))
    train_df['Activity'].value_counts().plot(kind='bar', color='#43aa8b')
    plt.title('Activity Distribution in Training Set')
    plt.xlabel('Activity')
    plt.ylabel('Count')
    plt.tight_layout()
    buf = io.BytesIO()
    plt.savefig(buf, format='png')
    plt.close()
    buf.seek(0)
    img = Image.open(buf)
    return img

def plot_confusion_matrix():
    y_pred = model.predict(X_test_seq)
    y_pred_labels = np.argmax(y_pred, axis=1)
    cm = confusion_matrix(y_test_seq, y_pred_labels)
    plt.figure(figsize=(7,6))
    plt.imshow(cm, interpolation='nearest', cmap=plt.cm.Blues)
    plt.title('Confusion Matrix')
    plt.colorbar()
    tick_marks = np.arange(len(le.classes_))
    class_labels = [str(lbl) for lbl in le.classes_]
    plt.xticks(tick_marks, class_labels, rotation=45)
    plt.yticks(tick_marks, class_labels)
    plt.ylabel('True label')
    plt.xlabel('Predicted label')
    plt.tight_layout()
    buf = io.BytesIO()
    plt.savefig(buf, format='png')
    plt.close()
    buf.seek(0)
    img = Image.open(buf)
    return img

def plot_per_class_accuracy():
    y_pred = model.predict(X_test_seq)
    y_pred_labels = np.argmax(y_pred, axis=1)
    accs = []
    for i, label in enumerate(le.classes_):
        idx = (y_test_seq == i)
        acc = accuracy_score(y_test_seq[idx], y_pred_labels[idx]) if np.sum(idx) > 0 else 0
        accs.append(acc)
    plt.figure(figsize=(8,4))
    class_labels = [str(lbl) for lbl in le.classes_]
    plt.bar(class_labels, accs, color='#f3722c')
    plt.title('Per-Class Accuracy')
    plt.xlabel('Activity')
    plt.ylabel('Accuracy')
    plt.ylim(0,1)
    plt.tight_layout()
    buf = io.BytesIO()
    plt.savefig(buf, format='png')
    plt.close()
    buf.seek(0)
    img = Image.open(buf)
    return img


def show_feature_stats():
    desc = train_df[feature_columns].describe().T[['mean', 'std', 'min', 'max']]
    return desc.to_html(classes='table table-striped', float_format='%.2f')

with gr.Blocks(theme=gr.themes.Soft()) as demo:
    gr.Markdown("""
    <h1 style='color:#0077b6;'>Human Activity Recognition (HAR) - CNN + LSTM</h1>
    <p>Predict human activity from sensor data. Explore the data and model performance below.</p>
    """)
    with gr.Tab("Predict Activity"):
        with gr.Row():
            output = gr.HTML()
            history = gr.Dataframe(
                interactive=False,
                label="Prediction History (last 10)"
            )
        with gr.Row():
            predict_btn = gr.Button("Predict Random", elem_id="predict-btn", variant="primary")
            seq_slider = gr.Slider(minimum=0, maximum=len(random_df)-WINDOW_SIZE, step=1, value=0, label="Select Start Row for Sequence")
            predict_by_idx_btn = gr.Button("Predict by Row", variant="secondary")
        with gr.Row():
            gr.Markdown("""#### Or upload your own CSV for batch prediction""")
            file_upload = gr.File(label="Upload CSV File", file_types=[".csv"])
            upload_output = gr.Dataframe(label="Batch Prediction Results")
        predict_btn.click(fn=lambda: predict_random(), outputs=[output, history])
        predict_by_idx_btn.click(fn=lambda idx: predict_by_index(int(idx)), inputs=seq_slider, outputs=[output, history])
        def batch_predict_from_csv(file):
            if file is None:
                return pd.DataFrame({"Error": ["No file uploaded."]})
            try:
                df = pd.read_csv(file.name)
            except Exception as e:
                return pd.DataFrame({"Error": [f"Failed to read CSV: {e}"]})
            # Check for required columns
            missing_cols = [col for col in feature_columns if col not in df.columns]
            if missing_cols:
                return pd.DataFrame({"Error": [f"Missing columns: {', '.join(missing_cols)}"]})
            if len(df) < WINDOW_SIZE:
                return pd.DataFrame({"Error": [f"Not enough rows (need at least {WINDOW_SIZE})"]})
            # Preprocess
            X = df[feature_columns]
            X_scaled = scaler.transform(X)
            # Create sequences
            X_seq = []
            for i in range(len(X_scaled) - WINDOW_SIZE + 1):
                X_seq.append(X_scaled[i:i+WINDOW_SIZE])
            X_seq = np.array(X_seq)
            # Predict
            preds = model.predict(X_seq)
            pred_labels = np.argmax(preds, axis=1)
            confidences = np.max(preds, axis=1) * 100
            # Prepare output
            results = []
            for i, (pl, conf) in enumerate(zip(pred_labels, confidences)):
                row_idx = i + WINDOW_SIZE - 1
                results.append({
                    "Row": row_idx,
                    "Predicted": label_map.get(pl, pl),
                    "Confidence (%)": f"{conf:.2f}",
                })
            return pd.DataFrame(results)
        file_upload.change(fn=batch_predict_from_csv, inputs=file_upload, outputs=upload_output)
    with gr.Tab("EDA: Activity Distribution"):
        gr.Markdown("""### Activity Distribution in Training Set""")
        gr.Image(value=plot_activity_distribution(), label="Activity Distribution")
    with gr.Tab("EDA: Feature Stats"):
        gr.Markdown("""### Feature Statistics (Train Set)""")
        gr.HTML(show_feature_stats)
    with gr.Tab("EDA: Confusion Matrix"):
        gr.Markdown("""### Confusion Matrix (Test Set)""")
        gr.Image(value=plot_confusion_matrix(), label="Confusion Matrix")
    with gr.Tab("EDA: Per-Class Accuracy"):
        gr.Markdown("""### Per-Class Accuracy (Test Set)""")
        gr.Image(value=plot_per_class_accuracy(), label="Per-Class Accuracy")

if __name__ == "__main__":
    print("Launching enhanced HAR Gradio app...")
    demo.launch()

