#!/bin/bash

# Declare variables
log_file="$HOME/logs.txt"
current_datetime=$(date +"%Y-%m-%d %H:%M:%S")
log_message="This log was generated at ${current_datetime}"

# Add the new log to the logs.txt file
echo "$log_message" >> "$log_file"

# Print a message to the terminal
echo "Log entry added successfully to $log_file"
