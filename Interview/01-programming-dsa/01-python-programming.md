# 🐍 Python Programming - Complete Interview Guide

## 📚 Table of Contents
1. [Python Basics](#python-basics)
2. [Object-Oriented Programming](#object-oriented-programming)
3. [Advanced Python](#advanced-python)
4. [Async Programming](#async-programming)
5. [Exception Handling](#exception-handling)
6. [Interview Questions](#interview-questions)

---

## Python Basics

### Data Types and Variables

```python
# Basic data types
integer_num = 42
float_num = 3.14
string_text = "Hello World"
boolean_flag = True
list_items = [1, 2, 3, 4, 5]
tuple_items = (1, 2, 3)
dict_data = {"name": "John", "age": 30}
set_data = {1, 2, 3, 4, 5}

# Type checking
print(type(integer_num))  # <class 'int'>
print(isinstance(string_text, str))  # True
```

### String Operations

```python
# String methods
text = "Python Programming"
print(text.lower())           # python programming
print(text.upper())           # PYTHON PROGRAMMING
print(text.replace("Python", "Java"))  # Java Programming
print(text.split())           # ['Python', 'Programming']

# String formatting
name = "Alice"
age = 25
# f-strings (preferred)
message = f"My name is {name} and I'm {age} years old"
# format method
message = "My name is {} and I'm {} years old".format(name, age)
# % formatting (legacy)
message = "My name is %s and I'm %d years old" % (name, age)
```

### List Comprehensions

```python
# Basic list comprehension
numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
squares = [x**2 for x in numbers]
even_squares = [x**2 for x in numbers if x % 2 == 0]

# Nested list comprehension
matrix = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
flattened = [item for row in matrix for item in row]

# Dictionary comprehension
word_lengths = {word: len(word) for word in ["hello", "world", "python"]}

# Set comprehension
unique_lengths = {len(word) for word in ["hello", "world", "python"]}
```

### Functions and Decorators

```python
# Basic function
def greet(name, greeting="Hello"):
    """Greet a person with a message."""
    return f"{greeting}, {name}!"

# *args and **kwargs
def flexible_function(*args, **kwargs):
    print(f"Args: {args}")
    print(f"Kwargs: {kwargs}")

flexible_function(1, 2, 3, name="Alice", age=30)

# Decorators
def timer_decorator(func):
    import time
    def wrapper(*args, **kwargs):
        start = time.time()
        result = func(*args, **kwargs)
        end = time.time()
        print(f"{func.__name__} took {end - start:.2f} seconds")
        return result
    return wrapper

@timer_decorator
def slow_function():
    import time
    time.sleep(1)
    return "Done"

# Property decorator
class Circle:
    def __init__(self, radius):
        self._radius = radius
    
    @property
    def radius(self):
        return self._radius
    
    @radius.setter
    def radius(self, value):
        if value < 0:
            raise ValueError("Radius cannot be negative")
        self._radius = value
    
    @property
    def area(self):
        return 3.14159 * self._radius ** 2
```

---

## Object-Oriented Programming

### Classes and Inheritance

```python
# Base class
class Animal:
    def __init__(self, name, species):
        self.name = name
        self.species = species
        self._protected_var = "protected"
        self.__private_var = "private"
    
    def speak(self):
        pass  # Abstract method
    
    def info(self):
        return f"{self.name} is a {self.species}"
    
    @classmethod
    def create_dog(cls, name):
        return cls(name, "Dog")
    
    @staticmethod
    def animal_sound():
        return "Some generic animal sound"

# Inheritance
class Dog(Animal):
    def __init__(self, name, breed):
        super().__init__(name, "Dog")
        self.breed = breed
    
    def speak(self):
        return "Woof!"
    
    def fetch(self):
        return f"{self.name} is fetching the ball"

class Cat(Animal):
    def speak(self):
        return "Meow!"

# Multiple inheritance
class Flyable:
    def fly(self):
        return "Flying high!"

class Bird(Animal, Flyable):
    def speak(self):
        return "Tweet!"

# Usage
dog = Dog("Buddy", "Golden Retriever")
print(dog.speak())  # Woof!
print(dog.info())   # Buddy is a Dog
print(dog.fetch())  # Buddy is fetching the ball

# Class methods and static methods
dog2 = Animal.create_dog("Max")
print(Animal.animal_sound())
```

### Magic Methods (Dunder Methods)

```python
class Vector:
    def __init__(self, x, y):
        self.x = x
        self.y = y
    
    def __str__(self):
        return f"Vector({self.x}, {self.y})"
    
    def __repr__(self):
        return f"Vector(x={self.x}, y={self.y})"
    
    def __add__(self, other):
        return Vector(self.x + other.x, self.y + other.y)
    
    def __sub__(self, other):
        return Vector(self.x - other.x, self.y - other.y)
    
    def __eq__(self, other):
        return self.x == other.x and self.y == other.y
    
    def __len__(self):
        return int((self.x**2 + self.y**2)**0.5)
    
    def __getitem__(self, key):
        if key == 0:
            return self.x
        elif key == 1:
            return self.y
        else:
            raise IndexError("Vector index out of range")

# Usage
v1 = Vector(3, 4)
v2 = Vector(1, 2)
print(v1 + v2)  # Vector(4, 6)
print(len(v1))  # 5
print(v1[0])    # 3
```

---

## Advanced Python

### Context Managers

```python
# Using with statement
with open('file.txt', 'w') as f:
    f.write("Hello World")

# Custom context manager using class
class DatabaseConnection:
    def __init__(self, host):
        self.host = host
    
    def __enter__(self):
        print(f"Connecting to {self.host}")
        self.connection = f"Connection to {self.host}"
        return self.connection
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        print(f"Closing connection to {self.host}")
        if exc_type:
            print(f"Exception occurred: {exc_val}")
        return False  # Don't suppress exceptions

# Custom context manager using contextlib
from contextlib import contextmanager

@contextmanager
def database_connection(host):
    print(f"Connecting to {host}")
    connection = f"Connection to {host}"
    try:
        yield connection
    finally:
        print(f"Closing connection to {host}")

# Usage
with database_connection("localhost") as conn:
    print(f"Using {conn}")
```

### Generators and Iterators

```python
# Generator function
def fibonacci_generator(n):
    a, b = 0, 1
    count = 0
    while count < n:
        yield a
        a, b = b, a + b
        count += 1

# Generator expression
squares_gen = (x**2 for x in range(10))

# Custom iterator
class CountDown:
    def __init__(self, start):
        self.start = start
    
    def __iter__(self):
        return self
    
    def __next__(self):
        if self.start <= 0:
            raise StopIteration
        self.start -= 1
        return self.start + 1

# Usage
for num in fibonacci_generator(10):
    print(num, end=" ")  # 0 1 1 2 3 5 8 13 21 34

for num in CountDown(5):
    print(num, end=" ")  # 5 4 3 2 1
```

### Closures and Function Factories

```python
# Closure example
def outer_function(x):
    def inner_function(y):
        return x + y
    return inner_function

add_10 = outer_function(10)
print(add_10(5))  # 15

# Function factory
def create_multiplier(n):
    def multiplier(x):
        return x * n
    return multiplier

double = create_multiplier(2)
triple = create_multiplier(3)

print(double(5))  # 10
print(triple(5))  # 15

# Decorator with arguments
def repeat(times):
    def decorator(func):
        def wrapper(*args, **kwargs):
            for _ in range(times):
                result = func(*args, **kwargs)
            return result
        return wrapper
    return decorator

@repeat(3)
def say_hello():
    print("Hello!")

say_hello()  # Prints "Hello!" three times
```

---

## Async Programming

### Asyncio Basics

```python
import asyncio
import aiohttp
import time

# Basic async function
async def say_hello():
    print("Hello")
    await asyncio.sleep(1)
    print("World")

# Running async function
asyncio.run(say_hello())

# Multiple async tasks
async def fetch_data(url, session):
    async with session.get(url) as response:
        return await response.text()

async def main():
    async with aiohttp.ClientSession() as session:
        tasks = []
        urls = [
            'https://httpbin.org/delay/1',
            'https://httpbin.org/delay/2',
            'https://httpbin.org/delay/3'
        ]
        
        for url in urls:
            task = asyncio.create_task(fetch_data(url, session))
            tasks.append(task)
        
        results = await asyncio.gather(*tasks)
        return results

# Async context manager
class AsyncDatabaseConnection:
    async def __aenter__(self):
        print("Connecting to database")
        await asyncio.sleep(0.1)  # Simulate connection time
        return self
    
    async def __aexit__(self, exc_type, exc_val, exc_tb):
        print("Closing database connection")
        await asyncio.sleep(0.1)  # Simulate closing time

async def use_database():
    async with AsyncDatabaseConnection() as db:
        print("Using database")
        await asyncio.sleep(1)

# Async generator
async def async_range(count):
    for i in range(count):
        await asyncio.sleep(0.1)
        yield i

async def consume_async_generator():
    async for num in async_range(5):
        print(num)
```

### Threading vs Asyncio

```python
import threading
import time
import asyncio

# Threading example
def cpu_bound_task(n):
    count = 0
    for i in range(n):
        count += i
    return count

def io_bound_task():
    time.sleep(1)
    return "IO task completed"

# Threading for CPU-bound tasks
def threading_example():
    threads = []
    for i in range(3):
        thread = threading.Thread(target=io_bound_task)
        threads.append(thread)
        thread.start()
    
    for thread in threads:
        thread.join()

# Asyncio for I/O-bound tasks
async def async_io_task():
    await asyncio.sleep(1)
    return "Async IO task completed"

async def asyncio_example():
    tasks = [async_io_task() for _ in range(3)]
    results = await asyncio.gather(*tasks)
    return results
```

---

## Exception Handling

### Basic Exception Handling

```python
# Basic try-except
try:
    result = 10 / 0
except ZeroDivisionError:
    print("Cannot divide by zero!")

# Multiple exceptions
try:
    number = int(input("Enter a number: "))
    result = 10 / number
except ValueError:
    print("Invalid input! Please enter a number.")
except ZeroDivisionError:
    print("Cannot divide by zero!")
except Exception as e:
    print(f"An unexpected error occurred: {e}")

# try-except-else-finally
try:
    file = open("data.txt", "r")
except FileNotFoundError:
    print("File not found!")
else:
    print("File opened successfully")
    content = file.read()
finally:
    if 'file' in locals():
        file.close()
        print("File closed")
```

### Custom Exceptions

```python
class CustomError(Exception):
    """Base class for custom exceptions"""
    pass

class ValidationError(CustomError):
    """Raised when validation fails"""
    def __init__(self, message, code=None):
        self.message = message
        self.code = code
        super().__init__(self.message)

class AuthenticationError(CustomError):
    """Raised when authentication fails"""
    pass

# Using custom exceptions
def validate_age(age):
    if not isinstance(age, int):
        raise ValidationError("Age must be an integer", code="INVALID_TYPE")
    if age < 0:
        raise ValidationError("Age cannot be negative", code="INVALID_VALUE")
    if age > 150:
        raise ValidationError("Age seems unrealistic", code="UNREALISTIC_VALUE")
    return True

def authenticate_user(username, password):
    valid_users = {"admin": "password123", "user": "userpass"}
    if username not in valid_users:
        raise AuthenticationError(f"User '{username}' not found")
    if valid_users[username] != password:
        raise AuthenticationError("Invalid password")
    return True

# Exception chaining
def process_data(data):
    try:
        # Some processing that might fail
        if not data:
            raise ValueError("Data cannot be empty")
        return data.upper()
    except ValueError as e:
        raise ValidationError("Data processing failed") from e

# Usage examples
try:
    validate_age(-5)
except ValidationError as e:
    print(f"Validation failed: {e.message} (Code: {e.code})")

try:
    authenticate_user("invalid_user", "wrong_pass")
except AuthenticationError as e:
    print(f"Authentication failed: {e}")

try:
    process_data("")
except ValidationError as e:
    print(f"Error: {e}")
    print(f"Original cause: {e.__cause__}")
```

---

## Interview Questions

### Q1: What's the difference between `is` and `==`?

**Answer:**
```python
# == checks for value equality
# is checks for identity (same object in memory)

a = [1, 2, 3]
b = [1, 2, 3]
c = a

print(a == b)  # True (same values)
print(a is b)  # False (different objects)
print(a is c)  # True (same object)

# Special case with small integers and strings
x = 256
y = 256
print(x is y)  # True (Python caches small integers)

x = 257
y = 257
print(x is y)  # False (not cached)
```

### Q2: Explain Python's GIL (Global Interpreter Lock)

**Answer:**
The GIL is a mutex that protects access to Python objects, preventing multiple threads from executing Python bytecode simultaneously. This means:

- **CPU-bound tasks**: Use multiprocessing instead of threading
- **I/O-bound tasks**: Threading works fine because threads release GIL during I/O

```python
import threading
import multiprocessing
import time

def cpu_intensive_task(n):
    count = 0
    for i in range(n):
        count += i ** 2
    return count

# Threading (not effective for CPU-bound due to GIL)
def test_threading():
    start = time.time()
    threads = []
    for _ in range(4):
        thread = threading.Thread(target=cpu_intensive_task, args=(1000000,))
        threads.append(thread)
        thread.start()
    
    for thread in threads:
        thread.join()
    
    print(f"Threading took: {time.time() - start:.2f} seconds")

# Multiprocessing (effective for CPU-bound)
def test_multiprocessing():
    start = time.time()
    with multiprocessing.Pool(4) as pool:
        pool.map(cpu_intensive_task, [1000000] * 4)
    
    print(f"Multiprocessing took: {time.time() - start:.2f} seconds")
```

### Q3: What are metaclasses?

**Answer:**
Metaclasses are "classes that create classes". They define how classes are constructed.

```python
# Metaclass example
class SingletonMeta(type):
    _instances = {}
    
    def __call__(cls, *args, **kwargs):
        if cls not in cls._instances:
            cls._instances[cls] = super().__call__(*args, **kwargs)
        return cls._instances[cls]

class Singleton(metaclass=SingletonMeta):
    def __init__(self, value):
        self.value = value

# Usage
s1 = Singleton("first")
s2 = Singleton("second")
print(s1 is s2)  # True
print(s1.value)  # "first" (not changed)

# Using __new__ for similar effect
class SingletonNew:
    _instance = None
    
    def __new__(cls, *args, **kwargs):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance
```

### Q4: Explain memory management in Python

**Answer:**
```python
import sys
import gc

# Reference counting
a = [1, 2, 3]
print(sys.getrefcount(a))  # Reference count

b = a  # Increases reference count
print(sys.getrefcount(a))

del b  # Decreases reference count
print(sys.getrefcount(a))

# Circular references (handled by garbage collector)
class Node:
    def __init__(self, value):
        self.value = value
        self.ref = None

node1 = Node(1)
node2 = Node(2)
node1.ref = node2
node2.ref = node1  # Circular reference

# Force garbage collection
gc.collect()

# Memory optimization with __slots__
class RegularClass:
    def __init__(self, x, y):
        self.x = x
        self.y = y

class OptimizedClass:
    __slots__ = ['x', 'y']
    
    def __init__(self, x, y):
        self.x = x
        self.y = y

# Regular class uses more memory due to __dict__
regular = RegularClass(1, 2)
optimized = OptimizedClass(1, 2)

print(sys.getsizeof(regular))   # Larger
print(sys.getsizeof(optimized)) # Smaller
```

### Q5: What's the difference between shallow and deep copy?

**Answer:**
```python
import copy

# Original list with nested objects
original = [[1, 2, 3], [4, 5, 6]]

# Shallow copy
shallow = copy.copy(original)
shallow[0].append(4)
print(original)  # [[1, 2, 3, 4], [4, 5, 6]] - original affected!

# Deep copy
original = [[1, 2, 3], [4, 5, 6]]
deep = copy.deepcopy(original)
deep[0].append(4)
print(original)  # [[1, 2, 3], [4, 5, 6]] - original not affected

# For immutable objects, shallow copy is sufficient
original_tuple = (1, 2, 3)
copied_tuple = copy.copy(original_tuple)
print(original_tuple is copied_tuple)  # True (optimization)
```

### Practice Problems

```python
# Problem 1: Implement a LRU Cache
from collections import OrderedDict

class LRUCache:
    def __init__(self, capacity):
        self.capacity = capacity
        self.cache = OrderedDict()
    
    def get(self, key):
        if key in self.cache:
            # Move to end (most recently used)
            self.cache.move_to_end(key)
            return self.cache[key]
        return -1
    
    def put(self, key, value):
        if key in self.cache:
            # Update existing key
            self.cache.move_to_end(key)
        elif len(self.cache) >= self.capacity:
            # Remove least recently used
            self.cache.popitem(last=False)
        
        self.cache[key] = value

# Problem 2: Implement a thread-safe counter
import threading

class ThreadSafeCounter:
    def __init__(self):
        self._value = 0
        self._lock = threading.Lock()
    
    def increment(self):
        with self._lock:
            self._value += 1
    
    def decrement(self):
        with self._lock:
            self._value -= 1
    
    @property
    def value(self):
        with self._lock:
            return self._value

# Problem 3: Context manager for timing code execution
import time
from contextlib import contextmanager

@contextmanager
def timer():
    start = time.time()
    try:
        yield
    finally:
        end = time.time()
        print(f"Execution time: {end - start:.2f} seconds")

# Usage
with timer():
    time.sleep(1)  # Simulates some work
```

## 🎯 Key Takeaways for Interview

1. **Understand Python's memory model and GIL**
2. **Know when to use threading vs multiprocessing vs asyncio**
3. **Master OOP concepts and magic methods**
4. **Practice implementing design patterns**
5. **Understand exception handling best practices**
6. **Be familiar with advanced features like decorators, context managers, and generators**

---

## 📝 Interview Questions & Answers (50+ Questions)

| **No.** | **Difficulty** | **Question** | **Answer** |
|---------|----------------|--------------|------------|
| 1 | Easy | What is Python? | Python is a high-level, interpreted, object-oriented programming language with dynamic semantics. It's known for its simple syntax and readability. |
| 2 | Easy | What are the key features of Python? | Easy to learn, interpreted language, object-oriented, cross-platform, large standard library, dynamically typed, automatic memory management. |
| 3 | Easy | What is the difference between list and tuple? | Lists are mutable (can be changed), defined with [], while tuples are immutable (cannot be changed), defined with (). Lists are slower but more flexible. |
| 4 | Easy | How do you comment in Python? | Single line: # comment, Multi-line: """comment""" or '''comment''' |
| 5 | Easy | What are Python data types? | int, float, str, bool, list, tuple, dict, set, frozenset, complex, bytes, bytearray |
| 6 | Easy | What is indentation in Python? | Python uses indentation (whitespace) to define code blocks instead of braces {}. Standard is 4 spaces per indentation level. |
| 7 | Easy | What is a variable in Python? | A variable is a name that refers to a value stored in memory. Python variables don't need explicit declaration and are dynamically typed. |
| 8 | Easy | How do you take input from user? | Using input() function: name = input("Enter name: ") |
| 9 | Easy | What is print() function? | print() is used to display output on screen. Syntax: print(value1, value2, sep=' ', end='\n') |
| 10 | Easy | What are Python keywords? | Reserved words that have special meaning: if, else, for, while, def, class, import, return, try, except, etc. |
| 11 | Medium | What is the difference between '==' and 'is'? | '==' compares values for equality, 'is' compares object identity (memory location). a == b checks if values are same, a is b checks if they're the same object. |
| 12 | Medium | What are Python decorators? | Decorators are functions that modify the behavior of other functions or classes. They use @decorator_name syntax and are called higher-order functions. |
| 13 | Medium | Explain list comprehension with example. | List comprehension creates lists concisely: [x**2 for x in range(10) if x%2==0] creates [0, 4, 16, 36, 64] |
| 14 | Medium | What is lambda function? | Lambda is an anonymous function defined with lambda keyword: lambda x: x**2. Used for short, simple functions often with map(), filter(), reduce(). |
| 15 | Medium | What are *args and **kwargs? | *args passes variable number of positional arguments as tuple, **kwargs passes variable number of keyword arguments as dictionary to functions. |
| 16 | Medium | What is the difference between shallow and deep copy? | Shallow copy creates new object but references are shared. Deep copy creates new object with new references. Use copy.copy() vs copy.deepcopy(). |
| 17 | Medium | What are Python generators? | Generators are functions that return iterator objects. They use yield keyword and generate values on-demand, saving memory for large datasets. |
| 18 | Medium | What is exception handling in Python? | Using try-except blocks to handle runtime errors gracefully. try: code, except ExceptionType: handle error, finally: cleanup code. |
| 19 | Medium | What are Python modules and packages? | Module is a .py file containing Python code. Package is a directory containing multiple modules with __init__.py file. |
| 20 | Medium | What is __init__ method? | __init__ is constructor method called when object is created. It initializes object attributes: def __init__(self, params): self.attr = value |
| 21 | Medium | What are class and instance variables? | Class variables are shared by all instances, defined in class. Instance variables are unique to each object, defined in __init__ with self. |
| 22 | Medium | What is inheritance in Python? | Inheritance allows class to inherit attributes/methods from another class. class Child(Parent): pass. Supports single, multiple, multilevel inheritance. |
| 23 | Medium | What are Python magic methods? | Special methods with double underscores like __str__, __len__, __add__. They define how objects behave with built-in functions and operators. |
| 24 | Medium | What is method overriding? | Redefining parent class method in child class with same name. Child method is called instead of parent method for child objects. |
| 25 | Medium | What are Python iterators? | Objects implementing __iter__() and __next__() methods. They can be iterated over with for loops or next() function. |
| 26 | Hard | What is Global Interpreter Lock (GIL)? | GIL is a mutex preventing multiple threads from executing Python bytecode simultaneously. It makes Python thread-safe but limits true parallelism in CPU-bound tasks. |
| 27 | Hard | Explain Python memory management. | Python uses reference counting + cyclic garbage collector. Objects are deleted when reference count reaches 0. Circular references handled by gc module. |
| 28 | Hard | What are metaclasses in Python? | Metaclasses are classes whose instances are classes. They define how classes are created. class MyClass(metaclass=MyMeta): pass |
| 29 | Hard | What is monkey patching? | Dynamically modifying classes/modules at runtime. Can add/modify methods to existing classes: MyClass.new_method = lambda self: "patched" |
| 30 | Hard | What are context managers? | Objects defining __enter__ and __exit__ methods for use with 'with' statement. Ensure proper resource cleanup: with open() as f: |
| 31 | Hard | What is the difference between staticmethod and classmethod? | @staticmethod doesn't receive any automatic arguments. @classmethod receives class as first argument (cls). Static methods are utility functions. |
| 32 | Hard | Explain Python's descriptor protocol. | Descriptors define __get__, __set__, __delete__ methods to control attribute access. Properties, methods are descriptors. Used for validation, computed attributes. |
| 33 | Hard | What is multiprocessing vs multithreading? | Multiprocessing creates separate processes (parallel execution), multithreading creates threads (concurrent execution limited by GIL in Python). |
| 34 | Hard | What are Python closures? | Inner function that captures and remembers variables from outer function scope even after outer function returns. |
| 35 | Hard | What is method resolution order (MRO)? | Order in which Python searches for methods in inheritance hierarchy. Uses C3 linearization algorithm. Check with ClassName.__mro__ or ClassName.mro(). |
| 36 | Hard | What are weak references? | References that don't increase object's reference count. Object can be garbage collected even if weak references exist. Use weakref module. |
| 37 | Hard | What is the difference between __new__ and __init__? | __new__ creates and returns new instance (constructor), __init__ initializes the instance (initializer). __new__ is called before __init__. |
| 38 | Hard | Explain Python's import system. | Python searches for modules in sys.path. Modules are cached in sys.modules. Import process: find, load, bind to namespace. |
| 39 | Hard | What are coroutines and async/await? | Coroutines are functions that can pause/resume execution. async def defines coroutine, await pauses execution. Used for asynchronous programming. |
| 40 | Hard | What is the difference between __call__ and regular methods? | __call__ makes object callable like function: obj(). Regular methods are called with obj.method(). __call__ enables function-like behavior. |
| 41 | Expert | How does Python's garbage collection work in detail? | Python uses reference counting as primary mechanism + cyclic garbage collector for circular references. GC runs in generations (0,1,2) with different thresholds. |
| 42 | Expert | Explain Python's bytecode compilation. | Python compiles source to bytecode (.pyc files) for faster execution. dis module shows bytecode. Bytecode is interpreted by Python Virtual Machine (PVM). |
| 43 | Expert | What are slots in Python classes? | __slots__ restricts attributes that can be added to class instances, saves memory by avoiding __dict__. class Point: __slots__ = ['x', 'y'] |
| 44 | Expert | How do you optimize Python performance? | Use built-in functions, list comprehensions, generators, cProfile for profiling, NumPy for numerical computing, Cython for speed-critical code. |
| 45 | Expert | What is cooperative inheritance and super()? | super() enables cooperative multiple inheritance by following MRO. All methods in hierarchy should use super() to ensure proper method chaining. |
| 46 | Expert | Explain Python's threading limitations and solutions. | GIL limits threading for CPU-bound tasks. Solutions: multiprocessing for CPU-bound, asyncio for I/O-bound, C extensions release GIL. |
| 47 | Expert | What are abstract base classes (ABC)? | ABCs define interfaces that subclasses must implement. Use abc module: @abstractmethod decorator forces implementation in subclasses. |
| 48 | Expert | How does Python handle circular imports? | Python partially imports modules to break circular dependencies. Best practices: restructure code, use import inside functions, forward references. |
| 49 | Expert | What is the difference between bound and unbound methods? | Bound methods are associated with instance (self automatically passed). Unbound methods are accessed via class (must pass instance manually). |
| 50 | Expert | Explain Python's namespace and scope resolution (LEGB). | LEGB rule: Local → Enclosing → Global → Built-in. Python searches for variables in this order. global/nonlocal keywords modify scope behavior. |
| 51 | Expert | What are data descriptors vs non-data descriptors? | Data descriptors define __get__ and __set__/__delete__. Non-data descriptors only define __get__. Data descriptors have higher priority in attribute lookup. |
| 52 | Expert | How do you implement custom iterators? | Implement __iter__ (returns self) and __next__ (returns next value, raises StopIteration when done). Example: Fibonacci iterator with state management. |
| 53 | Expert | What is the difference between classmethod vs staticmethod use cases? | classmethod for alternative constructors, methods that need class info. staticmethod for utility functions logically related to class but don't need class/instance. |
| 54 | Expert | Explain Python's dynamic typing implementation. | Python objects carry type information. Variables are name bindings to objects. Type checking happens at runtime. PyObject structure contains reference count and type. |
| 55 | Expert | How do you implement singleton pattern in Python? | Multiple ways: __new__ method, decorator, metaclass, module-level. Considerations: thread-safety, inheritance, testing challenges. |
