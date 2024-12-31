#!/bin/bash

# Declare variables
declare -i num1
declare -i num2
declare -i sum

# Prompt for input
echo "Enter the first number:"
read num1

echo "Enter the second number:"
read num2

# Calculate sum
sum=$((num1 + num2))

# Display result
echo "The sum of $num1 and $num2 is: $sum"