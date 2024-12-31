#!/bin/bash

# Generate a random number between 1 and 10
target=$((RANDOM % 10 + 1))

echo "Welcome to the Number Guessing Game!"
echo "I'm thinking of a number between 1 and 10."

while true; do
    echo "Enter your guess:"
    read guess

    if ! [[ "$guess" =~ ^[0-9]+$ ]]; then
        echo "Please enter a valid number."
        continue
    fi

    if ((guess < target)); then
        echo "Too low! Try again."
    elif ((guess > target)); then
        echo "Too high! Try again."
    else
        echo "Congratulations! You guessed the correct number: $target"
        break
    fi
done