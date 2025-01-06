# Example: Calling a REST API.

package main

import (
    "encoding/json"
    "fmt"
    "net/http"
)

type Response struct {
    Status string `json:"status"`
}

func main() {
    resp, err := http.Get("https://api.example.com/status")
    if err != nil {
        fmt.Println("Error:", err)
        return
    }
    defer resp.Body.Close()

    var result Response
    json.NewDecoder(resp.Body).Decode(&result)
    fmt.Println("API Status:", result.Status)
}
