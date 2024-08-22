# 🚀 Daily Log
## Day 10 - August 29, 2024

**Today's Focus:** Hyperparameter Tuning

**Resources Used:**
- 📖 *Hands-On Machine Learning with Scikit-Learn, Keras, and TensorFlow* by Aurélien Géron
- 🌐 [Towards Data Science - Hyperparameter Tuning Guide](https://towardsdatascience.com)
- 🌐 [Scikit-Learn Documentation on Hyperparameter Tuning](https://scikit-learn.org/stable/modules/grid_search.html)

**Activities:**
- 📝 Explored the importance of hyperparameter tuning in model optimization.
- 🔍 Practiced Grid Search and Random Search for hyperparameter tuning.
- 🛠 Implemented hyperparameter tuning in a machine learning project using Scikit-Learn.
- 🔗 [Hyperparameter Tuning Guide](https://towardsdatascience.com)

**Detailed Notes:**
- **Hyperparameter Tuning:** A crucial step in optimizing machine learning models for better accuracy and performance.
- **Grid Search:** A methodical way of searching through a manually specified subset of the hyperparameter space.
- **Random Search:** An alternative approach that randomly samples the hyperparameter space.
- **Key Hyperparameters:** Learning rate, regularization strength, number of layers/neurons, etc.

**Code Snippets:**
```python
from sklearn.model_selection import GridSearchCV
from sklearn.ensemble import RandomForestClassifier

# Example of Grid Search
param_grid = {
    'n_estimators': [100, 200, 300],
    'max_depth': [None, 10, 20, 30]
}

grid_search = GridSearchCV(estimator=RandomForestClassifier(), param_grid=param_grid, cv=5)
grid_search.fit(X_train, y_train)

print(f"Best Parameters: {grid_search.best_params_}")
