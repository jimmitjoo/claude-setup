---
name: Machine Learning Expert
description: PyTorch, TensorFlow, scikit-learn, MLOps, modellträning och deployment.
---

# Machine Learning Best Practices

## Projektstruktur

```
ml-project/
├── data/
│   ├── raw/                 # Orörd data
│   ├── processed/           # Bearbetad data
│   └── external/            # Externa dataset
├── notebooks/
│   ├── 01_exploration.ipynb
│   ├── 02_preprocessing.ipynb
│   └── 03_modeling.ipynb
├── src/
│   ├── data/
│   │   ├── __init__.py
│   │   ├── dataset.py       # Dataset klasser
│   │   └── transforms.py    # Data transformationer
│   ├── models/
│   │   ├── __init__.py
│   │   └── model.py         # Modellarkitektur
│   ├── training/
│   │   ├── __init__.py
│   │   ├── trainer.py
│   │   └── callbacks.py
│   └── inference/
│       ├── __init__.py
│       └── predictor.py
├── configs/
│   └── config.yaml
├── tests/
├── models/                  # Sparade modeller
├── logs/                    # Training logs
├── requirements.txt
└── README.md
```

## PyTorch

### Dataset
```python
from torch.utils.data import Dataset, DataLoader
from torchvision import transforms

class CustomDataset(Dataset):
    def __init__(self, data_path: str, transform=None):
        self.data = self._load_data(data_path)
        self.transform = transform

    def __len__(self) -> int:
        return len(self.data)

    def __getitem__(self, idx: int):
        sample = self.data[idx]
        if self.transform:
            sample = self.transform(sample)
        return sample

# DataLoader
train_loader = DataLoader(
    dataset,
    batch_size=32,
    shuffle=True,
    num_workers=4,
    pin_memory=True,  # Snabbare GPU transfer
)
```

### Model
```python
import torch
import torch.nn as nn

class ConvNet(nn.Module):
    def __init__(self, num_classes: int = 10):
        super().__init__()
        self.features = nn.Sequential(
            nn.Conv2d(3, 64, kernel_size=3, padding=1),
            nn.BatchNorm2d(64),
            nn.ReLU(inplace=True),
            nn.MaxPool2d(2),
            nn.Conv2d(64, 128, kernel_size=3, padding=1),
            nn.BatchNorm2d(128),
            nn.ReLU(inplace=True),
            nn.MaxPool2d(2),
        )
        self.classifier = nn.Sequential(
            nn.AdaptiveAvgPool2d(1),
            nn.Flatten(),
            nn.Linear(128, num_classes),
        )

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        x = self.features(x)
        x = self.classifier(x)
        return x
```

### Training Loop
```python
import torch
from torch.cuda.amp import GradScaler, autocast
from tqdm import tqdm

def train_epoch(
    model: nn.Module,
    loader: DataLoader,
    optimizer: torch.optim.Optimizer,
    criterion: nn.Module,
    device: torch.device,
    scaler: GradScaler = None,  # Mixed precision
) -> float:
    model.train()
    total_loss = 0

    for batch in tqdm(loader, desc="Training"):
        inputs, targets = batch
        inputs = inputs.to(device)
        targets = targets.to(device)

        optimizer.zero_grad()

        # Mixed precision training
        if scaler:
            with autocast():
                outputs = model(inputs)
                loss = criterion(outputs, targets)
            scaler.scale(loss).backward()
            scaler.step(optimizer)
            scaler.update()
        else:
            outputs = model(inputs)
            loss = criterion(outputs, targets)
            loss.backward()
            optimizer.step()

        total_loss += loss.item()

    return total_loss / len(loader)


def validate(
    model: nn.Module,
    loader: DataLoader,
    criterion: nn.Module,
    device: torch.device,
) -> tuple[float, float]:
    model.eval()
    total_loss = 0
    correct = 0
    total = 0

    with torch.no_grad():
        for inputs, targets in loader:
            inputs = inputs.to(device)
            targets = targets.to(device)

            outputs = model(inputs)
            loss = criterion(outputs, targets)

            total_loss += loss.item()
            _, predicted = outputs.max(1)
            total += targets.size(0)
            correct += predicted.eq(targets).sum().item()

    return total_loss / len(loader), correct / total
```

