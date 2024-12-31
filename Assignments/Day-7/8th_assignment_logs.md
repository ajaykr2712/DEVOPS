# Simple Logging Script with Cronjob and Aliases

## **Script: `logs.sh`**

This script generates a log entry with the current date and time, appending it to `logs.txt` in your home directory.

### **Code**
```bash
#!/bin/bash

# Define the log file path
log_file="$HOME/logs.txt"

# Get the current timestamp
current_datetime=$(date +"%Y-%m-%d %H:%M:%S")

# Define the log message
log_message="Log entry at ${current_datetime}"

# Append the log message to the log file
echo "$log_message" >> "$log_file"

# Print success message
echo "Log entry added successfully to $log_file"
