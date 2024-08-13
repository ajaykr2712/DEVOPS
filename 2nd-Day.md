
### Daily Log
#### Day 2 - August 13, 2024

**Today's Focus:** Advanced Data Wrangling with Pandas

**Resources Used:**
- 📖 *Python for Data Analysis* by Wes McKinney
- 🌐 [Real Python - Pandas GroupBy](https://realpython.com/pandas-groupby/)
- 🌐 [Kaggle - Data Cleaning Challenge](https://www.kaggle.com/competitions/data-cleaning-challenge)

**Activities:**
- 📝 Deep dive into `groupby`, merging, and joining operations.
- 📌 Explored reshaping and pivoting data for advanced analysis.
- 🔗 [Pandas GroupBy Documentation](https://pandas.pydata.org/pandas-docs/stable/reference/api/pandas.DataFrame.groupby.html)
- 🔗 [Pandas Merging, Joining, and Concatenating](https://pandas.pydata.org/pandas-docs/stable/user_guide/merging.html)

**Detailed Notes:**

📝 **GroupBy and Aggregation:**
- **Purpose:** Split data into groups based on some criteria and perform computations on each group independently.
- **Example:**
    ```python
    df.groupby('Category').sum()
    ```

📝 **Merging and Joining:**
- **Merging:** Combine datasets based on common columns or indices.
- **Joining:** A method similar to SQL joins (left, right, inner, outer).
- **Example:**
    ```python
    pd.merge(df1, df2, on='Key')
    ```

📝 **Reshaping with `melt` and `pivot`:**
- **Melt:** Unpivot a DataFrame from wide to long format.
- **Pivot:** Reshape data to create a pivot table.
- **Example:**
    ```python
    df.melt(id_vars=['Category'], value_vars=['Value1', 'Value2'])
    df.pivot(index='Category', columns='Type', values='Value')
    ```

**Code Snippet:**
```python
import pandas as pd

# Sample data for merging
df1 = pd.DataFrame({'Key': ['A', 'B', 'C'], 'Value1': [1, 2, 3]})
df2 = pd.DataFrame({'Key': ['A', 'B', 'D'], 'Value2': [4, 5, 6]})

# Merging dataframes on 'Key'
merged_df = pd.merge(df1, df2, on='Key', how='outer')

# GroupBy operation
grouped_df = merged_df.groupby('Key').sum()

# Reshaping with melt
melted_df = pd.melt(merged_df, id_vars=['Key'], value_vars=['Value1', 'Value2'])
```

**Reflections:**
- 🤔 Advanced data wrangling techniques like `groupby`, merging, and pivoting are essential for handling complex datasets.
- 🚀 Mastery of these operations allows for flexible and powerful data manipulation.

**Next Steps:**
- 🔜 Practice these operations on a real-world dataset.
- 🔜 Explore more advanced topics like multi-indexing and time-series manipulation.

