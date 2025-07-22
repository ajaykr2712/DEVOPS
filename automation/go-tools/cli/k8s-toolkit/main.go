package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"os"
	"sort"
	"strconv"
	"strings"
	"time"

	"github.com/spf13/cobra"
	"github.com/spf13/viper"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/tools/clientcmd"
	metricsv1beta1 "k8s.io/metrics/pkg/apis/metrics/v1beta1"
	metrics "k8s.io/metrics/pkg/client/clientset/versioned"
)

// HealthCheckResult represents the result of a health check
type HealthCheckResult struct {
	Component string            `json:"component"`
	Status    string            `json:"status"`
	Message   string            `json:"message"`
	Details   map[string]string `json:"details"`
	Timestamp time.Time         `json:"timestamp"`
}

// ClusterHealth represents overall cluster health
type ClusterHealth struct {
	OverallStatus string               `json:"overall_status"`
	Checks        []HealthCheckResult  `json:"checks"`
	Summary       map[string]int       `json:"summary"`
	Timestamp     time.Time            `json:"timestamp"`
}

// K8sToolkit represents the main application
type K8sToolkit struct {
	clientset        *kubernetes.Clientset
	metricsClientset *metrics.Clientset
	namespace        string
	output           string
}

// NewK8sToolkit creates a new instance of K8sToolkit
func NewK8sToolkit() (*K8sToolkit, error) {
	// Get kubeconfig path
	kubeconfig := viper.GetString("kubeconfig")
	if kubeconfig == "" {
		kubeconfig = clientcmd.RecommendedHomeFile
	}

	// Build config
	config, err := clientcmd.BuildConfigFromFlags("", kubeconfig)
	if err != nil {
		return nil, fmt.Errorf("failed to build config: %w", err)
	}

	// Create clientset
	clientset, err := kubernetes.NewForConfig(config)
	if err != nil {
		return nil, fmt.Errorf("failed to create clientset: %w", err)
	}

	// Create metrics clientset
	metricsClientset, err := metrics.NewForConfig(config)
	if err != nil {
		log.Printf("Warning: failed to create metrics clientset: %v", err)
	}

	return &K8sToolkit{
		clientset:        clientset,
		metricsClientset: metricsClientset,
		namespace:        viper.GetString("namespace"),
		output:           viper.GetString("output"),
	}, nil
}

// CheckAPIServer checks if the API server is healthy
func (k *K8sToolkit) CheckAPIServer() HealthCheckResult {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	result := HealthCheckResult{
		Component: "API Server",
		Timestamp: time.Now(),
		Details:   make(map[string]string),
	}

	version, err := k.clientset.Discovery().ServerVersion()
	if err != nil {
		result.Status = "Critical"
		result.Message = fmt.Sprintf("Failed to connect to API server: %v", err)
		return result
	}

	result.Status = "Healthy"
	result.Message = "API server is responding"
	result.Details["version"] = version.GitVersion
	result.Details["platform"] = version.Platform
	return result
}

// CheckNodes checks the health of all nodes
func (k *K8sToolkit) CheckNodes() HealthCheckResult {
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	result := HealthCheckResult{
		Component: "Nodes",
		Timestamp: time.Now(),
		Details:   make(map[string]string),
	}

	nodes, err := k.clientset.CoreV1().Nodes().List(ctx, metav1.ListOptions{})
	if err != nil {
		result.Status = "Critical"
		result.Message = fmt.Sprintf("Failed to list nodes: %v", err)
		return result
	}

	if len(nodes.Items) == 0 {
		result.Status = "Critical"
		result.Message = "No nodes found in cluster"
		return result
	}

	readyNodes := 0
	notReadyNodes := 0
	var nodeIssues []string

	for _, node := range nodes.Items {
		nodeReady := false
		for _, condition := range node.Status.Conditions {
			if condition.Type == "Ready" {
				if condition.Status == "True" {
					nodeReady = true
					readyNodes++
				} else {
					notReadyNodes++
					nodeIssues = append(nodeIssues, fmt.Sprintf("%s: %s", node.Name, condition.Message))
				}
				break
			}
		}
		if !nodeReady {
			notReadyNodes++
			nodeIssues = append(nodeIssues, fmt.Sprintf("%s: Ready condition not found", node.Name))
		}
	}

	result.Details["total_nodes"] = strconv.Itoa(len(nodes.Items))
	result.Details["ready_nodes"] = strconv.Itoa(readyNodes)
	result.Details["not_ready_nodes"] = strconv.Itoa(notReadyNodes)

	if notReadyNodes > 0 {
		result.Status = "Warning"
		result.Message = fmt.Sprintf("%d nodes not ready", notReadyNodes)
		result.Details["issues"] = strings.Join(nodeIssues, "; ")
	} else {
		result.Status = "Healthy"
		result.Message = fmt.Sprintf("All %d nodes are ready", readyNodes)
	}

	return result
}

