# Daily Log
## Day 1 - August 12, 2024

**Today's Focus:** Data Manipulation with Pandas

### Resources Used:
- 📖 *Python for Data Analysis* by Wes McKinney
- 🌐 [Pandas Official Documentation](https://pandas.pydata.org/pandas-docs/stable/)
- 🌐 [Kaggle - Pandas Basics](https://www.kaggle.com/learn/pandas)

### Activities:
- 📝 Reviewed Pandas for data manipulation and analysis
- 📌 Explored DataFrames, Series, and basic operations
- 🔍 Worked on data filtering, aggregation, and handling missing data
- 🔗 [Pandas Official Documentation](https://pandas.pydata.org/pandas-docs/stable/)
- 🔗 [Kaggle Pandas Tutorial](https://www.kaggle.com/learn/pandas)

### Detailed Notes:

#### 📝 DataFrames and Series:
- **DataFrame:** A 2-dimensional labeled data structure, similar to a table in SQL or Excel.
    ```python
    import pandas as pd
    data = {'Name': ['Alice', 'Bob', 'Charlie'], 'Age': [25, 30, 35]}
    df = pd.DataFrame(data)
    print(df)
    ```
- **Series:** A one-dimensional array-like object containing an array of data and an associated array of data labels.
    ```python
    age_series = pd.Series([25, 30, 35], name='Age')
    print(age_series)
    ```

#### 📝 Basic Operations:
- **Data Selection:** Selecting columns or rows using labels.
    ```python
    df['Name']  # Selecting the 'Name' column
    df.loc[0]   # Selecting the first row
    ```
- **Filtering:** Using conditions to filter data.
    ```python
    df[df['Age'] > 30]  # Filtering rows where Age > 30
    ```

#### 📝 Aggregation and Missing Data:
- **Aggregation:** Performing operations like sum, mean, or count on data.
    ```python
    df['Age'].mean()  # Calculating the mean age
    ```
- **Handling Missing Data:** Dealing with NaNs in datasets.
    ```python
    df.dropna()  # Dropping rows with missing values
    df.fillna(0) # Filling missing values with 0
    ```

### Code Snippets:
```python
# Example of filtering and aggregation
import pandas as pd

# Creating a DataFrame
data = {'Name': ['Alice', 'Bob', 'Charlie'], 'Age': [25, 30, None]}
df = pd.DataFrame(data)

# Handling missing data
df['Age'].fillna(df['Age'].mean(), inplace=True)

# Filtering and calculating mean age
filtered_df = df[df['Age'] > 28]
mean_age = filtered_df['Age'].mean()

print(mean_age)  # Output: 32.5
Reflections:
🤔 Understanding DataFrames and Series is key to efficiently handling and analyzing data in Pandas.
🚀 Mastering filtering, aggregation, and handling missing data is crucial for data preparation in Machine Learning projects.
Next Steps:
🔜 Explore advanced Pandas operations like merging, joining, and groupby.
🔜 Start working on a mini-project involving data cleaning and manipulation.
