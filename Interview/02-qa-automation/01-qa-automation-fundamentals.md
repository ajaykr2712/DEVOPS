# QA Automation Fundamentals

## Table of Contents
1. [Pytest Framework](#pytest-framework)
2. [Page Object Model (POM)](#page-object-model-pom)
3. [Modular Test Frameworks](#modular-test-frameworks)
4. [UI Testing with Selenium](#ui-testing-with-selenium)
5. [API Testing](#api-testing)
6. [Test Parameterization](#test-parameterization)
7. [Fixtures and Test Data Management](#fixtures-and-test-data-management)
8. [Test Reporting](#test-reporting)
9. [Mocking and Test Doubles](#mocking-and-test-doubles)
10. [Code Coverage](#code-coverage)
11. [Handling Flaky Tests](#handling-flaky-tests)
12. [QA Metrics and KPIs](#qa-metrics-and-kpis)
13. [Interview Questions](#interview-questions)

## Pytest Framework

### Basic Pytest Setup

```python
# conftest.py - Global configuration
import pytest
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
import requests

@pytest.fixture(scope="session")
def driver():
    """Setup Chrome driver for UI tests"""
    options = Options()
    options.add_argument("--headless")
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    
    driver = webdriver.Chrome(options=options)
    driver.implicitly_wait(10)
    yield driver
    driver.quit()

@pytest.fixture(scope="session")
def api_client():
    """Setup API client"""
    session = requests.Session()
    session.headers.update({'Content-Type': 'application/json'})
    yield session
    session.close()

# Pytest markers
pytestmark = [
    pytest.mark.automation,
    pytest.mark.regression
]
```

### Advanced Pytest Features

```python
# test_advanced_pytest.py
import pytest
import allure
from datetime import datetime

class TestAdvancedFeatures:
    
    @pytest.mark.parametrize("username,password,expected", [
        ("valid_user", "valid_pass", True),
        ("invalid_user", "valid_pass", False),
        ("valid_user", "invalid_pass", False),
        ("", "", False)
    ])
    def test_login_scenarios(self, username, password, expected):
        """Test multiple login scenarios"""
        result = authenticate_user(username, password)
        assert result == expected
    
    @pytest.mark.slow
    @pytest.mark.integration
    def test_database_integration(self, db_connection):
        """Test database operations"""
        user_id = db_connection.create_user("test@example.com")
        assert user_id is not None
        
        user = db_connection.get_user(user_id)
        assert user.email == "test@example.com"
    
    @allure.step("Perform user registration")
    def test_user_registration_flow(self, api_client):
        """Complete user registration flow with allure reporting"""
        
        # Step 1: Register user
        registration_data = {
            "username": f"testuser_{datetime.now().timestamp()}",
            "email": "test@example.com",
            "password": "SecurePass123!"
        }
        
        response = api_client.post("/api/register", json=registration_data)
        assert response.status_code == 201
        
        # Step 2: Verify email sent
        user_id = response.json()["user_id"]
        verification_response = api_client.get(f"/api/users/{user_id}/verification-status")
        assert verification_response.json()["email_sent"] is True
    
    @pytest.mark.xfail(reason="Known issue with third-party service")
    def test_external_service_integration(self):
        """Test that might fail due to external dependencies"""
        pass
    
    def test_with_custom_timeout(self):
        """Test with custom timeout handling"""
        with pytest.timeout(30):
            # Long running operation
            result = perform_heavy_computation()
            assert result is not None
```

## Page Object Model (POM)

### Base Page Class

```python
# pages/base_page.py
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By
from selenium.common.exceptions import TimeoutException
import logging

class BasePage:
    def __init__(self, driver):
        self.driver = driver
        self.wait = WebDriverWait(driver, 10)
        self.logger = logging.getLogger(__name__)
    
    def find_element(self, locator, timeout=10):
        """Find element with explicit wait"""
        try:
            element = WebDriverWait(self.driver, timeout).until(
                EC.presence_of_element_located(locator)
            )
            return element
        except TimeoutException:
            self.logger.error(f"Element not found: {locator}")
            raise
    
    def click_element(self, locator):
        """Click element when clickable"""
        element = self.wait.until(EC.element_to_be_clickable(locator))
        element.click()
        self.logger.info(f"Clicked element: {locator}")
    
    def enter_text(self, locator, text):
        """Enter text into input field"""
        element = self.find_element(locator)
        element.clear()
        element.send_keys(text)
        self.logger.info(f"Entered text '{text}' into {locator}")
    
    def get_text(self, locator):
        """Get text from element"""
        element = self.find_element(locator)
        return element.text
    
    def is_element_present(self, locator, timeout=5):
        """Check if element is present"""
        try:
            self.find_element(locator, timeout)
            return True
        except TimeoutException:
            return False
    
    def wait_for_page_load(self):
        """Wait for page to load completely"""
        self.wait.until(
            lambda driver: driver.execute_script("return document.readyState") == "complete"
        )
```

### Specific Page Classes

```python
# pages/login_page.py
from pages.base_page import BasePage
from selenium.webdriver.common.by import By

class LoginPage(BasePage):
    # Locators
    USERNAME_INPUT = (By.ID, "username")
    PASSWORD_INPUT = (By.ID, "password")
    LOGIN_BUTTON = (By.XPATH, "//button[@type='submit']")
    ERROR_MESSAGE = (By.CLASS_NAME, "error-message")
    FORGOT_PASSWORD_LINK = (By.LINK_TEXT, "Forgot Password?")
    
    def __init__(self, driver):
        super().__init__(driver)
        self.url = "https://example.com/login"
    
    def navigate_to_login(self):
        """Navigate to login page"""
        self.driver.get(self.url)
        self.wait_for_page_load()
        return self
    
    def login(self, username, password):
        """Perform login action"""
        self.enter_text(self.USERNAME_INPUT, username)
        self.enter_text(self.PASSWORD_INPUT, password)
        self.click_element(self.LOGIN_BUTTON)
        return self
    
    def get_error_message(self):
        """Get error message text"""
        if self.is_element_present(self.ERROR_MESSAGE):
            return self.get_text(self.ERROR_MESSAGE)
        return None
    
    def click_forgot_password(self):
        """Click forgot password link"""
        self.click_element(self.FORGOT_PASSWORD_LINK)
        from pages.forgot_password_page import ForgotPasswordPage
        return ForgotPasswordPage(self.driver)

# pages/dashboard_page.py
class DashboardPage(BasePage):
    # Locators
    USER_PROFILE = (By.CLASS_NAME, "user-profile")
    LOGOUT_BUTTON = (By.ID, "logout")
    NAVIGATION_MENU = (By.CLASS_NAME, "nav-menu")
    
    def is_logged_in(self):
        """Check if user is logged in"""
        return self.is_element_present(self.USER_PROFILE)
    
    def logout(self):
        """Perform logout"""
        self.click_element(self.LOGOUT_BUTTON)
        from pages.login_page import LoginPage
        return LoginPage(self.driver)
```

## Modular Test Frameworks

### Framework Structure

```python
# framework/test_runner.py
import pytest
import sys
import os
from framework.config_manager import ConfigManager
from framework.report_generator import ReportGenerator
from framework.test_data_manager import TestDataManager

class TestRunner:
    def __init__(self):
        self.config = ConfigManager()
        self.report_generator = ReportGenerator()
        self.test_data = TestDataManager()
    
    def run_tests(self, test_suite=None, environment="staging"):
        """Run test suite with configuration"""
        
        # Set environment
        self.config.set_environment(environment)
        
        # Prepare test data
        self.test_data.setup_test_data(environment)
        
        # Configure pytest arguments
        pytest_args = [
            "-v",
            "--tb=short",
            f"--html=reports/report_{environment}.html",
            "--self-contained-html",
            "--junitxml=reports/junit.xml"
        ]
        
        if test_suite:
            pytest_args.extend(["-k", test_suite])
        
        # Run tests
        exit_code = pytest.main(pytest_args)
        
        # Generate reports
        self.report_generator.generate_summary_report()
        
        return exit_code

# framework/config_manager.py
import json
import os
from typing import Dict, Any

class ConfigManager:
    def __init__(self):
        self.config_file = "config/test_config.json"
        self.config = self._load_config()
        self.current_env = "staging"
    
    def _load_config(self) -> Dict[str, Any]:
        """Load configuration from file"""
        try:
            with open(self.config_file, 'r') as f:
                return json.load(f)
        except FileNotFoundError:
            return self._default_config()
    
    def _default_config(self) -> Dict[str, Any]:
        """Default configuration"""
        return {
            "environments": {
                "staging": {
                    "base_url": "https://staging.example.com",
                    "api_url": "https://api-staging.example.com",
                    "database_url": "staging-db.example.com",
                    "timeout": 30
                },
                "production": {
                    "base_url": "https://example.com",
                    "api_url": "https://api.example.com",
                    "database_url": "prod-db.example.com",
                    "timeout": 10
                }
            },
            "test_settings": {
                "parallel_execution": True,
                "retry_count": 2,
                "screenshot_on_failure": True
            }
        }
    
    def get_config(self, key: str) -> Any:
        """Get configuration value"""
        env_config = self.config["environments"][self.current_env]
        return env_config.get(key) or self.config["test_settings"].get(key)
    
    def set_environment(self, environment: str):
        """Set current environment"""
        if environment in self.config["environments"]:
            self.current_env = environment
        else:
            raise ValueError(f"Environment {environment} not found in config")
```

## UI Testing with Selenium

### Advanced Selenium Patterns

```python
# tests/ui/test_e2e_user_journey.py
import pytest
import allure
from pages.login_page import LoginPage
from pages.dashboard_page import DashboardPage
from pages.profile_page import ProfilePage
from framework.test_data_manager import TestDataManager

class TestUserJourney:
    
    @allure.feature("User Authentication")
    @allure.story("Complete User Journey")
    def test_complete_user_workflow(self, driver):
        """Test complete user workflow from login to profile update"""
        
        test_data = TestDataManager.get_user_data("valid_user")
        
        # Step 1: Login
        login_page = LoginPage(driver)
        dashboard_page = login_page.navigate_to_login().login(
            test_data["username"], 
            test_data["password"]
        )
        
        # Verify login successful
        assert dashboard_page.is_logged_in()
        
        # Step 2: Navigate to profile
        profile_page = dashboard_page.navigate_to_profile()
        
        # Step 3: Update profile
        updated_data = {
            "first_name": "Updated",
            "last_name": "Name",
            "email": "updated@example.com"
        }
        
        profile_page.update_profile(updated_data)
        
        # Step 4: Verify update
        assert profile_page.get_success_message() == "Profile updated successfully"
        
        # Step 5: Logout
        login_page = dashboard_page.logout()
        assert not dashboard_page.is_logged_in()

# utils/selenium_helpers.py
from selenium.webdriver.support.ui import Select
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.common.keys import Keys
import time

class SeleniumHelpers:
    
    @staticmethod
    def select_dropdown_by_text(driver, locator, text):
        """Select dropdown option by visible text"""
        dropdown = Select(driver.find_element(*locator))
        dropdown.select_by_visible_text(text)
    
    @staticmethod
    def hover_over_element(driver, locator):
        """Hover over element"""
        element = driver.find_element(*locator)
        ActionChains(driver).move_to_element(element).perform()
    
    @staticmethod
    def drag_and_drop(driver, source_locator, target_locator):
        """Drag and drop element"""
        source = driver.find_element(*source_locator)
        target = driver.find_element(*target_locator)
        ActionChains(driver).drag_and_drop(source, target).perform()
    
    @staticmethod
    def scroll_to_element(driver, locator):
        """Scroll to element"""
        element = driver.find_element(*locator)
        driver.execute_script("arguments[0].scrollIntoView();", element)
    
    @staticmethod
    def wait_for_ajax_complete(driver, timeout=30):
        """Wait for AJAX requests to complete"""
        wait_time = 0
        while wait_time < timeout:
            ajax_complete = driver.execute_script(
                "return jQuery.active == 0" if "jQuery" in driver.execute_script("return typeof jQuery") 
                else "return true"
            )
            if ajax_complete:
                break
            time.sleep(0.5)
            wait_time += 0.5
```

## API Testing

### Comprehensive API Testing Framework

```python
# api/base_api_client.py
import requests
import json
import logging
from typing import Dict, Any, Optional

class BaseAPIClient:
    def __init__(self, base_url: str, headers: Optional[Dict] = None):
        self.base_url = base_url.rstrip('/')
        self.session = requests.Session()
        self.session.headers.update(headers or {})
        self.logger = logging.getLogger(__name__)
    
    def _make_request(self, method: str, endpoint: str, **kwargs) -> requests.Response:
        """Make HTTP request with logging"""
        url = f"{self.base_url}/{endpoint.lstrip('/')}"
        
        self.logger.info(f"{method.upper()} {url}")
        if 'json' in kwargs:
            self.logger.info(f"Request body: {json.dumps(kwargs['json'], indent=2)}")
        
        response = self.session.request(method, url, **kwargs)
        
        self.logger.info(f"Response status: {response.status_code}")
        self.logger.info(f"Response body: {response.text}")
        
        return response
    
    def get(self, endpoint: str, **kwargs) -> requests.Response:
        return self._make_request('GET', endpoint, **kwargs)
    
    def post(self, endpoint: str, **kwargs) -> requests.Response:
        return self._make_request('POST', endpoint, **kwargs)
    
    def put(self, endpoint: str, **kwargs) -> requests.Response:
        return self._make_request('PUT', endpoint, **kwargs)
    
    def delete(self, endpoint: str, **kwargs) -> requests.Response:
        return self._make_request('DELETE', endpoint, **kwargs)
    
    def authenticate(self, username: str, password: str) -> str:
        """Authenticate and return token"""
        auth_data = {"username": username, "password": password}
        response = self.post("/auth/login", json=auth_data)
        
        if response.status_code == 200:
            token = response.json().get("access_token")
            self.session.headers.update({"Authorization": f"Bearer {token}"})
            return token
        else:
            raise Exception(f"Authentication failed: {response.text}")

# tests/api/test_user_api.py
import pytest
import jsonschema
from api.base_api_client import BaseAPIClient

class TestUserAPI:
    
    @pytest.fixture(autouse=True)
    def setup(self, api_client):
        self.client = api_client
        # Authenticate for all tests
        self.client.authenticate("test_user", "test_password")
    
    def test_create_user_success(self):
        """Test successful user creation"""
        user_data = {
            "username": "newuser",
            "email": "newuser@example.com",
            "password": "SecurePass123!",
            "first_name": "New",
            "last_name": "User"
        }
        
        response = self.client.post("/api/users", json=user_data)
        
        assert response.status_code == 201
        
        response_data = response.json()
        assert response_data["username"] == user_data["username"]
        assert response_data["email"] == user_data["email"]
        assert "id" in response_data
        assert "password" not in response_data  # Password should not be returned
        
        # Validate response schema
        user_schema = {
            "type": "object",
            "properties": {
                "id": {"type": "integer"},
                "username": {"type": "string"},
                "email": {"type": "string", "format": "email"},
                "first_name": {"type": "string"},
                "last_name": {"type": "string"},
                "created_at": {"type": "string"}
            },
            "required": ["id", "username", "email", "created_at"]
        }
        
        jsonschema.validate(response_data, user_schema)
    
    @pytest.mark.parametrize("invalid_data,expected_error", [
        ({"username": "", "email": "test@example.com"}, "Username is required"),
        ({"username": "test", "email": "invalid-email"}, "Invalid email format"),
        ({"username": "test", "email": "test@example.com", "password": "123"}, "Password too weak")
    ])
    def test_create_user_validation_errors(self, invalid_data, expected_error):
        """Test user creation validation"""
        response = self.client.post("/api/users", json=invalid_data)
        
        assert response.status_code == 400
        assert expected_error in response.json()["message"]
    
    def test_get_user_by_id(self):
        """Test retrieving user by ID"""
        # First create a user
        user_data = {"username": "getuser", "email": "getuser@example.com", "password": "Pass123!"}
        create_response = self.client.post("/api/users", json=user_data)
        user_id = create_response.json()["id"]
        
        # Then retrieve it
        response = self.client.get(f"/api/users/{user_id}")
        
        assert response.status_code == 200
        response_data = response.json()
        assert response_data["id"] == user_id
        assert response_data["username"] == user_data["username"]
    
    def test_update_user(self):
        """Test user update"""
        # Create user
        user_data = {"username": "updateuser", "email": "updateuser@example.com", "password": "Pass123!"}
        create_response = self.client.post("/api/users", json=user_data)
        user_id = create_response.json()["id"]
        
        # Update user
        update_data = {"first_name": "Updated", "last_name": "Name"}
        response = self.client.put(f"/api/users/{user_id}", json=update_data)
        
        assert response.status_code == 200
        response_data = response.json()
        assert response_data["first_name"] == "Updated"
        assert response_data["last_name"] == "Name"
    
    def test_delete_user(self):
        """Test user deletion"""
        # Create user
        user_data = {"username": "deleteuser", "email": "deleteuser@example.com", "password": "Pass123!"}
        create_response = self.client.post("/api/users", json=user_data)
        user_id = create_response.json()["id"]
        
        # Delete user
        response = self.client.delete(f"/api/users/{user_id}")
        assert response.status_code == 204
        
        # Verify user is deleted
        get_response = self.client.get(f"/api/users/{user_id}")
        assert get_response.status_code == 404
```

## Test Parameterization

### Advanced Parameterization Techniques

```python
# tests/test_parameterization.py
import pytest
import json
from datetime import datetime, timedelta

class TestParameterization:
    
    # Simple parameterization
    @pytest.mark.parametrize("input_value,expected", [
        (5, 25),
        (0, 0),
        (-3, 9),
        (10, 100)
    ])
    def test_square_function(self, input_value, expected):
        """Test square function with multiple inputs"""
        assert square(input_value) == expected
    
    # Multiple parameter combinations
    @pytest.mark.parametrize("username", ["user1", "user2", "admin"])
    @pytest.mark.parametrize("environment", ["staging", "production"])
    def test_user_access_combinations(self, username, environment):
        """Test user access across different environments"""
        access_granted = check_user_access(username, environment)
        assert isinstance(access_granted, bool)
    
    # Using pytest.param for custom test IDs and marks
    @pytest.mark.parametrize("test_data", [
        pytest.param(
            {"username": "valid_user", "password": "valid_pass"}, 
            id="valid_credentials"
        ),
        pytest.param(
            {"username": "invalid_user", "password": "valid_pass"}, 
            marks=pytest.mark.xfail, 
            id="invalid_username"
        ),
        pytest.param(
            {"username": "valid_user", "password": "invalid_pass"}, 
            marks=pytest.mark.slow, 
            id="invalid_password"
        )
    ])
    def test_login_scenarios_advanced(self, test_data):
        """Advanced login testing with custom marks"""
        result = authenticate(**test_data)
        assert result is True  # Will fail for xfail cases
    
    # Loading test data from external files
    @pytest.mark.parametrize("test_case", load_test_data_from_json("test_data/user_scenarios.json"))
    def test_user_scenarios_from_file(self, test_case):
        """Test user scenarios loaded from JSON file"""
        user_service = UserService()
        result = user_service.process_user(test_case["input"])
        assert result == test_case["expected_output"]
    
    # Dynamic parameterization
    def generate_date_range():
        """Generate test dates for the last 7 days"""
        base_date = datetime.now()
        return [(base_date - timedelta(days=i)).strftime("%Y-%m-%d") for i in range(7)]
    
    @pytest.mark.parametrize("test_date", generate_date_range())
    def test_daily_reports(self, test_date):
        """Test report generation for multiple dates"""
        report = generate_daily_report(test_date)
        assert report is not None
        assert report.date == test_date

# Helper function for loading test data
def load_test_data_from_json(file_path):
    """Load test data from JSON file"""
    try:
        with open(file_path, 'r') as f:
            data = json.load(f)
            return data.get("test_cases", [])
    except FileNotFoundError:
        return []

# test_data/user_scenarios.json
"""
{
    "test_cases": [
        {
            "name": "Create admin user",
            "input": {
                "username": "admin",
                "role": "administrator",
                "permissions": ["read", "write", "delete"]
            },
            "expected_output": {
                "status": "created",
                "user_id": "admin_id",
                "role": "administrator"
            }
        },
        {
            "name": "Create regular user",
            "input": {
                "username": "regular_user",
                "role": "user",
                "permissions": ["read"]
            },
            "expected_output": {
                "status": "created",
                "user_id": "user_id",
                "role": "user"
            }
        }
    ]
}
"""
```

## Fixtures and Test Data Management

### Advanced Fixture Patterns

```python
# conftest.py - Advanced fixtures
import pytest
import tempfile
import shutil
import sqlite3
from pathlib import Path

@pytest.fixture(scope="session")
def test_database():
    """Create test database for the session"""
    # Create temporary database
    db_file = tempfile.mktemp(suffix=".db")
    
    # Initialize database
    conn = sqlite3.connect(db_file)
    cursor = conn.cursor()
    
    # Create tables
    cursor.execute("""
        CREATE TABLE users (
            id INTEGER PRIMARY KEY,
            username TEXT UNIQUE,
            email TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    """)
    
    cursor.execute("""
        CREATE TABLE posts (
            id INTEGER PRIMARY KEY,
            user_id INTEGER,
            title TEXT,
            content TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users (id)
        )
    """)
    
    conn.commit()
    
    yield {
        "connection": conn,
        "file_path": db_file
    }
    
    # Cleanup
    conn.close()
    Path(db_file).unlink(missing_ok=True)

@pytest.fixture
def clean_database(test_database):
    """Clean database between tests"""
    conn = test_database["connection"]
    cursor = conn.cursor()
    
    # Clean tables
    cursor.execute("DELETE FROM posts")
    cursor.execute("DELETE FROM users")
    conn.commit()
    
    yield test_database

@pytest.fixture
def sample_users(clean_database):
    """Create sample users for testing"""
    conn = clean_database["connection"]
    cursor = conn.cursor()
    
    users_data = [
        ("john_doe", "john@example.com"),
        ("jane_smith", "jane@example.com"),
        ("admin_user", "admin@example.com")
    ]
    
    cursor.executemany(
        "INSERT INTO users (username, email) VALUES (?, ?)",
        users_data
    )
    conn.commit()
    
    # Return user IDs
    cursor.execute("SELECT id, username FROM users")
    return dict(cursor.fetchall())

@pytest.fixture
def temp_directory():
    """Create temporary directory for file operations"""
    temp_dir = tempfile.mkdtemp()
    yield Path(temp_dir)
    shutil.rmtree(temp_dir)

@pytest.fixture(params=["small", "medium", "large"])
def test_file_sizes(request, temp_directory):
    """Generate test files of different sizes"""
    size_mapping = {
        "small": 1024,      # 1KB
        "medium": 1024**2,  # 1MB
        "large": 10 * 1024**2  # 10MB
    }
    
    size = size_mapping[request.param]
    test_file = temp_directory / f"test_file_{request.param}.txt"
    
    # Create file with specified size
    with open(test_file, 'w') as f:
        f.write('x' * size)
    
    return {
        "file_path": test_file,
        "size": size,
        "size_category": request.param
    }

# Test data factories
class TestDataFactory:
    @staticmethod
    def create_user_data(**overrides):
        """Create user data with optional overrides"""
        default_data = {
            "username": f"testuser_{datetime.now().timestamp()}",
            "email": "test@example.com",
            "first_name": "Test",
            "last_name": "User",
            "password": "SecurePass123!"
        }
        default_data.update(overrides)
        return default_data
    
    @staticmethod
    def create_post_data(user_id, **overrides):
        """Create post data"""
        default_data = {
            "user_id": user_id,
            "title": "Test Post",
            "content": "This is a test post content.",
            "tags": ["test", "automation"]
        }
        default_data.update(overrides)
        return default_data
```

## Test Reporting

### Comprehensive Test Reporting

```python
# framework/report_generator.py
import json
import xml.etree.ElementTree as ET
from datetime import datetime
import matplotlib.pyplot as plt
import pandas as pd

class ReportGenerator:
    def __init__(self):
        self.test_results = []
        self.metrics = {}
    
    def add_test_result(self, test_name, status, duration, error_message=None):
        """Add test result to collection"""
        self.test_results.append({
            "test_name": test_name,
            "status": status,
            "duration": duration,
            "timestamp": datetime.now(),
            "error_message": error_message
        })
    
    def generate_html_report(self, output_file="reports/test_report.html"):
        """Generate detailed HTML report"""
        total_tests = len(self.test_results)
        passed_tests = len([r for r in self.test_results if r["status"] == "passed"])
        failed_tests = len([r for r in self.test_results if r["status"] == "failed"])
        skipped_tests = len([r for r in self.test_results if r["status"] == "skipped"])
        
        pass_rate = (passed_tests / total_tests * 100) if total_tests > 0 else 0
        
        html_template = f"""
        <!DOCTYPE html>
        <html>
        <head>
            <title>Test Execution Report</title>
            <style>
                body {{ font-family: Arial, sans-serif; margin: 20px; }}
                .summary {{ background-color: #f0f0f0; padding: 15px; border-radius: 5px; }}
                .passed {{ color: green; }}
                .failed {{ color: red; }}
                .skipped {{ color: orange; }}
                table {{ border-collapse: collapse; width: 100%; margin-top: 20px; }}
                th, td {{ border: 1px solid #ddd; padding: 8px; text-align: left; }}
                th {{ background-color: #f2f2f2; }}
                .error-details {{ font-size: 0.8em; color: #666; }}
            </style>
        </head>
        <body>
            <h1>Test Execution Report</h1>
            <div class="summary">
                <h2>Summary</h2>
                <p><strong>Total Tests:</strong> {total_tests}</p>
                <p><strong>Passed:</strong> <span class="passed">{passed_tests}</span></p>
                <p><strong>Failed:</strong> <span class="failed">{failed_tests}</span></p>
                <p><strong>Skipped:</strong> <span class="skipped">{skipped_tests}</span></p>
                <p><strong>Pass Rate:</strong> {pass_rate:.2f}%</p>
                <p><strong>Generated:</strong> {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}</p>
            </div>
            
            <h2>Test Results</h2>
            <table>
                <thead>
                    <tr>
                        <th>Test Name</th>
                        <th>Status</th>
                        <th>Duration (s)</th>
                        <th>Timestamp</th>
                        <th>Error Message</th>
                    </tr>
                </thead>
                <tbody>
        """
        
        for result in self.test_results:
            status_class = result["status"]
            error_msg = result["error_message"] or ""
            
            html_template += f"""
                    <tr>
                        <td>{result["test_name"]}</td>
                        <td class="{status_class}">{result["status"].upper()}</td>
                        <td>{result["duration"]:.2f}</td>
                        <td>{result["timestamp"].strftime('%H:%M:%S')}</td>
                        <td class="error-details">{error_msg}</td>
                    </tr>
            """
        
        html_template += """
                </tbody>
            </table>
        </body>
        </html>
        """
        
        with open(output_file, 'w') as f:
            f.write(html_template)
        
        return output_file
    
    def generate_metrics_dashboard(self):
        """Generate test metrics visualization"""
        if not self.test_results:
            return
        
        # Create DataFrame
        df = pd.DataFrame(self.test_results)
        
        # Create visualizations
        fig, ((ax1, ax2), (ax3, ax4)) = plt.subplots(2, 2, figsize=(15, 10))
        
        # Test status distribution
        status_counts = df['status'].value_counts()
        ax1.pie(status_counts.values, labels=status_counts.index, autopct='%1.1f%%')
        ax1.set_title('Test Status Distribution')
        
        # Test duration histogram
        ax2.hist(df['duration'], bins=20, edgecolor='black')
        ax2.set_title('Test Duration Distribution')
        ax2.set_xlabel('Duration (seconds)')
        ax2.set_ylabel('Number of Tests')
        
        # Pass rate over time
        df['hour'] = df['timestamp'].dt.hour
        hourly_stats = df.groupby('hour')['status'].apply(
            lambda x: (x == 'passed').sum() / len(x) * 100
        )
        ax3.plot(hourly_stats.index, hourly_stats.values, marker='o')
        ax3.set_title('Pass Rate by Hour')
        ax3.set_xlabel('Hour of Day')
        ax3.set_ylabel('Pass Rate (%)')
        
        # Test categories performance
        # Extract test categories from test names
        df['category'] = df['test_name'].str.extract(r'test_(\w+)_')[0].fillna('other')
        category_stats = df.groupby('category')['status'].apply(
            lambda x: (x == 'passed').sum() / len(x) * 100
        )
        ax4.bar(category_stats.index, category_stats.values)
        ax4.set_title('Pass Rate by Test Category')
        ax4.set_xlabel('Test Category')
        ax4.set_ylabel('Pass Rate (%)')
        ax4.tick_params(axis='x', rotation=45)
        
        plt.tight_layout()
        plt.savefig('reports/test_metrics_dashboard.png', dpi=300, bbox_inches='tight')
        plt.close()

# Allure reporting integration
import allure

class AllureReporting:
    @staticmethod
    def attach_screenshot(driver, name="Screenshot"):
        """Attach screenshot to Allure report"""
        screenshot = driver.get_screenshot_as_png()
        allure.attach(screenshot, name=name, attachment_type=allure.attachment_type.PNG)
    
    @staticmethod
    def attach_logs(log_content, name="Logs"):
        """Attach logs to Allure report"""
        allure.attach(log_content, name=name, attachment_type=allure.attachment_type.TEXT)
    
    @staticmethod
    def attach_api_request_response(request_data, response_data):
        """Attach API request/response to Allure report"""
        allure.attach(
            json.dumps(request_data, indent=2),
            name="API Request",
            attachment_type=allure.attachment_type.JSON
        )
        allure.attach(
            json.dumps(response_data, indent=2),
            name="API Response",
            attachment_type=allure.attachment_type.JSON
        )
```

## Interview Questions

### Common QA Automation Interview Questions

**Q1: What's the difference between unit, integration, and end-to-end testing?**

**Answer:**
- **Unit Testing:** Tests individual components/functions in isolation. Fast, focused on single functionality.
- **Integration Testing:** Tests interaction between integrated components. Verifies interfaces and data flow.
- **End-to-End Testing:** Tests complete user workflows. Slow but provides highest confidence.

**Q2: How do you handle flaky tests?**

**Answer:**
```python
# Strategies for handling flaky tests:

# 1. Retry mechanism
@pytest.mark.flaky(reruns=3, reruns_delay=2)
def test_flaky_operation():
    pass

# 2. Better waits
def wait_for_element_stable(driver, locator, timeout=10):
    """Wait for element to be stable (not changing)"""
    element = WebDriverWait(driver, timeout).until(
        EC.presence_of_element_located(locator)
    )
    # Wait for element to stop moving/changing
    previous_location = None
    for _ in range(5):
        current_location = element.location
        if previous_location == current_location:
            break
        previous_location = current_location
        time.sleep(0.2)
    return element

# 3. Environment isolation
@pytest.fixture
def isolated_test_data():
    """Create isolated test data"""
    unique_id = str(uuid.uuid4())
    data = create_test_data(unique_id)
    yield data
    cleanup_test_data(unique_id)
```

**Q3: How do you implement Page Object Model effectively?**

**Answer:**
```python
# Best practices for POM:

# 1. Separate locators from actions
class LoginPageLocators:
    USERNAME = (By.ID, "username")
    PASSWORD = (By.ID, "password")
    LOGIN_BTN = (By.XPATH, "//button[@type='submit']")

class LoginPage(BasePage):
    def __init__(self, driver):
        super().__init__(driver)
        self.locators = LoginPageLocators()
    
    def login(self, username, password):
        self.enter_text(self.locators.USERNAME, username)
        self.enter_text(self.locators.PASSWORD, password)
        self.click_element(self.locators.LOGIN_BTN)
        return DashboardPage(self.driver)

# 2. Return page objects for navigation
# 3. Use composition for complex pages
class ComplexPage:
    def __init__(self, driver):
        self.driver = driver
        self.header = HeaderComponent(driver)
        self.sidebar = SidebarComponent(driver)
        self.content = ContentComponent(driver)
```

**Q4: How do you test APIs effectively?**

**Answer:**
```python
# Comprehensive API testing approach:

def test_api_comprehensive():
    # 1. Test happy path
    response = api_client.post("/users", json=valid_data)
    assert response.status_code == 201
    
    # 2. Validate response schema
    jsonschema.validate(response.json(), user_schema)
    
    # 3. Test error scenarios
    response = api_client.post("/users", json=invalid_data)
    assert response.status_code == 400
    assert "validation error" in response.json()["message"]
    
    # 4. Test boundary conditions
    # 5. Performance testing
    start_time = time.time()
    response = api_client.get("/users")
    duration = time.time() - start_time
    assert duration < 2.0  # Response under 2 seconds
    
    # 6. Security testing
    response = api_client.get("/admin", headers={"Authorization": "Bearer invalid_token"})
    assert response.status_code == 401
```

**Q5: How do you design a test automation framework?**

**Answer:**
Key components:
1. **Configuration Management:** Environment-specific settings
2. **Test Data Management:** External data files, factories
3. **Reporting:** Multiple format support (HTML, JSON, Allure)
4. **Utilities:** Common functions, helpers
5. **Page Objects:** UI abstraction layer
6. **API Clients:** Service layer abstraction
7. **Fixtures:** Test setup/teardown
8. **CI Integration:** Pipeline configuration

**Q6: What metrics do you track for test automation?**

**Answer:**
- **Test Coverage:** Code/feature coverage percentage
- **Pass Rate:** Percentage of passing tests
- **Test Execution Time:** Duration trends
- **Flaky Test Rate:** Tests that intermittently fail
- **Bug Detection Rate:** Bugs found by automation vs manual
- **Test Maintenance Effort:** Time spent fixing tests
- **Environment Stability:** Test failure due to environment issues

## Interview Questions and Answers

| # | Difficulty | Question | Answer |
|---|------------|----------|---------|
| 1 | Easy | What is QA automation? | Process of using tools and scripts to automatically execute tests instead of manual testing |
| 2 | Easy | What is Selenium? | Web automation framework for testing web applications across different browsers |
| 3 | Easy | What is pytest? | Python testing framework with simple syntax, fixtures, and powerful assertion capabilities |
| 4 | Easy | What is Page Object Model? | Design pattern separating page elements and actions from test logic for maintainability |
| 5 | Easy | What is test fixture? | Setup and teardown code that provides consistent test environment |
| 6 | Easy | What is assertion? | Statement that verifies expected behavior or outcome in test |
| 7 | Easy | What is test data? | Input values, files, or database records used to execute tests |
| 8 | Easy | What is test case? | Specific scenario with steps, inputs, and expected results |
| 9 | Easy | What is test suite? | Collection of related test cases grouped together |
| 10 | Easy | What is regression testing? | Re-running tests after code changes to ensure no new bugs introduced |
| 11 | Easy | What is smoke testing? | Basic testing to verify critical functionality works |
| 12 | Easy | What is API testing? | Testing application programming interfaces for functionality, reliability, performance |
| 13 | Easy | What is test coverage? | Percentage of code executed during testing |
| 14 | Easy | What is cross-browser testing? | Testing web applications across different browsers and versions |
| 15 | Easy | What is headless testing? | Running browser tests without GUI for faster execution |
| 16 | Medium | How to handle dynamic elements in Selenium? | Use explicit waits, WebDriverWait, expected conditions |
| 17 | Medium | What is data-driven testing? | Using external data sources to parameterize tests with multiple inputs |
| 18 | Medium | What is keyword-driven testing? | Test automation approach using keywords to represent actions |
| 19 | Medium | What is BDD (Behavior Driven Development)? | Development approach using natural language to describe behavior |
| 20 | Medium | What is Cucumber/Gherkin? | BDD framework using Given-When-Then syntax for test scenarios |
| 21 | Medium | How to handle authentication in automation? | Store credentials securely, use test accounts, implement login helpers |
| 22 | Medium | What is implicit vs explicit wait? | Implicit waits globally, explicit waits for specific conditions |
| 23 | Medium | How to handle file uploads in Selenium? | Use send_keys() on file input elements or robot/AutoIT for dialogs |
| 24 | Medium | What is parallel test execution? | Running multiple tests simultaneously to reduce execution time |
| 25 | Medium | How to handle alerts and popups? | Use Alert class in Selenium: accept(), dismiss(), getText() |
| 26 | Medium | What is test reporting? | Generating detailed reports showing test results, failures, metrics |
| 27 | Medium | How to handle multiple windows/tabs? | Use window handles and switch_to.window() method |
| 28 | Medium | What is mock testing? | Using fake objects to simulate external dependencies |
| 29 | Medium | How to test REST APIs? | Use requests library, verify status codes, response data, headers |
| 30 | Medium | What is contract testing? | Verifying API contracts between services remain consistent |
| 31 | Hard | How to handle flaky tests? | Identify root causes, add waits, improve selectors, retry mechanisms |
| 32 | Hard | What is test automation framework design? | Structure organizing test code, utilities, configurations, reporting |
| 33 | Hard | How to implement CI/CD for test automation? | Integrate tests in pipeline, parallel execution, result reporting |
| 34 | Hard | What is visual testing? | Comparing visual appearance using screenshot comparison tools |
| 35 | Hard | How to test responsive web design? | Test across different screen sizes, viewports, devices |
| 36 | Hard | What is performance testing in automation? | Measuring response times, load capacity, resource usage |
| 37 | Hard | How to handle test environment management? | Use containers, configuration management, environment isolation |
| 38 | Hard | What is database testing? | Validating data integrity, CRUD operations, stored procedures |
| 39 | Hard | How to test microservices? | API testing, contract testing, service virtualization |
| 40 | Hard | What is chaos testing? | Intentionally introducing failures to test system resilience |
| 41 | Hard | How to implement test data management? | Use data factories, test databases, data generation tools |
| 42 | Hard | What is accessibility testing? | Verifying compliance with WCAG guidelines, screen readers |
| 43 | Hard | How to test mobile applications? | Use Appium, device farms, emulators, real devices |
| 44 | Hard | What is security testing automation? | Automated vulnerability scanning, penetration testing |
| 45 | Hard | How to handle test maintenance? | Regular review, refactoring, updating selectors, removing obsolete tests |
| 46 | Expert | What is test automation ROI? | Return on investment calculation considering automation costs vs benefits |
| 47 | Expert | How to design scalable test architecture? | Modular design, service layers, configuration management, monitoring |
| 48 | Expert | What is shift-left testing? | Moving testing earlier in development lifecycle |
| 49 | Expert | How to implement test observability? | Logging, metrics, tracing for test execution monitoring |
| 50 | Expert | What is AI in test automation? | Using machine learning for test generation, maintenance, analysis |
| 51 | Expert | How to test AI/ML applications? | Data quality testing, model validation, bias detection |
| 52 | Expert | What is test automation metrics? | Key performance indicators for automation effectiveness |
| 53 | Expert | How to handle legacy system testing? | Wrapper approaches, API layers, gradual modernization |
| 54 | Expert | What is infrastructure as code testing? | Testing cloud infrastructure using automation tools |
| 55 | Expert | How to implement test automation governance? | Standards, best practices, review processes, tool selection |