// CheckSystemPods checks critical system pods
func (k *K8sToolkit) CheckSystemPods() HealthCheckResult {
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	result := HealthCheckResult{
		Component: "System Pods",
		Timestamp: time.Now(),
		Details:   make(map[string]string),
	}

	systemNamespaces := []string{"kube-system", "kube-public", "kube-node-lease"}
	var allIssues []string
	totalPods := 0
	runningPods := 0

	for _, ns := range systemNamespaces {
		pods, err := k.clientset.CoreV1().Pods(ns).List(ctx, metav1.ListOptions{})
		if err != nil {
			allIssues = append(allIssues, fmt.Sprintf("Failed to list pods in %s: %v", ns, err))
			continue
		}

		for _, pod := range pods.Items {
			totalPods++
			if pod.Status.Phase == "Running" {
				runningPods++
			} else if pod.Status.Phase != "Succeeded" {
				allIssues = append(allIssues, fmt.Sprintf("%s/%s: %s", ns, pod.Name, pod.Status.Phase))
			}
		}
	}

	result.Details["total_system_pods"] = strconv.Itoa(totalPods)
	result.Details["running_pods"] = strconv.Itoa(runningPods)

	if len(allIssues) > 0 {
		result.Status = "Warning"
		result.Message = fmt.Sprintf("%d system pods have issues", len(allIssues))
		result.Details["issues"] = strings.Join(allIssues, "; ")
	} else {
		result.Status = "Healthy"
		result.Message = fmt.Sprintf("All %d system pods are running", runningPods)
	}

	return result
}

// CheckResourceUsage checks cluster resource usage
func (k *K8sToolkit) CheckResourceUsage() HealthCheckResult {
	result := HealthCheckResult{
		Component: "Resource Usage",
		Timestamp: time.Now(),
		Details:   make(map[string]string),
	}

	if k.metricsClientset == nil {
		result.Status = "Warning"
		result.Message = "Metrics server not available"
		return result
	}

	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	// Get node metrics
	nodeMetrics, err := k.metricsClientset.MetricsV1beta1().NodeMetricses().List(ctx, metav1.ListOptions{})
	if err != nil {
		result.Status = "Warning"
		result.Message = fmt.Sprintf("Failed to get node metrics: %v", err)
		return result
	}

	if len(nodeMetrics.Items) == 0 {
		result.Status = "Warning"
		result.Message = "No node metrics available"
		return result
	}

	var highCPUNodes []string
	var highMemoryNodes []string

	for _, nodeMetric := range nodeMetrics.Items {
		// Get node capacity
		node, err := k.clientset.CoreV1().Nodes().Get(ctx, nodeMetric.Name, metav1.GetOptions{})
		if err != nil {
			continue
		}

		cpuCapacity := node.Status.Capacity["cpu"]
		memoryCapacity := node.Status.Capacity["memory"]
		cpuUsage := nodeMetric.Usage["cpu"]
		memoryUsage := nodeMetric.Usage["memory"]

		// Calculate percentages (simplified)
		cpuPercent := float64(cpuUsage.MilliValue()) / float64(cpuCapacity.MilliValue()) * 100
		memoryPercent := float64(memoryUsage.Value()) / float64(memoryCapacity.Value()) * 100

		if cpuPercent > 80 {
			highCPUNodes = append(highCPUNodes, fmt.Sprintf("%s(%.1f%%)", nodeMetric.Name, cpuPercent))
		}
		if memoryPercent > 80 {
			highMemoryNodes = append(highMemoryNodes, fmt.Sprintf("%s(%.1f%%)", nodeMetric.Name, memoryPercent))
		}
	}

	result.Details["nodes_checked"] = strconv.Itoa(len(nodeMetrics.Items))

	if len(highCPUNodes) > 0 || len(highMemoryNodes) > 0 {
		result.Status = "Warning"
		var issues []string
		if len(highCPUNodes) > 0 {
			issues = append(issues, fmt.Sprintf("High CPU: %s", strings.Join(highCPUNodes, ", ")))
		}
		if len(highMemoryNodes) > 0 {
			issues = append(issues, fmt.Sprintf("High Memory: %s", strings.Join(highMemoryNodes, ", ")))
		}
		result.Message = strings.Join(issues, "; ")
	} else {
		result.Status = "Healthy"
		result.Message = "Resource usage is within normal limits"
	}

	return result
}

