#!/bin/bash

while true; do
    echo "Menu:"
    echo "1. List files in current directory"
    echo "2. Create a new directory"
    echo "3. Remove a file"
    echo "4. Exit"
    read -p "Choose an option (1-4): " choice

    case $choice in
        1)
            echo "Files in current directory:"
            ls -l
            ;;
        2)
            read -p "Enter the name of the new directory: " dir_name
            mkdir "$dir_name"
            echo "Directory '$dir_name' created."
            ;;
        3)
            read -p "Enter the name of the file to remove: " file_name
            if [ -f "$file_name" ]; then
                rm "$file_name"
                echo "File '$file_name' removed."
            else
                echo "File '$file_name' does not exist."
            fi
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