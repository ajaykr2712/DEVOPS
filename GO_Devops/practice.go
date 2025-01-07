package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"time"
)

// PipelineStatus represents the status of a CI/CD pipeline
type PipelineStatus struct {
	ID     string `json:"id"`
	Status string `json:"status"`
	Logs   string `json:"logs,omitempty"`
}

// Mock pipeline data
var pipelineData = map[string]*PipelineStatus{}

func main() {
	http.HandleFunc("/trigger", triggerPipeline)
	http.HandleFunc("/status", getPipelineStatus)
	http.HandleFunc("/logs", getPipelineLogs)

	port := 8080
	fmt.Printf("Starting server on port %d...\n", port)
	log.Fatal(http.ListenAndServe(fmt.Sprintf(":%d", port), nil))
}

// triggerPipeline triggers a new CI/CD pipeline
func triggerPipeline(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Invalid request method", http.StatusMethodNotAllowed)
		return
	}

	pipelineID := fmt.Sprintf("pipeline-%d", time.Now().UnixNano())
	pipelineData[pipelineID] = &PipelineStatus{
		ID:     pipelineID,
		Status: "In Progress",
	}

	go func(id string) {
		time.Sleep(10 * time.Second) // Simulate build process
		pipelineData[id].Status = "Success"
		pipelineData[id].Logs = "Build completed successfully."
	}(pipelineID)

	response := map[string]string{"message": "Pipeline triggered", "id": pipelineID}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

// getPipelineStatus retrieves the status of a given pipeline
func getPipelineStatus(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "Invalid request method", http.StatusMethodNotAllowed)
		return
	}

	id := r.URL.Query().Get("id")
	if id == "" {
		http.Error(w, "Pipeline ID is required", http.StatusBadRequest)
		return
	}

	pipeline, exists := pipelineData[id]
	if !exists {
		http.Error(w, "Pipeline not found", http.StatusNotFound)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(pipeline)
}

// getPipelineLogs retrieves the logs of a completed pipeline
func getPipelineLogs(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "Invalid request method", http.StatusMethodNotAllowed)
		return
	}

	id := r.URL.Query().Get("id")
	if id == "" {
		http.Error(w, "Pipeline ID is required", http.StatusBadRequest)
		return
	}

	pipeline, exists := pipelineData[id]
	if !exists {
		http.Error(w, "Pipeline not found", http.StatusNotFound)
		return
	}

	if pipeline.Status != "Success" {
		http.Error(w, "Logs not available for in-progress or failed pipelines", http.StatusBadRequest)
		return
	}

	response := map[string]string{"logs": pipeline.Logs}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}
