---
name: Data Science Expert
description: Pandas, NumPy, dataanalys, visualisering, feature engineering och statistik.
---

# Data Science Best Practices

## Projektstruktur

```
data-project/
├── data/
│   ├── raw/              # Original data (rör aldrig)
│   ├── interim/          # Mellansteg
│   └── processed/        # Färdig data för analys
├── notebooks/
│   ├── 01_data_exploration.ipynb
│   ├── 02_data_cleaning.ipynb
│   ├── 03_feature_engineering.ipynb
│   └── 04_analysis.ipynb
├── src/
│   ├── data/
│   │   ├── load.py
│   │   └── clean.py
│   ├── features/
│   │   └── build.py
│   └── visualization/
│       └── plots.py
├── reports/
│   └── figures/
├── requirements.txt
└── README.md
```

## Pandas

### Ladda data
```python
import pandas as pd

# CSV
df = pd.read_csv('data.csv', parse_dates=['date_col'])

# Excel
df = pd.read_excel('data.xlsx', sheet_name='Sheet1')

# SQL
from sqlalchemy import create_engine
engine = create_engine('postgresql://user:pass@host/db')
df = pd.read_sql('SELECT * FROM table', engine)

# Parquet (snabbt, komprimerat)
df = pd.read_parquet('data.parquet')
```

### Utforska data
```python
# Översikt
df.info()
df.describe()
df.shape
df.dtypes

# Saknade värden
df.isnull().sum()
df.isnull().sum() / len(df) * 100  # Procent

# Unika värden
df['column'].nunique()
df['column'].value_counts()

# Korrelation
df.corr()
```

### Rensa data
```python
# Ta bort duplicater
df = df.drop_duplicates()
df = df.drop_duplicates(subset=['key_col'])

# Hantera saknade värden
df = df.dropna()                          # Ta bort rader
df = df.dropna(subset=['important_col'])  # Specifika kolumner
df['col'] = df['col'].fillna(0)           # Fyll med värde
df['col'] = df['col'].fillna(df['col'].mean())  # Fyll med medel
df['col'] = df['col'].ffill()             # Forward fill

# Ändra typer
df['date'] = pd.to_datetime(df['date'])
df['category'] = df['category'].astype('category')
df['number'] = pd.to_numeric(df['number'], errors='coerce')

# Ta bort outliers
q1 = df['col'].quantile(0.25)
q3 = df['col'].quantile(0.75)
iqr = q3 - q1
df = df[(df['col'] >= q1 - 1.5*iqr) & (df['col'] <= q3 + 1.5*iqr)]
```

### Transformera data
```python
# Filtrera
df_filtered = df[df['age'] > 18]
df_filtered = df[df['status'].isin(['active', 'pending'])]
df_filtered = df.query('age > 18 and status == "active"')

# Sortera
df = df.sort_values('date', ascending=False)
df = df.sort_values(['category', 'date'])

# Gruppera
grouped = df.groupby('category').agg({
    'value': ['mean', 'sum', 'count'],
    'date': 'max',
})

# Pivot
pivot = df.pivot_table(
    values='sales',
    index='date',
    columns='product',
    aggfunc='sum',
)

# Merge/Join
merged = pd.merge(df1, df2, on='key', how='left')
merged = df1.join(df2, on='key', how='inner')

# Concat
combined = pd.concat([df1, df2], axis=0)  # Vertikalt
combined = pd.concat([df1, df2], axis=1)  # Horisontellt
```

### Apply och Transform
```python
# Apply på kolumn
df['upper'] = df['name'].apply(str.upper)
df['length'] = df['name'].apply(len)

# Apply med lambda
df['category'] = df['value'].apply(lambda x: 'high' if x > 100 else 'low')

# Apply på rad
df['full_name'] = df.apply(lambda row: f"{row['first']} {row['last']}", axis=1)

# Transform (behåller index)
df['normalized'] = df.groupby('group')['value'].transform(
    lambda x: (x - x.mean()) / x.std()
)

# Vectorized (snabbare)
df['category'] = np.where(df['value'] > 100, 'high', 'low')
```

## NumPy

### Grundläggande
```python
import numpy as np

# Skapa arrays
arr = np.array([1, 2, 3])
zeros = np.zeros((3, 4))
ones = np.ones((3, 4))
range_arr = np.arange(0, 10, 0.5)
linspace = np.linspace(0, 1, 100)
random = np.random.randn(3, 4)

# Shape operations
arr.reshape(2, 3)
arr.flatten()
arr.T  # Transpose

# Aggregering
arr.sum(), arr.mean(), arr.std()
arr.min(), arr.max(), arr.argmax()
arr.sum(axis=0)  # Per kolumn
arr.sum(axis=1)  # Per rad

# Indexering
arr[0, 1]
arr[:, 0]  # Första kolumn
arr[arr > 0]  # Boolean indexing
```

### Vectorized Operations
```python
# Element-wise
a + b, a - b, a * b, a / b
np.sqrt(a), np.exp(a), np.log(a)

# Matrix
np.dot(a, b)
a @ b  # Matrix multiplication

# Broadcasting
a = np.array([[1, 2, 3]])  # (1, 3)
b = np.array([[1], [2]])   # (2, 1)
a + b  # (2, 3)
```

## Feature Engineering