### Spara och ladda modell
```python
# Spara
torch.save({
    'epoch': epoch,
    'model_state_dict': model.state_dict(),
    'optimizer_state_dict': optimizer.state_dict(),
    'loss': loss,
}, 'checkpoint.pth')

# Ladda
checkpoint = torch.load('checkpoint.pth')
model.load_state_dict(checkpoint['model_state_dict'])
optimizer.load_state_dict(checkpoint['optimizer_state_dict'])
```

## TensorFlow/Keras

### Model
```python
import tensorflow as tf
from tensorflow import keras
from keras import layers

def create_model(num_classes: int = 10) -> keras.Model:
    inputs = keras.Input(shape=(224, 224, 3))

    x = layers.Conv2D(64, 3, padding='same')(inputs)
    x = layers.BatchNormalization()(x)
    x = layers.ReLU()(x)
    x = layers.MaxPooling2D()(x)

    x = layers.Conv2D(128, 3, padding='same')(x)
    x = layers.BatchNormalization()(x)
    x = layers.ReLU()(x)
    x = layers.GlobalAveragePooling2D()(x)

    outputs = layers.Dense(num_classes, activation='softmax')(x)

    return keras.Model(inputs, outputs)

model = create_model()
model.compile(
    optimizer='adam',
    loss='sparse_categorical_crossentropy',
    metrics=['accuracy'],
)
```

### Training
```python
# Callbacks
callbacks = [
    keras.callbacks.EarlyStopping(
        patience=5,
        restore_best_weights=True,
    ),
    keras.callbacks.ModelCheckpoint(
        'best_model.keras',
        save_best_only=True,
    ),
    keras.callbacks.TensorBoard(log_dir='./logs'),
    keras.callbacks.ReduceLROnPlateau(
        factor=0.5,
        patience=3,
    ),
]

# Träna
history = model.fit(
    train_dataset,
    validation_data=val_dataset,
    epochs=100,
    callbacks=callbacks,
)
```

## scikit-learn

### Pipeline
```python
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.decomposition import PCA
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import GridSearchCV

# Pipeline
pipeline = Pipeline([
    ('scaler', StandardScaler()),
    ('pca', PCA(n_components=0.95)),
    ('classifier', RandomForestClassifier()),
])

# Hyperparameter search
param_grid = {
    'pca__n_components': [0.9, 0.95, 0.99],
    'classifier__n_estimators': [100, 200, 500],
    'classifier__max_depth': [None, 10, 20],
}

search = GridSearchCV(
    pipeline,
    param_grid,
    cv=5,
    scoring='accuracy',
    n_jobs=-1,
)

search.fit(X_train, y_train)
print(f"Best params: {search.best_params_}")
print(f"Best score: {search.best_score_:.4f}")
```

### Evaluation
```python
from sklearn.metrics import (
    classification_report,
    confusion_matrix,
    roc_auc_score,
)

# Predictions
y_pred = model.predict(X_test)
y_prob = model.predict_proba(X_test)

# Metrics
print(classification_report(y_test, y_pred))
print(f"ROC AUC: {roc_auc_score(y_test, y_prob, multi_class='ovr'):.4f}")

# Confusion matrix
cm = confusion_matrix(y_test, y_pred)
```

## Transformers (Hugging Face)