// CheckPVs checks persistent volumes
func (k *K8sToolkit) CheckPVs() HealthCheckResult {
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	result := HealthCheckResult{
		Component: "Persistent Volumes",
		Timestamp: time.Now(),
		Details:   make(map[string]string),
	}

	pvs, err := k.clientset.CoreV1().PersistentVolumes().List(ctx, metav1.ListOptions{})
	if err != nil {
		result.Status = "Warning"
		result.Message = fmt.Sprintf("Failed to list PVs: %v", err)
		return result
	}

	totalPVs := len(pvs.Items)
	availablePVs := 0
	boundPVs := 0
	failedPVs := 0
	var failedPVNames []string

	for _, pv := range pvs.Items {
		switch pv.Status.Phase {
		case "Available":
			availablePVs++
		case "Bound":
			boundPVs++
		case "Failed":
			failedPVs++
			failedPVNames = append(failedPVNames, pv.Name)
		}
	}

	result.Details["total_pvs"] = strconv.Itoa(totalPVs)
	result.Details["available_pvs"] = strconv.Itoa(availablePVs)
	result.Details["bound_pvs"] = strconv.Itoa(boundPVs)
	result.Details["failed_pvs"] = strconv.Itoa(failedPVs)

	if failedPVs > 0 {
		result.Status = "Warning"
		result.Message = fmt.Sprintf("%d PVs in failed state", failedPVs)
		result.Details["failed_pv_names"] = strings.Join(failedPVNames, ", ")
	} else {
		result.Status = "Healthy"
		result.Message = fmt.Sprintf("All %d PVs are healthy", totalPVs)
	}

	return result
}

// RunHealthCheck runs all health checks
func (k *K8sToolkit) RunHealthCheck() (*ClusterHealth, error) {
	checks := []HealthCheckResult{
		k.CheckAPIServer(),
		k.CheckNodes(),
		k.CheckSystemPods(),
		k.CheckResourceUsage(),
		k.CheckPVs(),
	}

	summary := make(map[string]int)
	overallStatus := "Healthy"

	for _, check := range checks {
		summary[check.Status]++
		
		// Determine overall status
		if check.Status == "Critical" {
			overallStatus = "Critical"
		} else if check.Status == "Warning" && overallStatus != "Critical" {
			overallStatus = "Warning"
		}
	}

	return &ClusterHealth{
		OverallStatus: overallStatus,
		Checks:        checks,
		Summary:       summary,
		Timestamp:     time.Now(),
	}, nil
}

