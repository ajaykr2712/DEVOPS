# 🚀 Day 9 - Machine Learning & Data Science Journey

**Date:** August 27, 2024

## 📚 Today's Focus: Feature Engineering & Selection

### Resources Used:
- 📖 *Feature Engineering and Selection* by Max Kuhn & Kjell Johnson
- 🌐 [Kaggle Learn - Feature Engineering](https://www.kaggle.com/learn/feature-engineering)
- 🌐 [Towards Data Science - Feature Selection Techniques](https://towardsdatascience.com)

### 📝 Activities:
- Explored key techniques in **Feature Engineering**.
- Studied **Feature Selection** methods to improve model performance.
- Implemented examples in Python using Pandas and Scikit-learn.

### 🧠 Detailed Notes:

#### **Feature Engineering:**
- **Definition:** Process of transforming raw data into features that better represent the underlying problem.
- **Techniques:** 
  - **Encoding Categorical Variables:** One-hot encoding, label encoding.
  - **Scaling & Normalization:** Min-max scaling, standardization.
  - **Creating Interaction Features:** Combining multiple features.

#### **Feature Selection:**
- **Definition:** Process of selecting the most relevant features to improve model efficiency and accuracy.
- **Methods:** 
  - **Filter Methods:** Correlation matrix, Chi-square test.
  - **Wrapper Methods:** Recursive Feature Elimination (RFE).
  - **Embedded Methods:** Lasso regression, Decision Trees.

### 💻 Code Snippets:

```python
# Example: Feature scaling using StandardScaler
from sklearn.preprocessing import StandardScaler

scaler = StandardScaler()
scaled_features = scaler.fit_transform(df[['feature1', 'feature2']])
