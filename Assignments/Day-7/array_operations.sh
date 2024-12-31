#!/bin/bash

# Declare an array of favorite fruits
fruits=("apple" "banana" "orange" "grape" "mango")

# Function to display fruits
display_fruits() {
    echo "Current fruits:"
    for i in "${!fruits[@]}"; do
        echo "$((i+1)). ${fruits[i]}"
    done
}

while true; do
    echo "1. Add a fruit"
    echo "2. Remove a fruit"
    echo "3. Display fruits"
    echo "4. Exit"
    read -p "Choose an option (1-4): " choice

    case $choice in
        1)
            read -p "Enter a fruit to add: " new_fruit
            fruits+=("$new_fruit")
            echo "Fruit added successfully."
            ;;
        2)
            display_fruits
            read -p "Enter the number of the fruit to remove: " remove_index
            if ((remove_index >= 1 && remove_index <= ${#fruits[@]})); then
                unset "fruits[$((remove_index-1))]"
                fruits=("${fruits[@]}")
                echo "Fruit removed successfully."
            else
                echo "Invalid index."
            fi
            ;;
        3)
            display_fruits
            ;;
        4)
            echo "Goodbye!"
            exit 0
            ;;
        *)
            echo "Invalid option. Please try again."
            ;;
    esac
    echo
done