# 🧪 Unit Testing - Complete Guide (Python & Go)

## 📚 Table of Contents
1. [Python Testing with unittest](#python-unittest)
2. [Python Testing with pytest](#python-pytest)
3. [Go Testing Framework](#go-testing)
4. [Test-Driven Development (TDD)](#test-driven-development)
5. [Mocking and Test Doubles](#mocking-and-test-doubles)
6. [Test Coverage and Quality](#test-coverage-and-quality)
7. [Interview Questions](#interview-questions)

---

## Python unittest

### Basic unittest Framework

```python
import unittest
import sys
import io
from unittest.mock import Mock, patch, MagicMock
import tempfile
import os

# Sample classes to test
class Calculator:
    def add(self, a, b):
        return a + b
    
    def subtract(self, a, b):
        return a - b
    
    def multiply(self, a, b):
        return a * b
    
    def divide(self, a, b):
        if b == 0:
            raise ValueError("Cannot divide by zero")
        return a / b
    
    def power(self, base, exponent):
        return base ** exponent

class BankAccount:
    def __init__(self, initial_balance=0):
        self.balance = initial_balance
        self.transaction_history = []
    
    def deposit(self, amount):
        if amount <= 0:
            raise ValueError("Deposit amount must be positive")
        self.balance += amount
        self.transaction_history.append(f"Deposited: ${amount}")
        return self.balance
    
    def withdraw(self, amount):
        if amount <= 0:
            raise ValueError("Withdrawal amount must be positive")
        if amount > self.balance:
            raise ValueError("Insufficient funds")
        self.balance -= amount
        self.transaction_history.append(f"Withdrew: ${amount}")
        return self.balance
    
    def get_balance(self):
        return self.balance

class FileManager:
    def read_file(self, filename):
        with open(filename, 'r') as file:
            return file.read()
    
    def write_file(self, filename, content):
        with open(filename, 'w') as file:
            file.write(content)
    
    def file_exists(self, filename):
        return os.path.exists(filename)

# Basic unittest examples
class TestCalculator(unittest.TestCase):
    
    def setUp(self):
        """Set up test fixtures before each test method."""
        self.calc = Calculator()
    
    def tearDown(self):
        """Clean up after each test method."""
        # Usually not needed for simple tests
        pass
    
    def test_add(self):
        """Test addition functionality"""
        result = self.calc.add(2, 3)
        self.assertEqual(result, 5)
        
        # Test with negative numbers
        result = self.calc.add(-1, 1)
        self.assertEqual(result, 0)
        
        # Test with floats
        result = self.calc.add(2.5, 3.7)
        self.assertAlmostEqual(result, 6.2, places=1)
    
    def test_subtract(self):
        """Test subtraction functionality"""
        result = self.calc.subtract(5, 3)
        self.assertEqual(result, 2)
        
        result = self.calc.subtract(0, 5)
        self.assertEqual(result, -5)
    
    def test_multiply(self):
        """Test multiplication functionality"""
        result = self.calc.multiply(4, 5)
        self.assertEqual(result, 20)
        
        result = self.calc.multiply(-2, 3)
        self.assertEqual(result, -6)
        
        result = self.calc.multiply(0, 100)
        self.assertEqual(result, 0)
    
    def test_divide(self):
        """Test division functionality"""
        result = self.calc.divide(10, 2)
        self.assertEqual(result, 5)
        
        result = self.calc.divide(7, 2)
        self.assertEqual(result, 3.5)
    
    def test_divide_by_zero(self):
        """Test division by zero raises exception"""
        with self.assertRaises(ValueError) as context:
            self.calc.divide(10, 0)
        
        self.assertEqual(str(context.exception), "Cannot divide by zero")
    
    def test_power(self):
        """Test power functionality"""
        result = self.calc.power(2, 3)
        self.assertEqual(result, 8)
        
        result = self.calc.power(5, 0)
        self.assertEqual(result, 1)
        
        result = self.calc.power(4, 0.5)
        self.assertEqual(result, 2)

class TestBankAccount(unittest.TestCase):
    
    def setUp(self):
        self.account = BankAccount(100)
    
    def test_initial_balance(self):
        """Test initial balance is set correctly"""
        account = BankAccount()
        self.assertEqual(account.get_balance(), 0)
        
        account_with_balance = BankAccount(50)
        self.assertEqual(account_with_balance.get_balance(), 50)
    
    def test_deposit(self):
        """Test deposit functionality"""
        new_balance = self.account.deposit(50)
        self.assertEqual(new_balance, 150)
        self.assertEqual(self.account.get_balance(), 150)
        
        # Check transaction history
        self.assertIn("Deposited: $50", self.account.transaction_history)
    
    def test_deposit_invalid_amount(self):
        """Test deposit with invalid amounts"""
        with self.assertRaises(ValueError):
            self.account.deposit(-10)
        
        with self.assertRaises(ValueError):
            self.account.deposit(0)
        
        # Balance should remain unchanged
        self.assertEqual(self.account.get_balance(), 100)
    
    def test_withdraw(self):
        """Test withdrawal functionality"""
        new_balance = self.account.withdraw(30)
        self.assertEqual(new_balance, 70)
        self.assertEqual(self.account.get_balance(), 70)
        
        # Check transaction history
        self.assertIn("Withdrew: $30", self.account.transaction_history)
    
    def test_withdraw_insufficient_funds(self):
        """Test withdrawal with insufficient funds"""
        with self.assertRaises(ValueError) as context:
            self.account.withdraw(150)
        
        self.assertEqual(str(context.exception), "Insufficient funds")
        self.assertEqual(self.account.get_balance(), 100)  # Balance unchanged
    
    def test_withdraw_invalid_amount(self):
        """Test withdrawal with invalid amounts"""
        with self.assertRaises(ValueError):
            self.account.withdraw(-10)
        
        with self.assertRaises(ValueError):
            self.account.withdraw(0)
    
    def test_multiple_transactions(self):
        """Test multiple transactions"""
        self.account.deposit(50)   # 150
        self.account.withdraw(30)  # 120
        self.account.deposit(25)   # 145
        
        self.assertEqual(self.account.get_balance(), 145)
        self.assertEqual(len(self.account.transaction_history), 3)

# Advanced unittest features
class TestAdvancedFeatures(unittest.TestCase):
    
    def test_assertions_examples(self):
        """Demonstrate various assertion methods"""
        # Equality assertions
        self.assertEqual(2 + 2, 4)
        self.assertNotEqual(2 + 2, 5)
        
        # Boolean assertions
        self.assertTrue(True)
        self.assertFalse(False)
        
        # None assertions
        self.assertIsNone(None)
        self.assertIsNotNone("hello")
        
        # Container assertions
        self.assertIn(2, [1, 2, 3])
        self.assertNotIn(4, [1, 2, 3])
        
        # Type assertions
        self.assertIsInstance(42, int)
        self.assertNotIsInstance("42", int)
        
        # Floating point comparison
        self.assertAlmostEqual(0.1 + 0.2, 0.3, places=7)
        
        # Greater/Less than
        self.assertGreater(5, 3)
        self.assertLess(3, 5)
        self.assertGreaterEqual(5, 5)
        self.assertLessEqual(3, 3)
        
        # Regular expressions
        self.assertRegex("hello world", r"hello \w+")
        
        # Collections
        self.assertCountEqual([1, 2, 3], [3, 2, 1])  # Same elements, order doesn't matter
    
    @unittest.skip("Demonstrating skip decorator")
    def test_skip_example(self):
        """This test will be skipped"""
        self.fail("This should not run")
    
    @unittest.skipIf(sys.version_info < (3, 8), "Requires Python 3.8+")
    def test_conditional_skip(self):
        """Skip if condition is met"""
        self.assertTrue(True)
    
    @unittest.expectedFailure
    def test_expected_failure(self):
        """This test is expected to fail"""
        self.assertEqual(1, 2)
    
    def test_subtest_example(self):
        """Using subtests to test multiple similar cases"""
        test_cases = [
            (2, 3, 5),
            (10, 5, 15),
            (-1, 1, 0),
            (0, 0, 0)
        ]
        
        calc = Calculator()
        
        for a, b, expected in test_cases:
            with self.subTest(a=a, b=b, expected=expected):
                result = calc.add(a, b)
                self.assertEqual(result, expected)

# Mock examples
class TestWithMocks(unittest.TestCase):
    
    @patch('builtins.open', unittest.mock.mock_open(read_data='file content'))
    def test_file_reading_with_mock(self):
        """Test file reading using mock"""
        file_manager = FileManager()
        content = file_manager.read_file('any_file.txt')
        self.assertEqual(content, 'file content')
    
    @patch('os.path.exists')
    def test_file_exists_with_mock(self, mock_exists):
        """Test file existence check with mock"""
        mock_exists.return_value = True
        
        file_manager = FileManager()
        result = file_manager.file_exists('some_file.txt')
        
        self.assertTrue(result)
        mock_exists.assert_called_once_with('some_file.txt')
    
    def test_mock_object_example(self):
        """Demonstrate mock object usage"""
        # Create a mock object
        mock_service = Mock()
        
        # Configure mock behavior
        mock_service.get_data.return_value = {"id": 1, "name": "test"}
        mock_service.is_available.return_value = True
        
        # Use the mock
        data = mock_service.get_data()
        available = mock_service.is_available()
        
        # Verify calls
        mock_service.get_data.assert_called_once()
        mock_service.is_available.assert_called_once()
        
        # Verify return values
        self.assertEqual(data, {"id": 1, "name": "test"})
        self.assertTrue(available)
    
    def test_mock_side_effects(self):
        """Demonstrate mock side effects"""
        mock_service = Mock()
        
        # Mock can raise exceptions
        mock_service.failing_method.side_effect = ConnectionError("Network error")
        
        with self.assertRaises(ConnectionError):
            mock_service.failing_method()
        
        # Mock can return different values on successive calls
        mock_service.counter.side_effect = [1, 2, 3]
        
        self.assertEqual(mock_service.counter(), 1)
        self.assertEqual(mock_service.counter(), 2)
        self.assertEqual(mock_service.counter(), 3)

# Test suite organization
class TestSuiteExample:
    """Example of organizing tests into suites"""
    
    @staticmethod
    def create_test_suite():
        """Create a custom test suite"""
        suite = unittest.TestSuite()
        
        # Add specific test methods
        suite.addTest(TestCalculator('test_add'))
        suite.addTest(TestCalculator('test_subtract'))
        
        # Add all tests from a test class
        suite.addTests(unittest.TestLoader().loadTestsFromTestCase(TestBankAccount))
        
        return suite
    
    @staticmethod
    def run_custom_suite():
        """Run a custom test suite"""
        suite = TestSuiteExample.create_test_suite()
        runner = unittest.TextTestRunner(verbosity=2)
        result = runner.run(suite)
        return result

# Performance testing with unittest
class TestPerformance(unittest.TestCase):
    
    def test_performance_benchmark(self):
        """Basic performance testing"""
        import time
        
        def slow_function():
            time.sleep(0.1)
            return sum(range(10000))
        
        start_time = time.time()
        result = slow_function()
        execution_time = time.time() - start_time
        
        self.assertLess(execution_time, 0.2, "Function took too long")
        self.assertIsInstance(result, int)

if __name__ == '__main__':
    # Run all tests
    unittest.main(verbosity=2)
```

---

## Python pytest

### Basic pytest Framework

```python
import pytest
import tempfile
import os
from unittest.mock import Mock, patch
import requests

# Same classes from unittest examples
from calculator import Calculator, BankAccount, FileManager

# Basic pytest examples
class TestCalculatorPytest:
    
    def setup_method(self):
        """Setup before each test method"""
        self.calc = Calculator()
    
    def teardown_method(self):
        """Cleanup after each test method"""
        pass
    
    def test_add(self):
        """Test addition"""
        assert self.calc.add(2, 3) == 5
        assert self.calc.add(-1, 1) == 0
        assert self.calc.add(2.5, 3.7) == pytest.approx(6.2, rel=1e-2)
    
    def test_subtract(self):
        """Test subtraction"""
        assert self.calc.subtract(5, 3) == 2
        assert self.calc.subtract(0, 5) == -5
    
    def test_multiply(self):
        """Test multiplication"""
        assert self.calc.multiply(4, 5) == 20
        assert self.calc.multiply(-2, 3) == -6
        assert self.calc.multiply(0, 100) == 0
    
    def test_divide(self):
        """Test division"""
        assert self.calc.divide(10, 2) == 5
        assert self.calc.divide(7, 2) == 3.5
    
    def test_divide_by_zero(self):
        """Test division by zero"""
        with pytest.raises(ValueError, match="Cannot divide by zero"):
            self.calc.divide(10, 0)
    
    def test_power(self):
        """Test power operation"""
        assert self.calc.power(2, 3) == 8
        assert self.calc.power(5, 0) == 1
        assert self.calc.power(4, 0.5) == 2

# Pytest fixtures
@pytest.fixture
def calculator():
    """Fixture to provide calculator instance"""
    return Calculator()

@pytest.fixture
def bank_account():
    """Fixture to provide bank account with initial balance"""
    return BankAccount(100)

@pytest.fixture
def empty_bank_account():
    """Fixture to provide empty bank account"""
    return BankAccount()

@pytest.fixture(scope="session")
def database_connection():
    """Session-scoped fixture for database connection"""
    # Setup: create connection
    connection = {"host": "localhost", "port": 5432, "connected": True}
    yield connection
    # Teardown: close connection
    connection["connected"] = False

@pytest.fixture
def temp_file():
    """Fixture to provide temporary file"""
    with tempfile.NamedTemporaryFile(mode='w+', delete=False) as f:
        f.write("test content")
        temp_filename = f.name
    
    yield temp_filename
    
    # Cleanup
    os.unlink(temp_filename)

# Using fixtures
class TestWithFixtures:
    
    def test_calculator_with_fixture(self, calculator):
        """Test using calculator fixture"""
        assert calculator.add(1, 2) == 3
    
    def test_bank_account_deposit(self, bank_account):
        """Test deposit using fixture"""
        new_balance = bank_account.deposit(50)
        assert new_balance == 150
        assert bank_account.get_balance() == 150
    
    def test_empty_account_initial_balance(self, empty_bank_account):
        """Test empty account using fixture"""
        assert empty_bank_account.get_balance() == 0
    
    def test_temp_file_fixture(self, temp_file):
        """Test using temporary file fixture"""
        with open(temp_file, 'r') as f:
            content = f.read()
        assert content == "test content"

# Parametrized tests
class TestParametrized:
    
    @pytest.mark.parametrize("a,b,expected", [
        (2, 3, 5),
        (10, 5, 15),
        (-1, 1, 0),
        (0, 0, 0),
        (2.5, 3.7, 6.2)
    ])
    def test_add_parametrized(self, calculator, a, b, expected):
        """Parametrized test for addition"""
        result = calculator.add(a, b)
        if isinstance(expected, float):
            assert result == pytest.approx(expected, rel=1e-1)
        else:
            assert result == expected
    
    @pytest.mark.parametrize("operation,a,b,expected", [
        ("add", 2, 3, 5),
        ("subtract", 5, 3, 2),
        ("multiply", 4, 5, 20),
        ("divide", 10, 2, 5),
    ])
    def test_calculator_operations(self, calculator, operation, a, b, expected):
        """Test multiple calculator operations"""
        method = getattr(calculator, operation)
        assert method(a, b) == expected
    
    @pytest.mark.parametrize("amount,expected_balance", [
        (50, 150),
        (25, 125),
        (100, 200),
    ])
    def test_bank_deposit_amounts(self, bank_account, amount, expected_balance):
        """Test different deposit amounts"""
        bank_account.deposit(amount)
        assert bank_account.get_balance() == expected_balance

# Pytest markers
class TestMarkers:
    
    @pytest.mark.slow
    def test_slow_operation(self):
        """Test marked as slow"""
        import time
        time.sleep(0.1)
        assert True
    
    @pytest.mark.integration
    def test_integration_test(self):
        """Integration test marker"""
        assert True
    
    @pytest.mark.skip(reason="Not implemented yet")
    def test_not_implemented(self):
        """Skipped test"""
        assert False
    
    @pytest.mark.skipif(os.name == "nt", reason="Linux only test")
    def test_linux_only(self):
        """Skip on Windows"""
        assert True
    
    @pytest.mark.xfail(reason="Known bug")
    def test_expected_failure(self):
        """Expected to fail"""
        assert 1 == 2
    
    @pytest.mark.xfail(strict=True)
    def test_strict_failure(self):
        """Strict expected failure"""
        assert 1 == 2

# Testing exceptions
class TestExceptions:
    
    def test_value_error_with_message(self, bank_account):
        """Test exception with specific message"""
        with pytest.raises(ValueError, match="Deposit amount must be positive"):
            bank_account.deposit(-10)
    
    def test_exception_info(self, bank_account):
        """Test accessing exception info"""
        with pytest.raises(ValueError) as exc_info:
            bank_account.withdraw(1000)
        
        assert "Insufficient funds" in str(exc_info.value)
    
    def test_no_exception(self, bank_account):
        """Test that no exception is raised"""
        # This should not raise any exception
        balance = bank_account.deposit(50)
        assert balance == 150

# Mocking with pytest
class TestMocking:
    
    @patch('requests.get')
    def test_api_call_mock(self, mock_get):
        """Test API call with mock"""
        # Configure mock
        mock_response = Mock()
        mock_response.status_code = 200
        mock_response.json.return_value = {"id": 1, "name": "test"}
        mock_get.return_value = mock_response
        
        # Function to test
        def fetch_user(user_id):
            response = requests.get(f"https://api.example.com/users/{user_id}")
            if response.status_code == 200:
                return response.json()
            return None
        
        # Test
        result = fetch_user(1)
        assert result == {"id": 1, "name": "test"}
        mock_get.assert_called_once_with("https://api.example.com/users/1")
    
    def test_mock_with_fixture(self, monkeypatch):
        """Test using monkeypatch fixture"""
        def mock_exists(path):
            return path == "/existing/file"
        
        # Patch the function
        monkeypatch.setattr(os.path, "exists", mock_exists)
        
        # Test
        assert os.path.exists("/existing/file") is True
        assert os.path.exists("/nonexistent/file") is False
    
    def test_environment_variables(self, monkeypatch):
        """Test with environment variables"""
        monkeypatch.setenv("TEST_VAR", "test_value")
        
        assert os.environ.get("TEST_VAR") == "test_value"

# Custom fixtures with parameters
@pytest.fixture(params=[0, 100, 1000])
def account_with_balance(request):
    """Parametrized fixture for different account balances"""
    return BankAccount(request.param)

class TestParametrizedFixtures:
    
    def test_account_balance(self, account_with_balance):
        """Test will run with different account balances"""
        initial_balance = account_with_balance.get_balance()
        account_with_balance.deposit(10)
        assert account_with_balance.get_balance() == initial_balance + 10

# Pytest configuration in conftest.py
"""
# conftest.py content (this would be in a separate file)

import pytest
from calculator import Calculator, BankAccount

@pytest.fixture(scope="session")
def shared_calculator():
    return Calculator()

@pytest.fixture(autouse=True)
def reset_environment():
    # This fixture runs automatically before each test
    # Setup code here
    yield
    # Cleanup code here

# Custom markers
def pytest_configure(config):
    config.addinivalue_line("markers", "slow: mark test as slow running")
    config.addinivalue_line("markers", "integration: mark test as integration test")

# Custom command line options
def pytest_addoption(parser):
    parser.addoption(
        "--run-slow", action="store_true", default=False, help="run slow tests"
    )

def pytest_collection_modifyitems(config, items):
    if config.getoption("--run-slow"):
        # Don't skip any tests if --run-slow is given
        return
    skip_slow = pytest.mark.skip(reason="need --run-slow option to run")
    for item in items:
        if "slow" in item.keywords:
            item.add_marker(skip_slow)
"""

# Async testing with pytest
class TestAsync:
    
    @pytest.mark.asyncio
    async def test_async_function(self):
        """Test async function"""
        import asyncio
        
        async def async_add(a, b):
            await asyncio.sleep(0.01)  # Simulate async work
            return a + b
        
        result = await async_add(2, 3)
        assert result == 5

# Property-based testing with hypothesis
try:
    from hypothesis import given, strategies as st
    
    class TestPropertyBased:
        
        @given(st.integers(), st.integers())
        def test_add_commutative(self, a, b):
            """Test that addition is commutative"""
            calc = Calculator()
            assert calc.add(a, b) == calc.add(b, a)
        
        @given(st.integers(), st.integers(), st.integers())
        def test_add_associative(self, a, b, c):
            """Test that addition is associative"""
            calc = Calculator()
            assert calc.add(calc.add(a, b), c) == calc.add(a, calc.add(b, c))
        
        @given(st.floats(allow_nan=False, allow_infinity=False), 
               st.floats(allow_nan=False, allow_infinity=False, min_value=0.01))
        def test_divide_multiply_inverse(self, a, b):
            """Test that division and multiplication are inverse operations"""
            calc = Calculator()
            result = calc.multiply(calc.divide(a, b), b)
            assert result == pytest.approx(a, rel=1e-10)

except ImportError:
    # Hypothesis not installed
    pass

if __name__ == "__main__":
    # Run pytest programmatically
    pytest.main(["-v", __file__])
```

---

## Go Testing

### Go Testing Framework

```go
package main

import (
    "errors"
    "fmt"
    "io"
    "io/ioutil"
    "os"
    "strings"
    "testing"
    "time"
)

// Sample code to test
type Calculator struct{}

func (c *Calculator) Add(a, b int) int {
    return a + b
}

func (c *Calculator) Subtract(a, b int) int {
    return a - b
}

func (c *Calculator) Multiply(a, b int) int {
    return a * b
}

func (c *Calculator) Divide(a, b int) (int, error) {
    if b == 0 {
        return 0, errors.New("division by zero")
    }
    return a / b, nil
}

type BankAccount struct {
    balance int
    history []string
}

func NewBankAccount(initialBalance int) *BankAccount {
    return &BankAccount{
        balance: initialBalance,
        history: make([]string, 0),
    }
}

func (ba *BankAccount) Deposit(amount int) error {
    if amount <= 0 {
        return errors.New("deposit amount must be positive")
    }
    ba.balance += amount
    ba.history = append(ba.history, fmt.Sprintf("Deposited: %d", amount))
    return nil
}

func (ba *BankAccount) Withdraw(amount int) error {
    if amount <= 0 {
        return errors.New("withdrawal amount must be positive")
    }
    if amount > ba.balance {
        return errors.New("insufficient funds")
    }
    ba.balance -= amount
    ba.history = append(ba.history, fmt.Sprintf("Withdrew: %d", amount))
    return nil
}

func (ba *BankAccount) GetBalance() int {
    return ba.balance
}

// Basic Go tests
func TestCalculatorAdd(t *testing.T) {
    calc := &Calculator{}
    
    result := calc.Add(2, 3)
    expected := 5
    
    if result != expected {
        t.Errorf("Add(2, 3) = %d; want %d", result, expected)
    }
}

func TestCalculatorSubtract(t *testing.T) {
    calc := &Calculator{}
    
    tests := []struct {
        name     string
        a, b     int
        expected int
    }{
        {"positive numbers", 5, 3, 2},
        {"negative result", 3, 5, -2},
        {"zero result", 5, 5, 0},
    }
    
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            result := calc.Subtract(tt.a, tt.b)
            if result != tt.expected {
                t.Errorf("Subtract(%d, %d) = %d; want %d", tt.a, tt.b, result, tt.expected)
            }
        })
    }
}

func TestCalculatorDivide(t *testing.T) {
    calc := &Calculator{}
    
    // Test normal division
    result, err := calc.Divide(10, 2)
    if err != nil {
        t.Fatalf("Divide(10, 2) returned unexpected error: %v", err)
    }
    if result != 5 {
        t.Errorf("Divide(10, 2) = %d; want 5", result)
    }
    
    // Test division by zero
    _, err = calc.Divide(10, 0)
    if err == nil {
        t.Error("Divide(10, 0) should return an error")
    }
    
    expectedError := "division by zero"
    if err.Error() != expectedError {
        t.Errorf("Divide(10, 0) error = %q; want %q", err.Error(), expectedError)
    }
}

// Table-driven tests
func TestCalculatorOperations(t *testing.T) {
    calc := &Calculator{}
    
    tests := []struct {
        name      string
        operation string
        a, b      int
        expected  int
        expectErr bool
    }{
        {"add positive", "add", 2, 3, 5, false},
        {"add negative", "add", -1, 1, 0, false},
        {"subtract positive", "subtract", 5, 3, 2, false},
        {"multiply positive", "multiply", 4, 5, 20, false},
        {"multiply by zero", "multiply", 5, 0, 0, false},
        {"divide normal", "divide", 10, 2, 5, false},
        {"divide by zero", "divide", 10, 0, 0, true},
    }
    
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            var result int
            var err error
            
            switch tt.operation {
            case "add":
                result = calc.Add(tt.a, tt.b)
            case "subtract":
                result = calc.Subtract(tt.a, tt.b)
            case "multiply":
                result = calc.Multiply(tt.a, tt.b)
            case "divide":
                result, err = calc.Divide(tt.a, tt.b)
            }
            
            if tt.expectErr {
                if err == nil {
                    t.Errorf("%s(%d, %d) should return an error", tt.operation, tt.a, tt.b)
                }
                return
            }
            
            if err != nil {
                t.Fatalf("%s(%d, %d) returned unexpected error: %v", tt.operation, tt.a, tt.b, err)
            }
            
            if result != tt.expected {
                t.Errorf("%s(%d, %d) = %d; want %d", tt.operation, tt.a, tt.b, result, tt.expected)
            }
        })
    }
}

// Testing with setup and teardown
func TestBankAccount(t *testing.T) {
    // Setup
    account := NewBankAccount(100)
    
    // Test initial balance
    if balance := account.GetBalance(); balance != 100 {
        t.Errorf("Initial balance = %d; want 100", balance)
    }
    
    // Test deposit
    err := account.Deposit(50)
    if err != nil {
        t.Fatalf("Deposit(50) returned error: %v", err)
    }
    
    if balance := account.GetBalance(); balance != 150 {
        t.Errorf("Balance after deposit = %d; want 150", balance)
    }
    
    // Test withdrawal
    err = account.Withdraw(30)
    if err != nil {
        t.Fatalf("Withdraw(30) returned error: %v", err)
    }
    
    if balance := account.GetBalance(); balance != 120 {
        t.Errorf("Balance after withdrawal = %d; want 120", balance)
    }
    
    // Test invalid deposit
    err = account.Deposit(-10)
    if err == nil {
        t.Error("Deposit(-10) should return an error")
    }
    
    // Test insufficient funds
    err = account.Withdraw(200)
    if err == nil {
        t.Error("Withdraw(200) should return an error")
    }
}

// Subtests
func TestBankAccountSubtests(t *testing.T) {
    account := NewBankAccount(100)
    
    t.Run("Deposit", func(t *testing.T) {
        err := account.Deposit(50)
        if err != nil {
            t.Errorf("Deposit(50) returned error: %v", err)
        }
        
        if balance := account.GetBalance(); balance != 150 {
            t.Errorf("Balance = %d; want 150", balance)
        }
    })
    
    t.Run("Withdraw", func(t *testing.T) {
        err := account.Withdraw(30)
        if err != nil {
            t.Errorf("Withdraw(30) returned error: %v", err)
        }
        
        if balance := account.GetBalance(); balance != 120 {
            t.Errorf("Balance = %d; want 120", balance)
        }
    })
    
    t.Run("InvalidOperations", func(t *testing.T) {
        t.Run("NegativeDeposit", func(t *testing.T) {
            err := account.Deposit(-10)
            if err == nil {
                t.Error("Deposit(-10) should return an error")
            }
        })
        
        t.Run("InsufficientFunds", func(t *testing.T) {
            err := account.Withdraw(1000)
            if err == nil {
                t.Error("Withdraw(1000) should return an error")
            }
        })
    })
}

// Benchmark tests
func BenchmarkCalculatorAdd(b *testing.B) {
    calc := &Calculator{}
    
    for i := 0; i < b.N; i++ {
        calc.Add(100, 200)
    }
}

func BenchmarkCalculatorOperations(b *testing.B) {
    calc := &Calculator{}
    
    b.Run("Add", func(b *testing.B) {
        for i := 0; i < b.N; i++ {
            calc.Add(100, 200)
        }
    })
    
    b.Run("Multiply", func(b *testing.B) {
        for i := 0; i < b.N; i++ {
            calc.Multiply(100, 200)
        }
    })
    
    b.Run("Divide", func(b *testing.B) {
        for i := 0; i < b.N; i++ {
            calc.Divide(200, 2)
        }
    })
}

// Memory allocation benchmarks
func BenchmarkStringConcatenation(b *testing.B) {
    b.Run("Plus", func(b *testing.B) {
        for i := 0; i < b.N; i++ {
            result := "hello" + " " + "world"
            _ = result
        }
    })
    
    b.Run("Builder", func(b *testing.B) {
        for i := 0; i < b.N; i++ {
            var builder strings.Builder
            builder.WriteString("hello")
            builder.WriteString(" ")
            builder.WriteString("world")
            result := builder.String()
            _ = result
        }
    })
}

// Example tests (appear in documentation)
func ExampleCalculator_Add() {
    calc := &Calculator{}
    result := calc.Add(2, 3)
    fmt.Println(result)
    // Output: 5
}

func ExampleBankAccount_Deposit() {
    account := NewBankAccount(100)
    err := account.Deposit(50)
    if err != nil {
        fmt.Printf("Error: %v\n", err)
        return
    }
    fmt.Printf("Balance: %d\n", account.GetBalance())
    // Output: Balance: 150
}

// Test helpers
func createTempFile(t *testing.T, content string) string {
    t.Helper() // Mark this as a helper function
    
    tmpfile, err := ioutil.TempFile("", "test")
    if err != nil {
        t.Fatalf("Failed to create temp file: %v", err)
    }
    
    if _, err := tmpfile.Write([]byte(content)); err != nil {
        t.Fatalf("Failed to write to temp file: %v", err)
    }
    
    if err := tmpfile.Close(); err != nil {
        t.Fatalf("Failed to close temp file: %v", err)
    }
    
    return tmpfile.Name()
}

func TestFileOperations(t *testing.T) {
    content := "test content"
    filename := createTempFile(t, content)
    defer os.Remove(filename) // Cleanup
    
    // Test reading the file
    data, err := ioutil.ReadFile(filename)
    if err != nil {
        t.Fatalf("Failed to read file: %v", err)
    }
    
    if string(data) != content {
        t.Errorf("File content = %q; want %q", string(data), content)
    }
}

// Testing with timeouts
func TestWithTimeout(t *testing.T) {
    if testing.Short() {
        t.Skip("Skipping test in short mode")
    }
    
    done := make(chan bool, 1)
    
    go func() {
        time.Sleep(100 * time.Millisecond)
        done <- true
    }()
    
    select {
    case <-done:
        // Test passed
    case <-time.After(200 * time.Millisecond):
        t.Error("Test timed out")
    }
}

// Parallel tests
func TestParallel(t *testing.T) {
    t.Run("Test1", func(t *testing.T) {
        t.Parallel()
        time.Sleep(100 * time.Millisecond)
        // Test logic here
    })
    
    t.Run("Test2", func(t *testing.T) {
        t.Parallel()
        time.Sleep(100 * time.Millisecond)
        // Test logic here
    })
    
    t.Run("Test3", func(t *testing.T) {
        t.Parallel()
        time.Sleep(100 * time.Millisecond)
        // Test logic here
    })
}

// Testing interfaces and mocks
type DataStore interface {
    Get(key string) (string, error)
    Set(key, value string) error
}

type MockDataStore struct {
    data map[string]string
}

func (m *MockDataStore) Get(key string) (string, error) {
    if value, exists := m.data[key]; exists {
        return value, nil
    }
    return "", errors.New("key not found")
}

func (m *MockDataStore) Set(key, value string) error {
    if m.data == nil {
        m.data = make(map[string]string)
    }
    m.data[key] = value
    return nil
}

type UserService struct {
    store DataStore
}

func (us *UserService) GetUser(id string) (string, error) {
    return us.store.Get("user:" + id)
}

func (us *UserService) SaveUser(id, name string) error {
    return us.store.Set("user:"+id, name)
}

func TestUserService(t *testing.T) {
    mockStore := &MockDataStore{}
    userService := &UserService{store: mockStore}
    
    // Test saving user
    err := userService.SaveUser("123", "John Doe")
    if err != nil {
        t.Fatalf("SaveUser returned error: %v", err)
    }
    
    // Test getting user
    name, err := userService.GetUser("123")
    if err != nil {
        t.Fatalf("GetUser returned error: %v", err)
    }
    
    if name != "John Doe" {
        t.Errorf("GetUser returned %q; want %q", name, "John Doe")
    }
    
    // Test getting non-existent user
    _, err = userService.GetUser("999")
    if err == nil {
        t.Error("GetUser should return error for non-existent user")
    }
}

// Running specific tests:
// go test -run TestCalculatorAdd
// go test -run "TestCalculator.*"
// go test -v
// go test -short
// go test -race
// go test -cover
// go test -bench=.
// go test -bench=BenchmarkCalculator -benchmem
```

## How to run these tests:

### Running Python tests:
```bash
# unittest
python -m unittest test_file.py -v

# pytest
pip install pytest pytest-cov pytest-mock hypothesis
pytest test_file.py -v
pytest -k "test_add"  # Run specific tests
pytest --cov=calculator  # Coverage report
pytest -m slow  # Run tests with 'slow' marker
```

### Running Go tests:
```bash
# Basic test run
go test

# Verbose output
go test -v

# Run specific tests
go test -run TestCalculatorAdd

# Run benchmarks
go test -bench=.

# Coverage
go test -cover

# Race detection
go test -race

# Generate coverage HTML report
go test -coverprofile=coverage.out
go tool cover -html=coverage.out
```

---

## Interview Questions and Answers

| # | Difficulty | Question | Answer |
|---|------------|----------|---------|
| 1 | Easy | What is unit testing? | Testing individual components or functions in isolation to verify they work correctly |
| 2 | Easy | What is TDD? | Test-Driven Development - write tests before code, then implement to make tests pass |
| 3 | Easy | What is the AAA pattern? | Arrange (setup), Act (execute), Assert (verify) - structure for test methods |
| 4 | Easy | What is a test fixture? | Fixed state or context used as baseline for running tests |
| 5 | Easy | What is assertion? | Statement that checks if expected condition is true during test execution |
| 6 | Easy | What is test coverage? | Percentage of code executed during testing - statement, branch, path coverage |
| 7 | Easy | What is a mock object? | Fake object that simulates behavior of real object for testing purposes |
| 8 | Easy | What is test isolation? | Tests should be independent and not affect each other's execution |
| 9 | Easy | What is setUp and tearDown? | Methods run before and after each test to prepare and clean up test environment |
| 10 | Easy | What is parametrized testing? | Running same test with different input values using test parameters |
| 11 | Easy | What is pytest? | Popular Python testing framework with simple syntax and powerful features |
| 12 | Easy | What are pytest fixtures? | Reusable setup code that provides data or objects to tests |
| 13 | Easy | What is test discovery? | Automatic finding and running of tests based on naming conventions |
| 14 | Easy | What is unittest module? | Built-in Python testing framework based on xUnit architecture |
| 15 | Easy | What is Go testing package? | Built-in Go testing framework for writing unit and benchmark tests |
| 16 | Medium | Difference between mock and stub? | Mock verifies interactions, stub provides predefined responses |
| 17 | Medium | What is monkey patching in testing? | Dynamically modifying classes or functions at runtime for testing |
| 18 | Medium | What is pytest.mark? | Decorator for marking tests with metadata like skip, parametrize, slow |
| 19 | Medium | What is conftest.py? | Configuration file for sharing fixtures and settings across test modules |
| 20 | Medium | What is test doubles? | Generic term for mock, stub, spy, fake, dummy objects |
| 21 | Medium | What is integration testing? | Testing interaction between multiple components or services |
| 22 | Medium | What is end-to-end testing? | Testing complete user workflows from start to finish |
| 23 | Medium | What is contract testing? | Verifying that APIs meet expected contracts between services |
| 24 | Medium | What is property-based testing? | Testing with automatically generated inputs to find edge cases |
| 25 | Medium | What is mutation testing? | Introducing bugs to test if tests catch them, measuring test quality |
| 26 | Medium | What is test pyramid? | Strategy with many unit tests, fewer integration tests, few E2E tests |
| 27 | Medium | What is dependency injection for testing? | Providing dependencies externally to make testing easier |
| 28 | Medium | What is database testing? | Testing database operations with test databases or in-memory databases |
| 29 | Medium | What is async testing? | Testing asynchronous code using async/await patterns |
| 30 | Medium | What is table-driven tests in Go? | Testing pattern using slice of test cases with inputs and expected outputs |
| 31 | Hard | How to test private methods? | Generally avoid - test public interface or extract to separate testable unit |
| 32 | Hard | What is test smell? | Poorly written tests that are hard to maintain - long tests, unclear assertions |
| 33 | Hard | How to test error conditions? | Use pytest.raises(), unittest.assertRaises(), or Go's error returns |
| 34 | Hard | What is flaky test? | Test that sometimes passes and sometimes fails without code changes |
| 35 | Hard | How to handle test data? | Use factories, builders, fixtures, or test data files |
| 36 | Hard | What is hermetic testing? | Tests that are completely isolated from external dependencies |
| 37 | Hard | How to test multi-threaded code? | Use synchronization, deterministic scheduling, or testing frameworks |
| 38 | Hard | What is snapshot testing? | Comparing current output with previously approved output |
| 39 | Hard | How to test file operations? | Use temporary files, mock file system, or in-memory file systems |
| 40 | Hard | What is performance testing? | Measuring execution time, memory usage, and resource consumption |
| 41 | Hard | How to test network calls? | Mock HTTP clients, use test servers, or record/replay patterns |
| 42 | Hard | What is test containerization? | Running tests in isolated containers for consistent environments |
| 43 | Hard | How to test configuration? | Use test configs, environment variables, or config injection |
| 44 | Hard | What is chaos testing? | Intentionally introducing failures to test system resilience |
| 45 | Hard | How to test time-dependent code? | Mock time, use fixed timestamps, or time travel techniques |
| 46 | Expert | What is approval testing? | Testing by comparing output with approved reference files |
| 47 | Expert | How to test legacy code? | Add characterization tests, use seams, gradually refactor |
| 48 | Expert | What is test-induced design damage? | When tests force poor design decisions in production code |
| 49 | Expert | How to test machine learning models? | Test data preprocessing, model outputs, statistical properties |
| 50 | Expert | What is metamorphic testing? | Testing by verifying relationships between inputs and outputs |
| 51 | Expert | How to test distributed systems? | Use test doubles, local clusters, or distributed testing frameworks |
| 52 | Expert | What is generative testing? | Automatically generating test cases based on specifications |
| 53 | Expert | How to test microservices? | Consumer-driven contracts, service virtualization, testing pyramids |
| 54 | Expert | What is A/B testing framework? | Infrastructure for comparing different versions or features |
| 55 | Expert | How to test security vulnerabilities? | Penetration testing, fuzzing, static analysis, dependency scanning |
