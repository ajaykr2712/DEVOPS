import re

# 1. Basic Pattern Matching
text = "Hello, my email is john@example.com"
email_pattern = r'\b[\w.-]+@[\w.-]+\.\w+\b'  # Simplified \.- to .-
email_match = re.search(email_pattern, text)
if email_match:
    print(email_match.group())  # Output: john@example.com

# 2. Phone Number Matching
phone_text = "Call me at 123-456-7890 or (987) 654-3210"
phone_pattern = r'\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4}'
phones = re.findall(phone_pattern, phone_text)
print(phones)  # Output: ['123-456-7890', '(987) 654-3210']

# 3. Text Replacement
text = "I love cats, cats are great"
new_text = re.sub(r'cats', 'dogs', text, flags=re.IGNORECASE)  # Added flags for case insensitivity
print(new_text)  # Output: I love dogs, dogs are great

# 4. Validating Username
def is_valid_username(username):
    return bool(re.match(r'^[a-zA-Z0-9_]{3,16}$', username))

print(is_valid_username("john_doe123"))  # Output: True
print(is_valid_username("jo"))          # Output: False

# 5. Extracting URLs
text = "Visit https://www.example.com and http://test.com"
url_pattern = r'https?://(?:[-\w.]|(?:%[\da-fA-F]{2}))+[^\s]*'
urls = re.findall(url_pattern, text)
print(urls)  # Output: ['https://www.example.com', 'http://test.com']

# 6. Split String by Multiple Delimiters
text = "apple,banana;orange|grape"
items = re.split(r'[,\|;]', text)  # Adjusted pattern for clarity
print(items)  # Output: ['apple', 'banana', 'orange', 'grape']

# 7. Password Validation
def is_valid_password(password):
    pattern = r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$'
    return bool(re.match(pattern, password))

print(is_valid_password("Password123!"))  # Output: True
print(is_valid_password("weak"))          # Output: False

# 8. Date Format Validation
def is_valid_date(date):
    pattern = r'^(0[1-9]|1[0-2])/(0[1-9]|[12]\d|3[01])/([12]\d{3})$'
    return bool(re.match(pattern, date))

print(is_valid_date("12/25/2023"))  # Output: True
print(is_valid_date("13/45/2023"))  # Output: False

# 9. Extracting Words with Specific Pattern
text = "Python3 is great123 for coding456"
pattern = r'\b\w+\d+\b'  # Matches words ending with digits
words = re.findall(pattern, text)
print(words)  # Output: ['Python3', 'great123', 'coding456']

# 10. HTML Tag Removal
html = "<p>This is <b>bold</b> text</p>"
clean_text = re.sub(r'<[^>]+>', '', html)  # Removes all HTML tags
print(clean_text)  # Output: This is bold text
