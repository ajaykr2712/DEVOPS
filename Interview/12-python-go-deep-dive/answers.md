### Python - Lists, Dicts, Sets

**“How does a Python set handle duplicates internally?”**

A Python `set` is an unordered collection of unique elements. Internally, sets are implemented using a hash table, much like a dictionary. When an element is added to a set, Python computes its hash value. This hash determines the element's position within the underlying data structure.

If you attempt to add an element that is already present, its hash value will collide with the existing one. Python then performs an equality check (`__eq__`) to confirm if the elements are identical. If they are, the new element is discarded, ensuring that all elements in the set remain unique. This hash-based approach allows for highly efficient (average O(1)) additions and membership tests.

### Decorators & Closures

**“What is a closure? Can you write one?”**

A closure is a function that remembers and has access to variables from its enclosing scope, even after the outer function has finished executing. This is possible because the inner function maintains a reference to its lexical environment.

Here is an example of a closure in Python:

```python
def outer_function(text):
    """
    This outer function takes a text and returns a closure.
    """
    def inner_function():
        """
        This inner function is a closure that prints the text
        from the enclosing scope.
        """
        print(text)
    return inner_function

# Create a closure
my_closure = outer_function("Hello, Closure!")

# Execute the closure
my_closure()  # Output: Hello, Closure!
```

In this example, `inner_function` "closes over" the `text` variable from `outer_function`. Even after `outer_function` has returned, `my_closure` retains access to `text`.

### OOP in Python

**“How is inheritance handled? What’s MRO?”**

Inheritance in Python allows a class (the child) to inherit attributes and methods from another class (the parent). Python supports multiple inheritance, where a class can inherit from more than one parent.

**Method Resolution Order (MRO)** is the rule that Python follows to determine the order in which to search for methods in a class hierarchy. It uses the **C3 linearization algorithm**, which ensures a consistent and predictable order. You can inspect a class's MRO using the `__mro__` attribute or the `mro()` method.

```python
class A:
    def who_am_i(self):
        print("I am an A")

class B(A):
    pass

class C(A):
    def who_am_i(self):
        print("I am a C")

class D(B, C):
    pass

d = D()
d.who_am_i()  # Output: I am a C
print(D.__mro__)
# Output: (<class '__main__.D'>, <class '__main__.B'>, <class '__main__.C'>, <class '__main__.A'>, <class 'object'>)
```

The MRO for class `D` is `(D, B, C, A, object)`. When `d.who_am_i()` is called, Python searches this tuple and finds the method in class `C`.

### Error Handling

**“What happens when you raise an exception inside a context manager?”**

When an exception is raised inside a `with` block (a context manager), the context manager's `__exit__` method is called. This method receives the exception type, value, and traceback as arguments.

The `__exit__` method can handle the exception and "swallow" it by returning `True`, in which case the exception is suppressed and does not propagate outside the `with` block. If `__exit__` returns `False` or any other "falsy" value (or doesn't return anything), the exception is re-raised after the `__exit__` method completes. This ensures that cleanup code (like closing a file or releasing a lock) is always executed.

### Go - Pointers & Structs

**“Explain how memory is passed in Go functions — is it by value or reference?”**

In Go, everything is passed by **value**. When you pass a variable to a function, Go creates a copy of that variable and passes the copy. This applies to all types, including structs, integers, and strings.

However, the behavior can appear to be "pass-by-reference" when using pointers, slices, maps, or channels. This is because the value being copied is a pointer or a reference type itself.

*   **Structs, ints, etc.**: A full copy of the data is made.
*   **Pointers**: A copy of the memory address is made. The function can then modify the data at that address.
*   **Slices, Maps, Channels**: These are reference types that contain a pointer to an underlying data structure. When passed, the pointer is copied, but both the original and the copy point to the same data.

### Go Concurrency

**“How would you prevent race conditions with goroutines?”**

Race conditions occur when multiple goroutines access and modify shared data concurrently. Go provides two primary mechanisms to prevent them:

1.  **Mutexes (`sync.Mutex`)**: A mutex (mutual exclusion lock) ensures that only one goroutine can access a critical section of code at a time. You lock the mutex before accessing shared data and unlock it afterward.

    ```go
    import "sync"

    var counter int
    var lock sync.Mutex

    func increment() {
        lock.Lock()
        counter++
        lock.Unlock()
    }
    ```

2.  **Channels**: Channels provide a way for goroutines to communicate and synchronize by sending and receiving values. The Go philosophy is "Do not communicate by sharing memory; instead, share memory by communicating." By passing data between goroutines via channels, you can avoid explicit locks.

    ```go
    func worker(jobs <-chan int, results chan<- int) {
        for j := range jobs {
            // Process job and send result
            results <- j * 2
        }
    }
    ```

### Unit Testing (Python + Go)

**“Write a unit test to mock an API call that returns JSON.”**

**Python (using `unittest.mock`)**

```python
import unittest
from unittest.mock import patch, Mock
import requests

def get_user_data(user_id):
    response = requests.get(f"https://api.example.com/users/{user_id}")
    response.raise_for_status()
    return response.json()

class TestApi(unittest.TestCase):
    @patch('requests.get')
    def test_get_user_data(self, mock_get):
        # Configure the mock to return a response with a json method
        mock_response = Mock()
        mock_response.json.return_value = {"id": 1, "name": "John Doe"}
        mock_response.raise_for_status = Mock()
        mock_get.return_value = mock_response

        # Call the function
        user_data = get_user_data(1)

        # Assertions
        self.assertEqual(user_data, {"id": 1, "name": "John Doe"})
        mock_get.assert_called_once_with("https://api.example.com/users/1")

if __name__ == '__main__':
    unittest.main()
```

**Go (using `net/http/httptest`)**

```go
package main

import (
    "encoding/json"
    "net/http"
    "net/http/httptest"
    "testing"
)

type User struct {
    ID   int    `json:"id"`
    Name string `json:"name"`
}

func GetUserData(apiURL string) (*User, error) {
    resp, err := http.Get(apiURL)
    if err != nil {
        return nil, err
    }
    defer resp.Body.Close()

    var user User
    if err := json.NewDecoder(resp.Body).Decode(&user); err != nil {
        return nil, err
    }
    return &user, nil
}

func TestGetUserData(t *testing.T) {
    // Create a mock server
    server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        w.Header().Set("Content-Type", "application/json")
        w.WriteHeader(http.StatusOK)
        json.NewEncoder(w).Encode(User{ID: 1, Name: "John Doe"})
    }))
    defer server.Close()

    // Call the function with the mock server's URL
    user, err := GetUserData(server.URL)

    // Assertions
    if err != nil {
        t.Fatalf("expected no error, got %v", err)
    }
    if user.ID != 1 || user.Name != "John Doe" {
        t.Errorf("expected user {ID:1, Name:\"John Doe\"}, got %+v", user)
    }
}
```