### Numeriska features
```python
# Binning
df['age_group'] = pd.cut(df['age'], bins=[0, 18, 35, 50, 100],
                          labels=['young', 'adult', 'middle', 'senior'])

# Log transform (för skewed data)
df['log_value'] = np.log1p(df['value'])

# Normalisering
from sklearn.preprocessing import StandardScaler, MinMaxScaler

scaler = StandardScaler()
df['normalized'] = scaler.fit_transform(df[['value']])

# Polynomial features
from sklearn.preprocessing import PolynomialFeatures
poly = PolynomialFeatures(degree=2)
poly_features = poly.fit_transform(df[['x1', 'x2']])
```

### Kategoriska features
```python
# One-hot encoding
df_encoded = pd.get_dummies(df, columns=['category'])

# Label encoding
from sklearn.preprocessing import LabelEncoder
le = LabelEncoder()
df['category_encoded'] = le.fit_transform(df['category'])

# Target encoding
df['category_target_mean'] = df.groupby('category')['target'].transform('mean')
```

### Datum features
```python
df['year'] = df['date'].dt.year
df['month'] = df['date'].dt.month
df['day'] = df['date'].dt.day
df['dayofweek'] = df['date'].dt.dayofweek
df['is_weekend'] = df['date'].dt.dayofweek >= 5
df['quarter'] = df['date'].dt.quarter

# Tid sedan händelse
df['days_since'] = (pd.Timestamp.now() - df['date']).dt.days
```

### Text features
```python
# Grundläggande
df['word_count'] = df['text'].str.split().str.len()
df['char_count'] = df['text'].str.len()
df['has_email'] = df['text'].str.contains(r'@\w+\.\w+')

# TF-IDF
from sklearn.feature_extraction.text import TfidfVectorizer

tfidf = TfidfVectorizer(max_features=1000)
tfidf_features = tfidf.fit_transform(df['text'])
```

## Visualisering

### Matplotlib
```python
import matplotlib.pyplot as plt

fig, axes = plt.subplots(2, 2, figsize=(12, 10))

# Line plot
axes[0, 0].plot(df['date'], df['value'])
axes[0, 0].set_title('Time Series')

# Histogram
axes[0, 1].hist(df['value'], bins=30, edgecolor='black')
axes[0, 1].set_title('Distribution')

# Scatter
axes[1, 0].scatter(df['x'], df['y'], alpha=0.5)
axes[1, 0].set_title('Scatter Plot')

# Bar
axes[1, 1].bar(df['category'], df['count'])
axes[1, 1].set_title('Bar Chart')

plt.tight_layout()
plt.savefig('plots.png', dpi=300)
```

### Seaborn
```python
import seaborn as sns

# Korrelationsmatris
plt.figure(figsize=(10, 8))
sns.heatmap(df.corr(), annot=True, cmap='coolwarm', center=0)

# Distribution
sns.histplot(df['value'], kde=True)

# Box plot per kategori
sns.boxplot(data=df, x='category', y='value')

# Pair plot
sns.pairplot(df, hue='target')

# Violin plot
sns.violinplot(data=df, x='category', y='value')
```

### Plotly (interaktivt)
```python
import plotly.express as px

# Scatter
fig = px.scatter(df, x='x', y='y', color='category',
                 hover_data=['name'], title='Interactive Scatter')
fig.show()

# Line
fig = px.line(df, x='date', y='value', color='category')

# Bar
fig = px.bar(df, x='category', y='value', color='subcategory')

# Heatmap
fig = px.imshow(df.corr(), text_auto=True)
```

## Statistik

### Deskriptiv statistik
```python
from scipy import stats

# Central tendency
df['col'].mean()
df['col'].median()
stats.mode(df['col'])

# Spridning
df['col'].std()
df['col'].var()
stats.iqr(df['col'])

# Skevhet och kurtosis
stats.skew(df['col'])
stats.kurtosis(df['col'])
```

### Hypotestester
```python
# T-test (jämför medelvärden)
t_stat, p_value = stats.ttest_ind(group1, group2)

# Chi-square (kategoriska variabler)
chi2, p_value, dof, expected = stats.chi2_contingency(
    pd.crosstab(df['cat1'], df['cat2'])
)

# ANOVA (flera grupper)
f_stat, p_value = stats.f_oneway(group1, group2, group3)

# Korrelation
corr, p_value = stats.pearsonr(df['x'], df['y'])
corr, p_value = stats.spearmanr(df['x'], df['y'])
```

## Spara resultat

```python
# CSV
df.to_csv('output.csv', index=False)

# Excel med flera sheets
with pd.ExcelWriter('output.xlsx') as writer:
    df1.to_excel(writer, sheet_name='Data')
    df2.to_excel(writer, sheet_name='Summary')

# Parquet (rekommenderat för stora filer)
df.to_parquet('output.parquet')

# Pickle (behåller alla typer)
df.to_pickle('output.pkl')
```

## Best Practices

### Memory optimization
```python
# Optimera dtypes
df['int_col'] = df['int_col'].astype('int32')
df['float_col'] = df['float_col'].astype('float32')
df['cat_col'] = df['cat_col'].astype('category')

# Läs i chunks
chunks = pd.read_csv('large.csv', chunksize=10000)
result = pd.concat([process(chunk) for chunk in chunks])
```

### Reproducerbarhet
```python
# Seed för random operations
np.random.seed(42)

# Dokumentera data pipeline
# Versionshantera notebooks (nbstripout)
# Använd requirements.txt / environment.yml
```

## Undvik

- Modifiera raw data direkt
- Glömma att validera data efter transformationer
- Ignorera datatyper (object vs string vs category)
- Skapa features från test data
- Glömma att hantera missing values
- Inte dokumentera antaganden och beslut
