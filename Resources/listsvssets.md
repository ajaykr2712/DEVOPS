
# Keywords in Python

Keywords are reserved words in Python with predefined meanings. They cannot be used as variable names or identifiers. Keywords form the structural and logical framework of a Python program. These words are case-sensitive and must be used exactly as defined.

Here is a list of some essential Python keywords:

1. **and**: Logical operator; returns `True` if both operands are true.
   ```python
   x = True and False  # Output: False
   ```

2. **or**: Logical operator; returns `True` if at least one operand is true.
   ```python
   x = True or False  # Output: True
   ```

3. **not**: Logical operator; returns the opposite truth value of the operand.
   ```python
   x = not True  # Output: False
   ```

4. **if**: Starts a conditional statement.
   ```python
   if x > 0:
       print("Positive")
   ```

5. **else**: Defines a block of code executed if the `if` condition is false.
   ```python
   if x > 0:
       print("Positive")
   else:
       print("Non-positive")
   ```

6. **elif**: Stands for "else if," used for additional conditions.
   ```python
   if x > 0:
       print("Positive")
   elif x == 0:
       print("Zero")
   else:
       print("Negative")
   ```

7. **while**: Creates a loop that executes as long as the condition is true.
   ```python
   while x < 5:
       x += 1
   ```

8. **for**: Creates a loop to iterate over a sequence.
   ```python
   for item in [1, 2, 3]:
       print(item)
   ```

9. **in**: Checks if a value exists in a sequence.
   ```python
   if 2 in [1, 2, 3]:
       print("Found")
   ```

10. **try/except/finally**: Exception handling blocks.
    ```python
    try:
        x = 1 / 0
    except ZeroDivisionError:
        print("Division by zero")
    finally:
        print("Executed regardless")
    ```

11. **def**: Defines a function.
    ```python
    def add(a, b):
        return a + b
    ```

12. **class**: Defines a class.
    ```python
    class Person:
        pass
    ```

13. **import/from/as**: Imports modules or specific components, with optional aliasing.
    ```python
    import math
    from math import pi as circle_constant
    ```

14. **True/False/None**: Boolean values and null equivalent.
    ```python
    x = True
    y = False
    z = None
    ```

15. **is**: Checks identity of two objects.
    ```python
    x = y = [1, 2, 3]
    print(x is y)  # Output: True
    ```

16. **lambda**: Creates small anonymous functions.
    ```python
    square = lambda x: x ** 2
    print(square(3))  # Output: 9
    ```

17. **with**: Used for context management.
    ```python
    with open("file.txt", "r") as file:
        content = file.read()
    ```

18. **global/nonlocal**: Modifies variables in different scopes.
    ```python
    def example():
        global x
        x = 10
    ```

---

# Lists vs. Sets in Python

## Lists

- **Ordered Collection:**
  - Lists maintain the order of elements as they are added.
  - Elements can be accessed using their index.

  ```python
  my_list = [1, 2, 3, 4, 5]
  print(my_list[0])  # Output: 1
  ```

- **Mutable:**
  - Lists allow modification of elements after creation.

  ```python
  my_list[1] = 10
  ```

- **Allows Duplicate Elements:**
  - Lists can contain duplicate values.

  ```python
  my_list = [1, 2, 2, 3, 4]
  ```

- **Use Cases:**
  - Ideal when an ordered collection with modifiable elements is required.

## Sets

- **Unordered Collection:**
  - Sets do not maintain the order of elements.
  - Index-based access is not possible.

  ```python
  my_set = {1, 2, 3, 4, 5}
  ```

- **Mutable:**
  - Sets allow adding and removing elements after creation.

  ```python
  my_set.add(6)
  ```

- **No Duplicate Elements:**
  - Sets automatically eliminate duplicate values.

  ```python
  my_set = {1, 2, 2, 3, 4}  # Results in {1, 2, 3, 4}
  ```

- **Use Cases:**
  - Suitable when unique elements and set operations like union, intersection, or difference are needed.

---

## Common Operations

### Adding Elements:
- **Lists:** Use `append()` or `insert()`.  
- **Sets:** Use `add()`.

### Removing Elements:
- **Lists:** Use `remove()`, `pop()`, or the `del` statement.  
- **Sets:** Use `remove()` or `discard()`.

### Checking Membership:
- Both lists and sets use the `in` operator, but it is more efficient for sets.

```python
# Lists
if 3 in my_list:
    print("3 is in the list")

# Sets
if 3 in my_set:
    print("3 is in the set")
```

---

## Choosing Between Lists and Sets

### Use **Lists** When:
- Maintaining the order of elements is necessary.
- Duplicate values are acceptable.
- You need to access elements by index.

### Use **Sets** When:
- The order of elements does not matter.
- Unique values are required.
- Set operations like union, intersection, or difference are needed.
