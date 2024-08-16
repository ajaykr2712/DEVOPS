### Daily Log
#### Day 5 - August 16, 2024

**Today's Focus:** Introduction to Model Evaluation Metrics and Their Applications

**Resources Used:**
- 📖 *Hands-On Machine Learning with Scikit-Learn, Keras & TensorFlow* by Aurélien Géron
- 🌐 [Scikit-Learn Documentation - Model Evaluation](https://scikit-learn.org/stable/modules/model_evaluation.html)
- 🌐 [Towards Data Science - Understanding Model Evaluation Metrics](https://towardsdatascience.com/model-evaluation-metrics)

**Activities:**
- 📝 Learned about various model evaluation metrics like accuracy, precision, recall, and F1-score.
- 📌 Explored confusion matrices and their role in classification problems.
- 🔍 Investigated the practical applications of these metrics in Data Science and ML projects.

**Detailed Notes:**

📝 **Key Model Evaluation Metrics and Use Cases:**

- **Accuracy:**
  - **Definition:** The proportion of correct predictions out of all predictions.
  - **Use Case:** Best for balanced datasets where the number of positives and negatives is roughly equal.
  - **Application:** Used in general classification problems where all classes are equally important.

- **Precision:**
  - **Definition:** The proportion of true positives out of all positive predictions.
  - **Use Case:** Crucial in scenarios where the cost of a false positive is high.
  - **Application:** Used in spam detection, fraud detection, and medical diagnosis where false alarms can lead to significant consequences.

- **Recall (Sensitivity):**
  - **Definition:** The proportion of true positives out of all actual positives.
  - **Use Case:** Important in situations where missing a positive instance is costly.
  - **Application:** Used in medical screenings, customer retention strategies, and search engines to ensure important cases are not missed.

- **F1-Score:**
  - **Definition:** The harmonic mean of precision and recall, balancing the two metrics.
  - **Use Case:** Useful when there is an uneven class distribution and a balance between precision and recall is needed.
  - **Application:** Applied in natural language processing (NLP) tasks, such as text classification, where both precision and recall are vital.

📝 **Confusion Matrix:**
- **Definition:** A table used to describe the performance of a classification model by comparing predicted and actual values.
- **Use Case:** Provides a comprehensive view of model performance, especially in multi-class classification problems.
- **Application:** Used to identify model strengths and weaknesses by visualizing true positives, true negatives, false positives, and false negatives.

**Reflections:**
- Understanding and correctly applying these evaluation metrics is crucial for optimizing model performance and making data-driven decisions in ML projects.

**Next Steps:**
- Practice calculating and interpreting these metrics using Scikit-Learn on different datasets.
- Explore additional metrics like ROC-AUC and discuss their use cases, particularly in imbalanced datasets.
