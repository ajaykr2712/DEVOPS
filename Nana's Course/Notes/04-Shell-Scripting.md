# 4. Shell Scripting - Detailed Notes

## Introduction to Shell Scripting

### What is Shell Scripting?
Shell scripting is writing a sequence of commands in a file that can be executed by the shell. It's a powerful way to automate repetitive tasks, system administration, and complex workflows.

### Benefits of Shell Scripting:
- **Automation**: Eliminate manual repetitive tasks
- **Efficiency**: Execute multiple commands in sequence
- **Consistency**: Ensure tasks are performed the same way every time
- **Scheduling**: Can be automated with cron jobs
- **System Administration**: Perfect for server management tasks

### Types of Shells:
```bash
# Check available shells
cat /etc/shells

Common shells:
/bin/bash     # Bourne Again Shell (most common)
/bin/zsh      # Z Shell (macOS default)
/bin/fish     # Friendly Interactive Shell
/bin/dash     # Debian Almquist Shell
/bin/sh       # Original Bourne Shell
```

### Shebang Line:
```bash
#!/bin/bash           # Use bash interpreter
#!/bin/sh            # Use sh interpreter
#!/usr/bin/env bash  # Find bash in PATH (more portable)
#!/usr/bin/env python3  # For Python scripts
```

## Shell Scripting Concepts and Syntax

### Basic Script Structure:
```bash
#!/bin/bash

# Script: example.sh
# Description: Basic shell script example
# Author: Your Name
# Date: $(date)

# Enable strict mode
set -euo pipefail

# Global variables
SCRIPT_NAME=$(basename "$0")
LOG_FILE="/var/log/${SCRIPT_NAME}.log"

# Functions
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

main() {
    log_message "Script started"
    # Main script logic here
    log_message "Script completed"
}

# Script execution
main "$@"
```

### Variables:
```bash
# Variable declaration (no spaces around =)
NAME="John"
AGE=30
CURRENT_DATE=$(date)

# Variable usage
echo "Hello, $NAME"
echo "Hello, ${NAME}"  # Preferred for clarity
echo "Age: $AGE years"

# Read-only variables
readonly PI=3.14159
declare -r SCRIPT_VERSION="1.0"

# Local variables in functions
function example() {
    local local_var="This is local"
    echo "$local_var"
}
```

### Command Line Arguments:
```bash
# Special variables
echo "Script name: $0"
echo "First argument: $1"
echo "Second argument: $2"
echo "All arguments: $@"
echo "Number of arguments: $#"
echo "Exit status of last command: $?"
echo "Process ID: $$"

# Argument processing
if [ $# -eq 0 ]; then
    echo "Usage: $0 <argument1> <argument2>"
    exit 1
fi

# Argument validation
if [ -z "$1" ]; then
    echo "Error: First argument is required"
    exit 1
fi
```

### Conditional Statements:
```bash
# If-else statement
if [ "$AGE" -ge 18 ]; then
    echo "Adult"
elif [ "$AGE" -ge 13 ]; then
    echo "Teenager"
else
    echo "Child"
fi

# Test conditions
if [ -f "/etc/passwd" ]; then          # File exists
    echo "File exists"
fi

if [ -d "/home/user" ]; then           # Directory exists
    echo "Directory exists"
fi

if [ -r "/etc/shadow" ]; then          # File is readable
    echo "File is readable"
fi

if [ "$USER" = "root" ]; then          # String comparison
    echo "Running as root"
fi

if [ "$AGE" -gt 21 ]; then             # Numeric comparison
    echo "Can drink alcohol"
fi

# Logical operators
if [ "$AGE" -ge 18 ] && [ "$AGE" -le 65 ]; then
    echo "Working age"
fi

if [ "$USER" = "root" ] || [ "$USER" = "admin" ]; then
    echo "Privileged user"
fi
```

### Comparison Operators:
```bash
# Numeric comparisons
-eq    # Equal to
-ne    # Not equal to
-gt    # Greater than
-ge    # Greater than or equal to
-lt    # Less than
-le    # Less than or equal to

# String comparisons
=      # Equal to
!=     # Not equal to
-z     # String is empty
-n     # String is not empty

# File tests
-f     # Regular file
-d     # Directory
-e     # Exists
-r     # Readable
-w     # Writable
-x     # Executable
-s     # File size > 0
```

