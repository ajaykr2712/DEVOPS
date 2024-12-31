#!/bin/bash

add() {
    echo "$(($1 + $2))"
}

subtract() {
    echo "$(($1 - $2))"
}

multiply() {
    echo "$(($1 * $2))"
}

divide() {
    if [ $2 -eq 0 ]; then
        echo "Error: Division by zero"
    else
        echo "scale=2; $1 / $2" | bc
    fi
}

echo "Simple Calculator"
read -p "Enter first number: " num1
read -p "Enter second number: " num2
read -p "Enter operation (+, -, *, /): " op

case $op in
    +) result=$(add $num1 $num2) ;;
    -) result=$(subtract $num1 $num2) ;;
    *) result=$(multiply $num1 $num2) ;;
    /) result=$(divide $num1 $num2) ;;
    *) echo "Invalid operation"; exit 1 ;;
esac

echo "Result: $result"