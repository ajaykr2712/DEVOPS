function gpush() {
    git add .
    git commit -m "${1:-Auto commit}"
    git push origin main
}