### Loops:
```bash
# For loop - iterate over list
for item in apple banana cherry; do
    echo "Fruit: $item"
done

# For loop - iterate over files
for file in /etc/*.conf; do
    echo "Config file: $file"
done

# For loop - C-style
for ((i=1; i<=10; i++)); do
    echo "Number: $i"
done

# While loop
counter=1
while [ $counter -le 5 ]; do
    echo "Counter: $counter"
    ((counter++))
done

# Until loop
counter=1
until [ $counter -gt 5 ]; do
    echo "Counter: $counter"
    ((counter++))
done

# Break and continue
for i in {1..10}; do
    if [ $i -eq 5 ]; then
        continue  # Skip 5
    fi
    if [ $i -eq 8 ]; then
        break     # Stop at 8
    fi
    echo $i
done
```

### Case Statements:
```bash
case "$1" in
    start)
        echo "Starting service..."
        ;;
    stop)
        echo "Stopping service..."
        ;;
    restart)
        echo "Restarting service..."
        ;;
    status)
        echo "Checking service status..."
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status}"
        exit 1
        ;;
esac
```

### Functions:
```bash
# Function definition
function greet() {
    local name="$1"
    local age="$2"
    echo "Hello, $name! You are $age years old."
}

# Alternative syntax
greet() {
    echo "Hello, $1!"
}

# Function with return value
calculate_sum() {
    local num1="$1"
    local num2="$2"
    local sum=$((num1 + num2))
    echo "$sum"  # Return value via echo
}

# Using functions
greet "John" "30"
result=$(calculate_sum 10 20)
echo "Sum: $result"

# Function with exit codes
validate_file() {
    if [ -f "$1" ]; then
        return 0  # Success
    else
        return 1  # Failure
    fi
}

if validate_file "/etc/passwd"; then
    echo "File exists"
else
    echo "File not found"
fi
```

### Arrays:
```bash
# Array declaration
fruits=("apple" "banana" "cherry")
numbers=(1 2 3 4 5)

# Adding elements
fruits+=("orange")

# Accessing elements
echo "First fruit: ${fruits[0]}"
echo "All fruits: ${fruits[@]}"
echo "Number of fruits: ${#fruits[@]}"

# Iterating over array
for fruit in "${fruits[@]}"; do
    echo "Fruit: $fruit"
done

# Associative arrays (bash 4+)
declare -A colors
colors[red]="#FF0000"
colors[green]="#00FF00"
colors[blue]="#0000FF"

echo "Red color code: ${colors[red]}"

# Iterate over associative array
for color in "${!colors[@]}"; do
    echo "$color: ${colors[$color]}"
done
```

### String Manipulation:
```bash
string="Hello, World!"

# String length
echo ${#string}

# Substring extraction
echo ${string:0:5}    # "Hello"
echo ${string:7}      # "World!"

# String replacement
echo ${string/World/Universe}  # Replace first occurrence
echo ${string//l/L}            # Replace all occurrences

# String case conversion
echo ${string^^}      # Uppercase
echo ${string,,}      # Lowercase

# Remove from beginning/end
filename="document.txt.backup"
echo ${filename%.backup}      # Remove .backup from end
echo ${filename#document.}    # Remove document. from beginning
```

### Input/Output:
```bash
# Reading user input
read -p "Enter your name: " name
echo "Hello, $name!"

# Reading with timeout
if read -t 10 -p "Enter choice (10 seconds): " choice; then
    echo "You chose: $choice"
else
    echo "Timeout!"
fi

# Reading passwords (hidden input)
read -s -p "Enter password: " password
echo  # New line after hidden input

# Reading from file
while IFS= read -r line; do
    echo "Line: $line"
done < "/etc/passwd"
```

## Environment Variables

### What are Environment Variables?
Environment variables are dynamic values that affect the behavior of processes and programs running on the system.