// PrintHealthCheck prints the health check results
func (k *K8sToolkit) PrintHealthCheck(health *ClusterHealth) {
	if k.output == "json" {
		jsonData, err := json.MarshalIndent(health, "", "  ")
		if err != nil {
			log.Printf("Error marshaling JSON: %v", err)
			return
		}
		fmt.Println(string(jsonData))
		return
	}

	// Text output
	fmt.Printf("Kubernetes Cluster Health Report\n")
	fmt.Printf("Generated: %s\n", health.Timestamp.Format("2006-01-02 15:04:05"))
	fmt.Printf("Overall Status: %s\n\n", health.OverallStatus)

	// Summary
	fmt.Printf("Summary:\n")
	for status, count := range health.Summary {
		fmt.Printf("  %s: %d\n", status, count)
	}
	fmt.Println()

	// Detailed results
	fmt.Printf("Detailed Results:\n")
	sort.Slice(health.Checks, func(i, j int) bool {
		// Sort by status priority: Critical > Warning > Healthy
		statusPriority := map[string]int{"Critical": 3, "Warning": 2, "Healthy": 1}
		return statusPriority[health.Checks[i].Status] > statusPriority[health.Checks[j].Status]
	})

	for _, check := range health.Checks {
		statusIcon := map[string]string{
			"Healthy":  "✅",
			"Warning":  "⚠️",
			"Critical": "❌",
		}[check.Status]

		fmt.Printf("%s %s: %s\n", statusIcon, check.Component, check.Message)
		
		if len(check.Details) > 0 && (check.Status == "Warning" || check.Status == "Critical") {
			for key, value := range check.Details {
				if key != "issues" || check.Status != "Healthy" {
					fmt.Printf("    %s: %s\n", key, value)
				}
			}
		}
		fmt.Println()
	}
}

// createRootCmd creates the root command
func createRootCmd() *cobra.Command {
	var rootCmd = &cobra.Command{
		Use:   "k8s-toolkit",
		Short: "Kubernetes toolkit for DevOps operations",
		Long:  `A comprehensive toolkit for Kubernetes operations including health checks, resource optimization, and security scanning.`,
	}

	// Global flags
	rootCmd.PersistentFlags().String("kubeconfig", "", "Path to kubeconfig file")
	rootCmd.PersistentFlags().StringP("namespace", "n", "", "Kubernetes namespace")
	rootCmd.PersistentFlags().StringP("output", "o", "text", "Output format (text|json)")

	viper.BindPFlag("kubeconfig", rootCmd.PersistentFlags().Lookup("kubeconfig"))
	viper.BindPFlag("namespace", rootCmd.PersistentFlags().Lookup("namespace"))
	viper.BindPFlag("output", rootCmd.PersistentFlags().Lookup("output"))

	return rootCmd
}

// createHealthCmd creates the health command
func createHealthCmd() *cobra.Command {
	var healthCmd = &cobra.Command{
		Use:   "health",
		Short: "Check cluster health",
		Long:  `Performs comprehensive health checks on the Kubernetes cluster including nodes, pods, and resources.`,
		Run: func(cmd *cobra.Command, args []string) {
			toolkit, err := NewK8sToolkit()
			if err != nil {
				log.Fatalf("Failed to initialize toolkit: %v", err)
			}

			health, err := toolkit.RunHealthCheck()
			if err != nil {
				log.Fatalf("Failed to run health check: %v", err)
			}

			toolkit.PrintHealthCheck(health)

			// Exit with non-zero status if there are critical issues
			if health.OverallStatus == "Critical" {
				os.Exit(1)
			}
		},
	}

	return healthCmd
}

func main() {
	rootCmd := createRootCmd()
	
	// Add subcommands
	rootCmd.AddCommand(createHealthCmd())

	// Add version command
	rootCmd.AddCommand(&cobra.Command{
		Use:   "version",
		Short: "Print version information",
		Run: func(cmd *cobra.Command, args []string) {
			fmt.Println("k8s-toolkit version 2.0.0")
		},
	})

	if err := rootCmd.Execute(); err != nil {
		log.Fatal(err)
	}
}