### Text Classification
```python
from transformers import (
    AutoTokenizer,
    AutoModelForSequenceClassification,
    Trainer,
    TrainingArguments,
)
from datasets import load_dataset

# Ladda data
dataset = load_dataset("imdb")

# Tokenizer
tokenizer = AutoTokenizer.from_pretrained("bert-base-uncased")

def tokenize(examples):
    return tokenizer(
        examples["text"],
        padding="max_length",
        truncation=True,
        max_length=512,
    )

tokenized = dataset.map(tokenize, batched=True)

# Model
model = AutoModelForSequenceClassification.from_pretrained(
    "bert-base-uncased",
    num_labels=2,
)

# Training
training_args = TrainingArguments(
    output_dir="./results",
    num_train_epochs=3,
    per_device_train_batch_size=16,
    per_device_eval_batch_size=64,
    warmup_steps=500,
    weight_decay=0.01,
    logging_dir="./logs",
    evaluation_strategy="epoch",
    save_strategy="epoch",
    load_best_model_at_end=True,
)

trainer = Trainer(
    model=model,
    args=training_args,
    train_dataset=tokenized["train"],
    eval_dataset=tokenized["test"],
)

trainer.train()
```

## Experiment Tracking

### MLflow
```python
import mlflow

mlflow.set_experiment("my-experiment")

with mlflow.start_run():
    # Log parameters
    mlflow.log_params({
        "learning_rate": 0.001,
        "batch_size": 32,
        "epochs": 100,
    })

    # Train...

    # Log metrics
    mlflow.log_metrics({
        "train_loss": train_loss,
        "val_loss": val_loss,
        "accuracy": accuracy,
    })

    # Log model
    mlflow.pytorch.log_model(model, "model")
```

### Weights & Biases
```python
import wandb

wandb.init(project="my-project", config={
    "learning_rate": 0.001,
    "batch_size": 32,
})

for epoch in range(epochs):
    # Train...
    wandb.log({
        "train_loss": train_loss,
        "val_loss": val_loss,
        "accuracy": accuracy,
    })

wandb.finish()
```

## Model Deployment

### ONNX Export
```python
import torch.onnx

# Export till ONNX
dummy_input = torch.randn(1, 3, 224, 224)
torch.onnx.export(
    model,
    dummy_input,
    "model.onnx",
    input_names=["input"],
    output_names=["output"],
    dynamic_axes={
        "input": {0: "batch_size"},
        "output": {0: "batch_size"},
    },
)
```

### FastAPI Inference Server
```python
from fastapi import FastAPI, UploadFile
import torch
from PIL import Image

app = FastAPI()
model = torch.load("model.pth")
model.eval()

@app.post("/predict")
async def predict(file: UploadFile):
    image = Image.open(file.file)
    tensor = transform(image).unsqueeze(0)

    with torch.no_grad():
        output = model(tensor)
        prediction = output.argmax(1).item()

    return {"prediction": prediction}
```

## Best Practices

### Reproducerbarhet
```python
import random
import numpy as np
import torch

def set_seed(seed: int = 42):
    random.seed(seed)
    np.random.seed(seed)
    torch.manual_seed(seed)
    torch.cuda.manual_seed_all(seed)
    torch.backends.cudnn.deterministic = True
    torch.backends.cudnn.benchmark = False
```

### GPU Memory
```python
# Töm cache
torch.cuda.empty_cache()

# Gradient accumulation för stora batches
accumulation_steps = 4
for i, batch in enumerate(loader):
    loss = model(batch) / accumulation_steps
    loss.backward()

    if (i + 1) % accumulation_steps == 0:
        optimizer.step()
        optimizer.zero_grad()
```

### Debugging
```python
# Kolla shapes
print(f"Input shape: {x.shape}")
print(f"Output shape: {y.shape}")

# Kolla gradients
for name, param in model.named_parameters():
    if param.grad is not None:
        print(f"{name}: grad mean={param.grad.mean():.6f}")

# Detect anomalies
torch.autograd.set_detect_anomaly(True)
```

## Undvik

- Träna utan validation set
- Glömma att sätta model.eval() vid inference
- Läcka test data till träning
- Ignorera class imbalance
- Överfitta på validation set genom för mycket tuning
- Glömma att normalisera input
- Använda för hög learning rate från start