### Common Environment Variables:
```bash
echo $HOME        # User's home directory
echo $USER        # Current username
echo $PATH        # Executable search path
echo $PWD         # Current working directory
echo $SHELL       # Current shell
echo $TERM        # Terminal type
echo $LANG        # System language
echo $PS1         # Primary prompt string
```

### Viewing Environment Variables:
```bash
env               # Show all environment variables
printenv          # Alternative to env
printenv HOME     # Show specific variable
set               # Show all variables (including local)
```

### Setting Environment Variables:
```bash
# Temporary (current session only)
export MYVAR="Hello World"
export PATH="$PATH:/new/directory"

# Permanent (add to ~/.bashrc or ~/.profile)
echo 'export MYVAR="Hello World"' >> ~/.bashrc
source ~/.bashrc  # Reload configuration

# System-wide (add to /etc/environment)
echo 'MYVAR="Hello World"' | sudo tee -a /etc/environment
```

### Special Environment Variables:
```bash
# PATH - Search path for executables
export PATH="$HOME/bin:$PATH"

# LD_LIBRARY_PATH - Shared library search path
export LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH"

# EDITOR - Default text editor
export EDITOR="vim"

# BROWSER - Default web browser
export BROWSER="firefox"

# Proxy settings
export HTTP_PROXY="http://proxy.company.com:8080"
export HTTPS_PROXY="http://proxy.company.com:8080"
export NO_PROXY="localhost,127.0.0.1"
```

### Using Environment Variables in Scripts:
```bash
#!/bin/bash

# Check if variable is set
if [ -z "$MYVAR" ]; then
    echo "MYVAR is not set"
    exit 1
fi

# Provide default value
CONFIG_FILE="${CONFIG_FILE:-/etc/myapp/config.conf}"

# Use variable with validation
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Config file not found: $CONFIG_FILE"
    exit 1
fi

# Environment-based configuration
case "$ENVIRONMENT" in
    development)
        DEBUG=true
        LOG_LEVEL="debug"
        ;;
    production)
        DEBUG=false
        LOG_LEVEL="error"
        ;;
    *)
        echo "Unknown environment: $ENVIRONMENT"
        exit 1
        ;;
esac
```

### Best Practices for Environment Variables:
```bash
# Use meaningful names
export DATABASE_URL="postgresql://user:pass@host:5432/db"
export API_SECRET_KEY="your-secret-key"

# Use consistent naming convention
export MYAPP_DATABASE_HOST="localhost"
export MYAPP_DATABASE_PORT="5432"
export MYAPP_LOG_LEVEL="info"

# Validate required variables
required_vars=("DATABASE_URL" "API_SECRET_KEY")
for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        echo "Error: $var is not set"
        exit 1
    fi
done

# Use .env files for development
if [ -f ".env" ]; then
    export $(cat .env | xargs)
fi
```

### Script Error Handling:
```bash
#!/bin/bash

# Strict mode
set -euo pipefail

# Error handling function
error_exit() {
    echo "Error: $1" >&2
    exit 1
}

# Trap to cleanup on exit
cleanup() {
    echo "Cleaning up..."
    # Cleanup code here
}
trap cleanup EXIT

# Usage example
validate_file() {
    local file="$1"
    [ -f "$file" ] || error_exit "File not found: $file"
    [ -r "$file" ] || error_exit "File not readable: $file"
}

# Script logic with error handling
if ! command -v git &> /dev/null; then
    error_exit "Git is not installed"
fi

validate_file "/etc/passwd"
echo "All validations passed"
```

### Script Debugging:
```bash
# Debug mode - show commands as they execute
set -x

# Debug specific sections
(set -x; ls -la /home)

# Conditional debugging
if [ "$DEBUG" = "true" ]; then
    set -x
fi

# Log function with debug levels
log() {
    local level="$1"
    shift
    local message="$*"
    
    case "$level" in
        DEBUG)
            [ "$LOG_LEVEL" = "DEBUG" ] && echo "[DEBUG] $message" >&2
            ;;
        INFO)
            echo "[INFO] $message"
            ;;
        ERROR)
            echo "[ERROR] $message" >&2
            ;;
    esac
}

# Usage
log DEBUG "This is a debug message"
log INFO "Script started"
log ERROR "Something went wrong"
```
