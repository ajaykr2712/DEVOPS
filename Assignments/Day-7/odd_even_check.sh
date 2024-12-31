#!/bin/bash

# Function to validate integer input
validate_integer() {
    if [[ $1 =~ ^-?[0-9]+$ ]]; then
        return 0
    else
        echo "Error: '$1' is not a valid integer."
        return 1
    fi
}

# Prompt for a number
while true; do
    echo "Enter an integer:"
    read number
    if validate_integer "$number"; then
        break
    fi
done

# Check if odd or even
if ((number % 2 == 0)); then
    echo "The number you entered ($number) is even."
else
    echo "The number you entered ($number) is odd."
fi