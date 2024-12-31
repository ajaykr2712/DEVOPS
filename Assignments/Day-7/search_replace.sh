#!/bin/bash

if [ $# -ne 3 ]; then
    echo "Usage: $0 <filename> <search_word> <replace_word>"
    exit 1
fi

filename="$1"
search_word="$2"
replace_word="$3"

if [ ! -f "$filename" ]; then
    echo "Error: File '$filename' does not exist."
    exit 1
fi

sed -i "s/$search_word/$replace_word/g" "$filename"
echo "Replacement complete. Words replaced: $(grep -c "$replace_word" "$filename")"