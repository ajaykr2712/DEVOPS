### Arrays & HashMaps

**“Find the first non-repeating character in a string.”**

This problem can be efficiently solved using a hash map (or a dictionary in Python) to store the frequency of each character.

**Approach:**

1.  **First Pass:** Iterate through the string and store the count of each character in a hash map.
2.  **Second Pass:** Iterate through the string again. For each character, check its count in the hash map. The first character with a count of 1 is the answer.

**Time Complexity:** O(n) - We iterate through the string twice.
**Space Complexity:** O(k) - Where k is the number of unique characters in the string. In the worst case (all unique characters), this is O(n).

**Python Implementation:**

```python
from collections import OrderedDict

def first_non_repeating_char(s):
    """
    Finds the first non-repeating character in a string.
    """
    # Using an ordered dictionary to maintain insertion order for the second pass.
    # A regular dict and a second loop over the string also works perfectly.
    char_counts = OrderedDict()
    for char in s:
        char_counts[char] = char_counts.get(char, 0) + 1

    for char, count in char_counts.items():
        if count == 1:
            return char

    return None # Or an empty string, depending on requirements

# Example
print(first_non_repeating_char("swiss"))  # Output: w
print(first_non_repeating_char("aabbcc")) # Output: None
```

### Sorting & Searching

**“Implement binary search recursively.”**

Binary search is a highly efficient algorithm for finding an item from a **sorted** list. It works by repeatedly dividing the search interval in half.

**Approach:**

1.  Compare the target value with the middle element of the array.
2.  If they are not equal, the half in which the target cannot lie is eliminated, and the search continues on the remaining half.
3.  This process is repeated until the target value is found or the interval is empty.

**Time Complexity:** O(log n)

**Python Implementation:**

```python
def binary_search_recursive(arr, low, high, target):
    """
    Implements binary search recursively.
    Assumes arr is sorted.
    """
    if high >= low:
        mid = low + (high - low) // 2

        # If element is present at the middle itself
        if arr[mid] == target:
            return mid

        # If element is smaller than mid, then it can only be present in left subarray
        elif arr[mid] > target:
            return binary_search_recursive(arr, low, mid - 1, target)

        # Else the element can only be present in right subarray
        else:
            return binary_search_recursive(arr, mid + 1, high, target)
    else:
        # Element is not present in the array
        return -1

# Example
sorted_array = [2, 3, 4, 10, 40]
target_value = 10
result = binary_search_recursive(sorted_array, 0, len(sorted_array) - 1, target_value)

if result != -1:
    print(f"Element is present at index {result}") # Output: Element is present at index 3
else:
    print("Element is not present in array")
```

### Linked Lists / Trees

**“What is the time complexity of inserting a node in a BST?”**

A Binary Search Tree (BST) is a node-based binary tree data structure which has the following properties:
*   The left subtree of a node contains only nodes with keys lesser than the node’s key.
*   The right subtree of a node contains only nodes with keys greater than the node’s key.
*   The left and right subtree each must also be a binary search tree.

The time complexity of inserting a node depends on the height of the tree (`h`).

*   **Average Case:** For a balanced (or mostly balanced) tree, the height is `log n`, where `n` is the number of nodes. The time complexity is **O(log n)**.
*   **Worst Case:** For a completely unbalanced tree (which resembles a linked list), the height is `n`. The time complexity is **O(n)**.

### Sliding Window / 2 Pointers

**“Max sum subarray of size k.”**

This is a classic sliding window problem. We can find the maximum sum by maintaining a "window" of size `k` and sliding it through the array.

**Approach:**

1.  Calculate the sum of the first `k` elements. This is our initial `max_sum`.
2.  Iterate from the `k`-th element to the end of the array.
3.  In each iteration, "slide the window" by adding the current element to the sum and subtracting the first element of the previous window.
4.  Update `max_sum` if the new window's sum is greater.

**Time Complexity:** O(n) - We iterate through the array once.
**Space Complexity:** O(1)

**Python Implementation:**

```python
def max_sum_subarray(arr, k):
    """
    Finds the maximum sum of a subarray of size k.
    """
    if len(arr) < k:
        return -1 # Or handle error as appropriate

    # Compute sum of first window
    window_sum = sum(arr[:k])
    max_sum = window_sum

    # Slide the window from k to the end of the array
    for i in range(k, len(arr)):
        window_sum = window_sum - arr[i - k] + arr[i]
        max_sum = max(max_sum, window_sum)

    return max_sum

# Example
my_array = [1, 4, 2, 10, 23, 3, 1, 0, 20]
k_size = 4
print(f"Maximum sum of a subarray of size {k_size} is {max_sum_subarray(my_array, k_size)}")
# Output: Maximum sum of a subarray of size 4 is 39 (from [4, 2, 10, 23])
```

### Recursion + Backtracking

**“Print all subsets of a list.”**

This problem, also known as finding the "power set," is a great example for demonstrating recursion and backtracking.

**Approach:**

The idea is to generate all subsets by considering each element one by one. For each element, we have two choices:
1.  Include the element in the current subset.
2.  Do not include the element in the current subset.

We can implement this using a recursive helper function that builds the subsets.

**Time Complexity:** O(2^n) - There are 2^n possible subsets for a set with n elements.

**Python Implementation:**

```python
def find_subsets(nums):
    """
    Prints all subsets of a list using backtracking.
    """
    subsets = []
    current_subset = []

    def backtrack(start_index):
        # Add the current subset to the list of all subsets
        subsets.append(list(current_subset))

        # Explore further options by adding more elements
        for i in range(start_index, len(nums)):
            # Include the element
            current_subset.append(nums[i])
            # Recurse
            backtrack(i + 1)
            # Backtrack: remove the element to explore other subsets
            current_subset.pop()

    backtrack(0)
    return subsets

# Example
my_list = [1, 2, 3]
all_subsets = find_subsets(my_list)
print(all_subsets)
# Output: [[], [1], [1, 2], [1, 2, 3], [1, 3], [2], [2, 3], [3]]
```
