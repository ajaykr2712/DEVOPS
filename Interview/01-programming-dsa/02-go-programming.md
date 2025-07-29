# 🐹 Go Programming - Complete Interview Guide

## 📚 Table of Contents
1. [Go Basics](#go-basics)
2. [Structs and Methods](#structs-and-methods)
3. [Interfaces](#interfaces)
4. [Concurrency](#concurrency)
5. [Error Handling](#error-handling)
6. [Advanced Topics](#advanced-topics)
7. [Interview Questions](#interview-questions)
8. [Interview Questions and Answers](#interview-questions-and-answers)

---

## Go Basics

### Variables and Types

```go
package main

import (
    "fmt"
    "reflect"
)

func main() {
    // Variable declarations
    var name string = "John"
    var age int = 30
    var isActive bool = true
    
    // Short variable declaration
    city := "New York"
    salary := 50000.0
    
    // Multiple variable declaration
    var (
        firstName string = "Alice"
        lastName  string = "Smith"
        height    float64 = 5.6
    )
    
    // Zero values
    var count int        // 0
    var message string   // ""
    var active bool      // false
    var ptr *int         // nil
    
    // Type conversion
    var x int = 42
    var y float64 = float64(x)
    var z string = fmt.Sprintf("%d", x)
    
    fmt.Printf("Type of x: %v\n", reflect.TypeOf(x))
    fmt.Printf("Type of y: %v\n", reflect.TypeOf(y))
    fmt.Printf("Type of z: %v\n", reflect.TypeOf(z))
}
```

### Arrays, Slices, and Maps

```go
package main

import "fmt"

func main() {
    // Arrays (fixed size)
    var arr [5]int = [5]int{1, 2, 3, 4, 5}
    arr2 := [...]int{10, 20, 30} // Size inferred
    
    // Slices (dynamic arrays)
    slice1 := []int{1, 2, 3, 4, 5}
    slice2 := make([]int, 5, 10) // length 5, capacity 10
    
    // Slice operations
    slice3 := slice1[1:4]        // [2, 3, 4]
    slice1 = append(slice1, 6)   // Add element
    
    // Copy slices
    destination := make([]int, len(slice1))
    copy(destination, slice1)
    
    // Maps
    ages := map[string]int{
        "Alice": 25,
        "Bob":   30,
    }
    
    // Map operations
    ages["Charlie"] = 35         // Add
    age, exists := ages["Alice"] // Check existence
    delete(ages, "Bob")          // Delete
    
    if exists {
        fmt.Printf("Alice is %d years old\n", age)
    }
    
    // Iterate over map
    for name, age := range ages {
        fmt.Printf("%s: %d\n", name, age)
    }
}
```

### Functions and Closures

```go
package main

import "fmt"

// Basic function
func add(a, b int) int {
    return a + b
}

// Multiple return values
func divmod(a, b int) (int, int, error) {
    if b == 0 {
        return 0, 0, fmt.Errorf("division by zero")
    }
    return a / b, a % b, nil
}

// Named return values
func rectangle(length, width float64) (area, perimeter float64) {
    area = length * width
    perimeter = 2 * (length + width)
    return // naked return
}

// Variadic function
func sum(numbers ...int) int {
    total := 0
    for _, num := range numbers {
        total += num
    }
    return total
}

// Higher-order function
func applyOperation(a, b int, op func(int, int) int) int {
    return op(a, b)
}

// Closure
func counter() func() int {
    count := 0
    return func() int {
        count++
        return count
    }
}

func main() {
    // Function calls
    result := add(5, 3)
    fmt.Printf("5 + 3 = %d\n", result)
    
    quotient, remainder, err := divmod(10, 3)
    if err != nil {
        fmt.Printf("Error: %v\n", err)
    } else {
        fmt.Printf("10 / 3 = %d remainder %d\n", quotient, remainder)
    }
    
    // Variadic function
    total := sum(1, 2, 3, 4, 5)
    fmt.Printf("Sum: %d\n", total)
    
    // Higher-order function
    multiply := func(a, b int) int { return a * b }
    result = applyOperation(4, 5, multiply)
    fmt.Printf("4 * 5 = %d\n", result)
    
    // Closure
    c := counter()
    fmt.Printf("Count: %d\n", c()) // 1
    fmt.Printf("Count: %d\n", c()) // 2
    fmt.Printf("Count: %d\n", c()) // 3
}
```

---

## Structs and Methods

### Struct Definition and Methods

```go
package main

import (
    "fmt"
    "math"
)

// Basic struct
type Person struct {
    FirstName string
    LastName  string
    Age       int
    Email     string
}

// Struct with embedded fields
type Address struct {
    Street   string
    City     string
    ZipCode  string
    Country  string
}

type Employee struct {
    Person           // Embedded struct
    Address          // Embedded struct
    ID       int
    Salary   float64
    Department string
}

// Method with value receiver
func (p Person) FullName() string {
    return fmt.Sprintf("%s %s", p.FirstName, p.LastName)
}

// Method with pointer receiver (can modify the struct)
func (p *Person) UpdateAge(newAge int) {
    p.Age = newAge
}

func (p *Person) HaveBirthday() {
    p.Age++
}

// Method with value receiver for calculation
func (p Person) IsAdult() bool {
    return p.Age >= 18
}

// Struct with methods for geometric calculations
type Circle struct {
    Radius float64
}

func (c Circle) Area() float64 {
    return math.Pi * c.Radius * c.Radius
}

func (c Circle) Circumference() float64 {
    return 2 * math.Pi * c.Radius
}

func (c *Circle) Scale(factor float64) {
    c.Radius *= factor
}

// Constructor function
func NewPerson(firstName, lastName string, age int) *Person {
    return &Person{
        FirstName: firstName,
        LastName:  lastName,
        Age:       age,
    }
}

func NewEmployee(firstName, lastName string, age int, id int, salary float64) *Employee {
    return &Employee{
        Person: Person{
            FirstName: firstName,
            LastName:  lastName,
            Age:       age,
        },
        ID:     id,
        Salary: salary,
    }
}

func main() {
    // Creating structs
    person1 := Person{
        FirstName: "John",
        LastName:  "Doe",
        Age:       30,
        Email:     "john.doe@email.com",
    }
    
    // Using constructor
    person2 := NewPerson("Jane", "Smith", 25)
    
    // Calling methods
    fmt.Printf("Full name: %s\n", person1.FullName())
    fmt.Printf("Is adult: %v\n", person1.IsAdult())
    
    // Modifying through pointer receiver
    person1.UpdateAge(31)
    person1.HaveBirthday()
    fmt.Printf("Updated age: %d\n", person1.Age)
    
    // Employee with embedded structs
    emp := NewEmployee("Alice", "Johnson", 28, 1001, 75000)
    fmt.Printf("Employee: %s, ID: %d\n", emp.FullName(), emp.ID)
    
    // Setting address
    emp.Address = Address{
        Street:  "123 Main St",
        City:    "New York",
        ZipCode: "10001",
        Country: "USA",
    }
    
    // Circle example
    circle := Circle{Radius: 5.0}
    fmt.Printf("Circle area: %.2f\n", circle.Area())
    fmt.Printf("Circle circumference: %.2f\n", circle.Circumference())
    
    circle.Scale(2.0)
    fmt.Printf("Scaled circle area: %.2f\n", circle.Area())
}
```

### Struct Tags and JSON

```go
package main

import (
    "encoding/json"
    "fmt"
    "time"
)

type User struct {
    ID        int       `json:"id"`
    Username  string    `json:"username"`
    Email     string    `json:"email,omitempty"`
    Password  string    `json:"-"` // Never serialize
    CreatedAt time.Time `json:"created_at"`
    IsActive  bool      `json:"is_active"`
}

type Product struct {
    ID          int     `json:"id" db:"product_id" validate:"required"`
    Name        string  `json:"name" db:"product_name" validate:"required,min=3,max=100"`
    Price       float64 `json:"price" db:"price" validate:"required,gt=0"`
    Description string  `json:"description,omitempty" db:"description"`
}

func main() {
    user := User{
        ID:        1,
        Username:  "johndoe",
        Email:     "john@example.com",
        Password:  "secretpassword",
        CreatedAt: time.Now(),
        IsActive:  true,
    }
    
    // Marshal to JSON
    jsonData, err := json.MarshalIndent(user, "", "  ")
    if err != nil {
        fmt.Printf("Error marshaling: %v\n", err)
        return
    }
    
    fmt.Printf("JSON:\n%s\n", jsonData)
    
    // Unmarshal from JSON
    jsonString := `{
        "id": 2,
        "username": "janedoe",
        "email": "jane@example.com",
        "created_at": "2023-01-01T00:00:00Z",
        "is_active": false
    }`
    
    var newUser User
    err = json.Unmarshal([]byte(jsonString), &newUser)
    if err != nil {
        fmt.Printf("Error unmarshaling: %v\n", err)
        return
    }
    
    fmt.Printf("Unmarshaled user: %+v\n", newUser)
}
```

---

## Interfaces

### Basic Interfaces

```go
package main

import (
    "fmt"
    "math"
)

// Shape interface
type Shape interface {
    Area() float64
    Perimeter() float64
}

// Writer interface (similar to io.Writer)
type Writer interface {
    Write([]byte) (int, error)
}

// Stringer interface (similar to fmt.Stringer)
type Stringer interface {
    String() string
}

// Rectangle implements Shape
type Rectangle struct {
    Width, Height float64
}

func (r Rectangle) Area() float64 {
    return r.Width * r.Height
}

func (r Rectangle) Perimeter() float64 {
    return 2 * (r.Width + r.Height)
}

func (r Rectangle) String() string {
    return fmt.Sprintf("Rectangle(%.2f x %.2f)", r.Width, r.Height)
}

// Circle implements Shape
type Circle struct {
    Radius float64
}

func (c Circle) Area() float64 {
    return math.Pi * c.Radius * c.Radius
}

func (c Circle) Perimeter() float64 {
    return 2 * math.Pi * c.Radius
}

func (c Circle) String() string {
    return fmt.Sprintf("Circle(radius: %.2f)", c.Radius)
}

// Function that works with any Shape
func printShapeInfo(s Shape) {
    fmt.Printf("Shape: %v\n", s)
    fmt.Printf("Area: %.2f\n", s.Area())
    fmt.Printf("Perimeter: %.2f\n", s.Perimeter())
    fmt.Println()
}

// Empty interface and type assertions
func processAny(value interface{}) {
    switch v := value.(type) {
    case int:
        fmt.Printf("Integer: %d\n", v)
    case string:
        fmt.Printf("String: %s\n", v)
    case Shape:
        fmt.Printf("Shape with area: %.2f\n", v.Area())
    default:
        fmt.Printf("Unknown type: %T\n", v)
    }
}

func main() {
    // Create shapes
    rect := Rectangle{Width: 5, Height: 3}
    circle := Circle{Radius: 2}
    
    // Use interface
    shapes := []Shape{rect, circle}
    
    for _, shape := range shapes {
        printShapeInfo(shape)
    }
    
    // Type assertion
    var s Shape = rect
    if r, ok := s.(Rectangle); ok {
        fmt.Printf("It's a rectangle: %v\n", r)
    }
    
    // Empty interface examples
    processAny(42)
    processAny("Hello, Go!")
    processAny(circle)
    processAny([]int{1, 2, 3})
}
```

### Advanced Interface Patterns

```go
package main

import (
    "fmt"
    "io"
    "strings"
)

// Interface composition
type Reader interface {
    Read([]byte) (int, error)
}

type Writer interface {
    Write([]byte) (int, error)
}

type ReadWriter interface {
    Reader
    Writer
}

type Closer interface {
    Close() error
}

type ReadWriteCloser interface {
    Reader
    Writer
    Closer
}

// Interface segregation principle
type Saver interface {
    Save() error
}

type Loader interface {
    Load() error
}

type Validator interface {
    Validate() error
}

// Document that implements multiple interfaces
type Document struct {
    Content string
    Path    string
}

func (d *Document) Save() error {
    fmt.Printf("Saving document to %s\n", d.Path)
    return nil
}

func (d *Document) Load() error {
    fmt.Printf("Loading document from %s\n", d.Path)
    return nil
}

func (d *Document) Validate() error {
    if d.Content == "" {
        return fmt.Errorf("document content cannot be empty")
    }
    return nil
}

// Strategy pattern with interfaces
type SortStrategy interface {
    Sort([]int) []int
}

type BubbleSort struct{}

func (bs BubbleSort) Sort(data []int) []int {
    fmt.Println("Using bubble sort")
    // Simplified bubble sort implementation
    result := make([]int, len(data))
    copy(result, data)
    
    for i := 0; i < len(result); i++ {
        for j := 0; j < len(result)-1-i; j++ {
            if result[j] > result[j+1] {
                result[j], result[j+1] = result[j+1], result[j]
            }
        }
    }
    return result
}

type QuickSort struct{}

func (qs QuickSort) Sort(data []int) []int {
    fmt.Println("Using quick sort")
    // Simplified quick sort implementation
    result := make([]int, len(data))
    copy(result, data)
    // ... actual quick sort logic would go here
    return result
}

type Sorter struct {
    strategy SortStrategy
}

func (s *Sorter) SetStrategy(strategy SortStrategy) {
    s.strategy = strategy
}

func (s *Sorter) Sort(data []int) []int {
    return s.strategy.Sort(data)
}

// Mock for testing
type MockWriter struct {
    Data []byte
}

func (mw *MockWriter) Write(data []byte) (int, error) {
    mw.Data = append(mw.Data, data...)
    return len(data), nil
}

func writeMessage(w Writer, message string) error {
    _, err := w.Write([]byte(message))
    return err
}

func main() {
    // Interface composition example
    var rw ReadWriter = &strings.Reader{}
    
    // Document example
    doc := &Document{
        Content: "Hello, World!",
        Path:    "/tmp/document.txt",
    }
    
    // Using interface segregation
    var saver Saver = doc
    var loader Loader = doc
    var validator Validator = doc
    
    validator.Validate()
    loader.Load()
    saver.Save()
    
    // Strategy pattern
    sorter := &Sorter{}
    data := []int{64, 34, 25, 12, 22, 11, 90}
    
    sorter.SetStrategy(BubbleSort{})
    sorted1 := sorter.Sort(data)
    fmt.Printf("Sorted: %v\n", sorted1)
    
    sorter.SetStrategy(QuickSort{})
    sorted2 := sorter.Sort(data)
    fmt.Printf("Sorted: %v\n", sorted2)
    
    // Mock for testing
    mock := &MockWriter{}
    err := writeMessage(mock, "Hello, testing!")
    if err != nil {
        fmt.Printf("Error: %v\n", err)
    }
    fmt.Printf("Mock received: %s\n", string(mock.Data))
}
```

---

## Concurrency

### Goroutines and Channels

```go
package main

import (
    "fmt"
    "sync"
    "time"
)

// Basic goroutine
func sayHello(name string) {
    for i := 0; i < 3; i++ {
        fmt.Printf("Hello %s %d\n", name, i)
        time.Sleep(100 * time.Millisecond)
    }
}

// Channels for communication
func producer(ch chan<- int) {
    for i := 1; i <= 5; i++ {
        ch <- i
        fmt.Printf("Produced: %d\n", i)
        time.Sleep(100 * time.Millisecond)
    }
    close(ch)
}

func consumer(ch <-chan int, done chan<- bool) {
    for value := range ch {
        fmt.Printf("Consumed: %d\n", value)
        time.Sleep(200 * time.Millisecond)
    }
    done <- true
}

// Buffered channels
func bufferedChannelExample() {
    ch := make(chan string, 3) // Buffer size 3
    
    // Send without blocking
    ch <- "first"
    ch <- "second"
    ch <- "third"
    
    // Receive values
    fmt.Println(<-ch)
    fmt.Println(<-ch)
    fmt.Println(<-ch)
}

// Select statement for non-blocking operations
func selectExample() {
    ch1 := make(chan string)
    ch2 := make(chan string)
    
    go func() {
        time.Sleep(1 * time.Second)
        ch1 <- "from channel 1"
    }()
    
    go func() {
        time.Sleep(2 * time.Second)
        ch2 <- "from channel 2"
    }()
    
    for i := 0; i < 2; i++ {
        select {
        case msg1 := <-ch1:
            fmt.Println("Received:", msg1)
        case msg2 := <-ch2:
            fmt.Println("Received:", msg2)
        case <-time.After(3 * time.Second):
            fmt.Println("Timeout!")
        }
    }
}

func main() {
    // Basic goroutines
    go sayHello("Alice")
    go sayHello("Bob")
    
    time.Sleep(1 * time.Second) // Wait for goroutines
    
    // Channel communication
    ch := make(chan int)
    done := make(chan bool)
    
    go producer(ch)
    go consumer(ch, done)
    
    <-done // Wait for consumer to finish
    
    // Buffered channels
    bufferedChannelExample()
    
    // Select statement
    selectExample()
}
```

### Synchronization Primitives

```go
package main

import (
    "fmt"
    "math/rand"
    "sync"
    "sync/atomic"
    "time"
)

// Mutex example
type SafeCounter struct {
    mu    sync.Mutex
    count int
}

func (c *SafeCounter) Increment() {
    c.mu.Lock()
    defer c.mu.Unlock()
    c.count++
}

func (c *SafeCounter) Value() int {
    c.mu.Lock()
    defer c.mu.Unlock()
    return c.count
}

// RWMutex example
type SafeMap struct {
    mu   sync.RWMutex
    data map[string]int
}

func NewSafeMap() *SafeMap {
    return &SafeMap{
        data: make(map[string]int),
    }
}

func (sm *SafeMap) Set(key string, value int) {
    sm.mu.Lock()
    defer sm.mu.Unlock()
    sm.data[key] = value
}

func (sm *SafeMap) Get(key string) (int, bool) {
    sm.mu.RLock()
    defer sm.mu.RUnlock()
    value, exists := sm.data[key]
    return value, exists
}

// WaitGroup example
func worker(id int, wg *sync.WaitGroup) {
    defer wg.Done()
    
    fmt.Printf("Worker %d starting\n", id)
    time.Sleep(time.Duration(rand.Intn(1000)) * time.Millisecond)
    fmt.Printf("Worker %d finished\n", id)
}

// Once example
var (
    instance *Database
    once     sync.Once
)

type Database struct {
    connection string
}

func GetDatabaseInstance() *Database {
    once.Do(func() {
        fmt.Println("Creating database instance")
        instance = &Database{connection: "db://localhost:5432"}
    })
    return instance
}

// Atomic operations
func atomicExample() {
    var counter int64
    var wg sync.WaitGroup
    
    for i := 0; i < 10; i++ {
        wg.Add(1)
        go func() {
            defer wg.Done()
            for j := 0; j < 1000; j++ {
                atomic.AddInt64(&counter, 1)
            }
        }()
    }
    
    wg.Wait()
    fmt.Printf("Atomic counter final value: %d\n", atomic.LoadInt64(&counter))
}

// Channel-based synchronization
func channelSync() {
    done := make(chan bool, 1)
    
    go func() {
        fmt.Println("Working...")
        time.Sleep(1 * time.Second)
        fmt.Println("Done")
        done <- true
    }()
    
    <-done // Block until work is complete
}

// Worker pool pattern
func workerPool() {
    const numWorkers = 3
    jobs := make(chan int, 100)
    results := make(chan int, 100)
    
    // Start workers
    var wg sync.WaitGroup
    for w := 1; w <= numWorkers; w++ {
        wg.Add(1)
        go func(id int) {
            defer wg.Done()
            for j := range jobs {
                fmt.Printf("Worker %d processing job %d\n", id, j)
                time.Sleep(100 * time.Millisecond)
                results <- j * 2
            }
        }(w)
    }
    
    // Send jobs
    go func() {
        for j := 1; j <= 9; j++ {
            jobs <- j
        }
        close(jobs)
    }()
    
    // Close results channel when all workers are done
    go func() {
        wg.Wait()
        close(results)
    }()
    
    // Collect results
    for result := range results {
        fmt.Printf("Result: %d\n", result)
    }
}

func main() {
    // Mutex example
    counter := &SafeCounter{}
    var wg sync.WaitGroup
    
    for i := 0; i < 10; i++ {
        wg.Add(1)
        go func() {
            defer wg.Done()
            for j := 0; j < 100; j++ {
                counter.Increment()
            }
        }()
    }
    
    wg.Wait()
    fmt.Printf("Final counter value: %d\n", counter.Value())
    
    // RWMutex example
    safeMap := NewSafeMap()
    safeMap.Set("key1", 100)
    
    value, exists := safeMap.Get("key1")
    if exists {
        fmt.Printf("key1: %d\n", value)
    }
    
    // WaitGroup example
    var workerWG sync.WaitGroup
    for i := 1; i <= 5; i++ {
        workerWG.Add(1)
        go worker(i, &workerWG)
    }
    workerWG.Wait()
    fmt.Println("All workers finished")
    
    // Once example
    db1 := GetDatabaseInstance()
    db2 := GetDatabaseInstance()
    fmt.Printf("Same instance: %v\n", db1 == db2)
    
    // Atomic operations
    atomicExample()
    
    // Channel synchronization
    channelSync()
    
    // Worker pool
    workerPool()
}
```

### Context Package

```go
package main

import (
    "context"
    "fmt"
    "time"
)

// Context with timeout
func doWork(ctx context.Context, name string) {
    for {
        select {
        case <-ctx.Done():
            fmt.Printf("%s: Work cancelled: %v\n", name, ctx.Err())
            return
        default:
            fmt.Printf("%s: Working...\n", name)
            time.Sleep(500 * time.Millisecond)
        }
    }
}

// Context with values
func contextWithValues() {
    ctx := context.Background()
    ctx = context.WithValue(ctx, "userID", "12345")
    ctx = context.WithValue(ctx, "requestID", "req-789")
    
    processRequest(ctx)
}

func processRequest(ctx context.Context) {
    userID := ctx.Value("userID")
    requestID := ctx.Value("requestID")
    
    fmt.Printf("Processing request %v for user %v\n", requestID, userID)
}

// HTTP-like handler with context
func handleRequest(ctx context.Context) error {
    // Simulate some work
    select {
    case <-time.After(2 * time.Second):
        fmt.Println("Request completed successfully")
        return nil
    case <-ctx.Done():
        fmt.Printf("Request cancelled: %v\n", ctx.Err())
        return ctx.Err()
    }
}

func main() {
    // Context with timeout
    ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
    defer cancel()
    
    go doWork(ctx, "Worker1")
    go doWork(ctx, "Worker2")
    
    time.Sleep(3 * time.Second)
    
    // Context with cancellation
    ctx2, cancel2 := context.WithCancel(context.Background())
    
    go doWork(ctx2, "Worker3")
    
    time.Sleep(1 * time.Second)
    cancel2() // Cancel work
    time.Sleep(1 * time.Second)
    
    // Context with values
    contextWithValues()
    
    // Context with deadline
    deadline := time.Now().Add(1 * time.Second)
    ctx3, cancel3 := context.WithDeadline(context.Background(), deadline)
    defer cancel3()
    
    err := handleRequest(ctx3)
    if err != nil {
        fmt.Printf("Request failed: %v\n", err)
    }
}
```

---

## Error Handling

### Basic Error Handling

```go
package main

import (
    "errors"
    "fmt"
    "strconv"
)

// Custom error type
type ValidationError struct {
    Field   string
    Value   interface{}
    Message string
}

func (ve ValidationError) Error() string {
    return fmt.Sprintf("validation failed for field '%s' with value '%v': %s", 
        ve.Field, ve.Value, ve.Message)
}

// Multiple error types
type NotFoundError struct {
    Resource string
    ID       string
}

func (nfe NotFoundError) Error() string {
    return fmt.Sprintf("%s with ID '%s' not found", nfe.Resource, nfe.ID)
}

type AuthorizationError struct {
    User   string
    Action string
}

func (ae AuthorizationError) Error() string {
    return fmt.Sprintf("user '%s' not authorized to perform action '%s'", ae.User, ae.Action)
}

// Function that returns different error types
func processUser(userID string, action string) (*User, error) {
    if userID == "" {
        return nil, ValidationError{
            Field:   "userID",
            Value:   userID,
            Message: "cannot be empty",
        }
    }
    
    if userID == "404" {
        return nil, NotFoundError{
            Resource: "User",
            ID:       userID,
        }
    }
    
    if action == "admin" && userID != "admin" {
        return nil, AuthorizationError{
            User:   userID,
            Action: action,
        }
    }
    
    return &User{ID: userID, Name: "User " + userID}, nil
}

type User struct {
    ID   string
    Name string
}

// Error wrapping
func parseAndValidate(input string) (int, error) {
    num, err := strconv.Atoi(input)
    if err != nil {
        return 0, fmt.Errorf("failed to parse input '%s': %w", input, err)
    }
    
    if num < 0 {
        return 0, fmt.Errorf("validation failed: number must be positive, got %d", num)
    }
    
    return num, nil
}

// Sentinel errors
var (
    ErrInvalidInput = errors.New("invalid input")
    ErrNotFound     = errors.New("not found")
    ErrUnauthorized = errors.New("unauthorized")
)

func businessLogic(input string) error {
    if input == "" {
        return ErrInvalidInput
    }
    
    if input == "missing" {
        return ErrNotFound
    }
    
    if input == "forbidden" {
        return ErrUnauthorized
    }
    
    return nil
}

// Error handling patterns
func handleErrors() {
    // Type assertion for custom errors
    _, err := processUser("", "read")
    if err != nil {
        switch e := err.(type) {
        case ValidationError:
            fmt.Printf("Validation error: %s\n", e.Error())
        case NotFoundError:
            fmt.Printf("Not found error: %s\n", e.Error())
        case AuthorizationError:
            fmt.Printf("Authorization error: %s\n", e.Error())
        default:
            fmt.Printf("Unknown error: %s\n", err.Error())
        }
    }
    
    // Error wrapping and unwrapping
    _, err = parseAndValidate("abc")
    if err != nil {
        fmt.Printf("Parse error: %s\n", err.Error())
        
        // Unwrap to get the original error
        if unwrapped := errors.Unwrap(err); unwrapped != nil {
            fmt.Printf("Original error: %s\n", unwrapped.Error())
        }
    }
    
    // Sentinel error checking
    err = businessLogic("")
    if errors.Is(err, ErrInvalidInput) {
        fmt.Println("Handling invalid input error")
    }
    
    err = businessLogic("missing")
    if errors.Is(err, ErrNotFound) {
        fmt.Println("Handling not found error")
    }
}

// Panic and recover
func recoverExample() {
    defer func() {
        if r := recover(); r != nil {
            fmt.Printf("Recovered from panic: %v\n", r)
        }
    }()
    
    fmt.Println("About to panic")
    panic("Something went wrong!")
    fmt.Println("This won't be printed")
}

// Error aggregation
type MultiError struct {
    Errors []error
}

func (me MultiError) Error() string {
    if len(me.Errors) == 0 {
        return "no errors"
    }
    
    result := fmt.Sprintf("%d errors occurred:", len(me.Errors))
    for i, err := range me.Errors {
        result += fmt.Sprintf("\n  %d: %s", i+1, err.Error())
    }
    return result
}

func validateFields(data map[string]string) error {
    var errs []error
    
    if data["name"] == "" {
        errs = append(errs, ValidationError{
            Field:   "name",
            Value:   data["name"],
            Message: "cannot be empty",
        })
    }
    
    if data["email"] == "" {
        errs = append(errs, ValidationError{
            Field:   "email",
            Value:   data["email"],
            Message: "cannot be empty",
        })
    }
    
    age, err := strconv.Atoi(data["age"])
    if err != nil {
        errs = append(errs, ValidationError{
            Field:   "age",
            Value:   data["age"],
            Message: "must be a valid number",
        })
    } else if age < 0 {
        errs = append(errs, ValidationError{
            Field:   "age",
            Value:   age,
            Message: "must be positive",
        })
    }
    
    if len(errs) > 0 {
        return MultiError{Errors: errs}
    }
    
    return nil
}

func main() {
    // Handle different error types
    handleErrors()
    
    // Panic and recover
    recoverExample()
    fmt.Println("Program continues after panic recovery")
    
    // Error aggregation
    data := map[string]string{
        "name":  "",
        "email": "",
        "age":   "invalid",
    }
    
    if err := validateFields(data); err != nil {
        fmt.Printf("Validation failed:\n%s\n", err.Error())
    }
}
```

---

## Advanced Topics

### Reflection

```go
package main

import (
    "fmt"
    "reflect"
)

type Person struct {
    Name string `json:"name" db:"full_name"`
    Age  int    `json:"age" db:"person_age"`
}

func (p Person) Greet() string {
    return fmt.Sprintf("Hello, I'm %s", p.Name)
}

func (p *Person) SetAge(age int) {
    p.Age = age
}

func inspectType(obj interface{}) {
    t := reflect.TypeOf(obj)
    v := reflect.ValueOf(obj)
    
    fmt.Printf("Type: %v\n", t)
    fmt.Printf("Kind: %v\n", t.Kind())
    fmt.Printf("Value: %v\n", v)
    
    if t.Kind() == reflect.Struct {
        fmt.Println("Fields:")
        for i := 0; i < t.NumField(); i++ {
            field := t.Field(i)
            value := v.Field(i)
            
            fmt.Printf("  %s: %v (type: %v)\n", field.Name, value.Interface(), field.Type)
            
            // Print tags
            if tag := field.Tag.Get("json"); tag != "" {
                fmt.Printf("    JSON tag: %s\n", tag)
            }
            if tag := field.Tag.Get("db"); tag != "" {
                fmt.Printf("    DB tag: %s\n", tag)
            }
        }
        
        fmt.Println("Methods:")
        for i := 0; i < t.NumMethod(); i++ {
            method := t.Method(i)
            fmt.Printf("  %s: %v\n", method.Name, method.Type)
        }
    }
}

func modifyValue(obj interface{}) {
    v := reflect.ValueOf(obj)
    
    if v.Kind() != reflect.Ptr {
        fmt.Println("Cannot modify non-pointer value")
        return
    }
    
    v = v.Elem() // Dereference pointer
    
    if v.Kind() == reflect.Struct {
        nameField := v.FieldByName("Name")
        if nameField.IsValid() && nameField.CanSet() {
            nameField.SetString("Modified Name")
        }
        
        ageField := v.FieldByName("Age")
        if ageField.IsValid() && ageField.CanSet() {
            ageField.SetInt(99)
        }
    }
}

func callMethod(obj interface{}, methodName string, args ...interface{}) {
    v := reflect.ValueOf(obj)
    method := v.MethodByName(methodName)
    
    if !method.IsValid() {
        fmt.Printf("Method %s not found\n", methodName)
        return
    }
    
    var reflectArgs []reflect.Value
    for _, arg := range args {
        reflectArgs = append(reflectArgs, reflect.ValueOf(arg))
    }
    
    results := method.Call(reflectArgs)
    
    fmt.Printf("Method %s returned:\n", methodName)
    for i, result := range results {
        fmt.Printf("  Result %d: %v\n", i, result.Interface())
    }
}

func main() {
    person := Person{Name: "Alice", Age: 30}
    
    // Inspect type
    fmt.Println("=== Type Inspection ===")
    inspectType(person)
    
    // Modify value using reflection
    fmt.Println("\n=== Value Modification ===")
    fmt.Printf("Before: %+v\n", person)
    modifyValue(&person)
    fmt.Printf("After: %+v\n", person)
    
    // Call method using reflection
    fmt.Println("\n=== Method Calling ===")
    callMethod(person, "Greet")
    callMethod(&person, "SetAge", 25)
    fmt.Printf("After SetAge: %+v\n", person)
}
```

### Generics (Go 1.18+)

```go
package main

import (
    "fmt"
    "golang.org/x/exp/constraints"
)

// Generic function with type constraint
func Max[T constraints.Ordered](a, b T) T {
    if a > b {
        return a
    }
    return b
}

// Generic slice functions
func Filter[T any](slice []T, predicate func(T) bool) []T {
    var result []T
    for _, item := range slice {
        if predicate(item) {
            result = append(result, item)
        }
    }
    return result
}

func Map[T any, R any](slice []T, mapper func(T) R) []R {
    result := make([]R, len(slice))
    for i, item := range slice {
        result[i] = mapper(item)
    }
    return result
}

func Reduce[T any, R any](slice []T, initial R, reducer func(R, T) R) R {
    result := initial
    for _, item := range slice {
        result = reducer(result, item)
    }
    return result
}

// Generic data structures
type Stack[T any] struct {
    items []T
}

func NewStack[T any]() *Stack[T] {
    return &Stack[T]{
        items: make([]T, 0),
    }
}

func (s *Stack[T]) Push(item T) {
    s.items = append(s.items, item)
}

func (s *Stack[T]) Pop() (T, bool) {
    if len(s.items) == 0 {
        var zero T
        return zero, false
    }
    
    index := len(s.items) - 1
    item := s.items[index]
    s.items = s.items[:index]
    return item, true
}

func (s *Stack[T]) Peek() (T, bool) {
    if len(s.items) == 0 {
        var zero T
        return zero, false
    }
    return s.items[len(s.items)-1], true
}

func (s *Stack[T]) IsEmpty() bool {
    return len(s.items) == 0
}

// Generic interface
type Comparable[T any] interface {
    Compare(other T) int
}

type Person struct {
    Name string
    Age  int
}

func (p Person) Compare(other Person) int {
    if p.Age < other.Age {
        return -1
    } else if p.Age > other.Age {
        return 1
    }
    return 0
}

func Sort[T Comparable[T]](slice []T) {
    for i := 0; i < len(slice); i++ {
        for j := i + 1; j < len(slice); j++ {
            if slice[i].Compare(slice[j]) > 0 {
                slice[i], slice[j] = slice[j], slice[i]
            }
        }
    }
}

// Type constraints
type Numeric interface {
    constraints.Integer | constraints.Float
}

func Sum[T Numeric](numbers []T) T {
    var sum T
    for _, num := range numbers {
        sum += num
    }
    return sum
}

func main() {
    // Generic functions
    fmt.Printf("Max(10, 20): %d\n", Max(10, 20))
    fmt.Printf("Max(3.14, 2.71): %.2f\n", Max(3.14, 2.71))
    fmt.Printf("Max(\"apple\", \"banana\"): %s\n", Max("apple", "banana"))
    
    // Generic slice operations
    numbers := []int{1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
    
    evenNumbers := Filter(numbers, func(n int) bool {
        return n%2 == 0
    })
    fmt.Printf("Even numbers: %v\n", evenNumbers)
    
    squared := Map(numbers, func(n int) int {
        return n * n
    })
    fmt.Printf("Squared: %v\n", squared)
    
    sum := Reduce(numbers, 0, func(acc, n int) int {
        return acc + n
    })
    fmt.Printf("Sum: %d\n", sum)
    
    // Generic data structure
    intStack := NewStack[int]()
    intStack.Push(1)
    intStack.Push(2)
    intStack.Push(3)
    
    for !intStack.IsEmpty() {
        if item, ok := intStack.Pop(); ok {
            fmt.Printf("Popped: %d\n", item)
        }
    }
    
    stringStack := NewStack[string]()
    stringStack.Push("hello")
    stringStack.Push("world")
    
    if item, ok := stringStack.Peek(); ok {
        fmt.Printf("Peeked: %s\n", item)
    }
    
    // Generic interface usage
    people := []Person{
        {Name: "Alice", Age: 30},
        {Name: "Bob", Age: 25},
        {Name: "Charlie", Age: 35},
    }
    
    fmt.Printf("Before sorting: %v\n", people)
    Sort(people)
    fmt.Printf("After sorting: %v\n", people)
    
    // Numeric constraint
    intSum := Sum([]int{1, 2, 3, 4, 5})
    floatSum := Sum([]float64{1.1, 2.2, 3.3, 4.4, 5.5})
    
    fmt.Printf("Int sum: %d\n", intSum)
    fmt.Printf("Float sum: %.2f\n", floatSum)
}
```

---

## Interview Questions

### Q1: Explain the difference between channels and mutexes

**Answer:**
```go
// Channels - for communication between goroutines
func channelExample() {
    ch := make(chan int)
    
    go func() {
        ch <- 42 // Send data
    }()
    
    value := <-ch // Receive data
    fmt.Printf("Received: %d\n", value)
}

// Mutexes - for protecting shared state
func mutexExample() {
    var mu sync.Mutex
    var counter int
    
    increment := func() {
        mu.Lock()
        defer mu.Unlock()
        counter++
    }
    
    var wg sync.WaitGroup
    for i := 0; i < 10; i++ {
        wg.Add(1)
        go func() {
            defer wg.Done()
            increment()
        }()
    }
    
    wg.Wait()
    fmt.Printf("Counter: %d\n", counter)
}

// Rule of thumb: Use channels for communication, mutexes for state protection
```

### Q2: What happens when you write to a closed channel?

**Answer:**
```go
func closedChannelExample() {
    ch := make(chan int, 1)
    close(ch)
    
    // Reading from closed channel returns zero value and false
    value, ok := <-ch
    fmt.Printf("Read from closed channel: value=%d, ok=%v\n", value, ok)
    
    // Writing to closed channel causes panic
    defer func() {
        if r := recover(); r != nil {
            fmt.Printf("Panic recovered: %v\n", r)
        }
    }()
    
    ch <- 42 // This will panic
}
```

### Q3: How do you implement a timeout for a goroutine?

**Answer:**
```go
func timeoutExample() {
    result := make(chan string, 1)
    
    go func() {
        time.Sleep(2 * time.Second) // Simulate work
        result <- "work completed"
    }()
    
    select {
    case res := <-result:
        fmt.Printf("Result: %s\n", res)
    case <-time.After(1 * time.Second):
        fmt.Println("Operation timed out")
    }
}

// Using context for cancellation
func contextTimeoutExample() {
    ctx, cancel := context.WithTimeout(context.Background(), 1*time.Second)
    defer cancel()
    
    go doWork(ctx, "Worker")
    
    time.Sleep(2 * time.Second)
}
```

### Q4: What's the difference between value and pointer receivers?

**Answer:**
```go
type Counter struct {
    count int
}

// Value receiver - receives a copy
func (c Counter) GetCount() int {
    return c.count
}

// Value receiver trying to modify (won't work)
func (c Counter) IncrementBroken() {
    c.count++ // This modifies the copy, not the original
}

// Pointer receiver - receives a pointer to the original
func (c *Counter) Increment() {
    c.count++ // This modifies the original
}

func receiverExample() {
    counter := Counter{count: 0}
    
    counter.IncrementBroken()
    fmt.Printf("After broken increment: %d\n", counter.GetCount()) // Still 0
    
    counter.Increment()
    fmt.Printf("After pointer increment: %d\n", counter.GetCount()) // Now 1
    
    // Go automatically handles pointer/value conversion
    counterPtr := &Counter{count: 10}
    fmt.Printf("Pointer count: %d\n", counterPtr.GetCount()) // Works even though GetCount has value receiver
}
```

### Q5: How do interfaces work internally?

**Answer:**
```go
// Interface internal structure (conceptual)
type iface struct {
    tab  *itab       // Type information
    data unsafe.Pointer // Actual data
}

type itab struct {
    inter *interfacetype // Interface type
    _type *_type        // Concrete type
    fun   [1]uintptr    // Method implementations
}

func interfaceInternals() {
    var w io.Writer
    
    // w is nil interface
    fmt.Printf("w == nil: %v\n", w == nil) // true
    
    var buf *bytes.Buffer // nil pointer
    w = buf               // Now w contains (*bytes.Buffer, nil)
    
    fmt.Printf("w == nil: %v\n", w == nil) // false! (type is not nil)
    fmt.Printf("w is nil pointer: %v\n", w == (*bytes.Buffer)(nil)) // true
    
    // Proper nil check
    if w == nil || reflect.ValueOf(w).IsNil() {
        fmt.Println("Writer is effectively nil")
    }
    
    // Type assertion
    if buffer, ok := w.(*bytes.Buffer); ok {
        fmt.Printf("Successfully asserted to *bytes.Buffer: %v\n", buffer == nil)
    }
}
```

## 🎯 Key Takeaways for Interview

1. **Understand Go's concurrency model**: Goroutines, channels, and select statements
2. **Know when to use pointers vs values**: Performance and mutation considerations
3. **Master interface design**: Implicit implementation and composition
4. **Understand memory management**: Stack vs heap allocation
5. **Practice error handling patterns**: Custom errors, wrapping, and sentinel errors
6. **Be familiar with the standard library**: especially `context`, `sync`, and `reflect` packages

---

## Interview Questions and Answers

| # | Difficulty | Question | Answer |
|---|------------|----------|---------|
| 1 | Easy | What is Go? | Go is a statically typed, compiled programming language developed by Google. It's designed for simplicity, efficiency, and excellent concurrency support. |
| 2 | Easy | How do you declare a variable in Go? | Using `var name type` or short declaration `:=`. Example: `var x int = 5` or `x := 5` |
| 3 | Easy | What are the basic data types in Go? | int, float64, string, bool, byte, rune. Arrays, slices, maps, channels, pointers, structs, interfaces, functions |
| 4 | Easy | How do you create a slice in Go? | `slice := []int{1, 2, 3}` or `slice := make([]int, length, capacity)` |
| 5 | Easy | What is the difference between array and slice? | Arrays have fixed size, slices are dynamic. Arrays are values, slices are references to underlying arrays. |
| 6 | Easy | How do you iterate over a slice? | Using `for i, v := range slice` or `for i := 0; i < len(slice); i++` |
| 7 | Easy | What is a map in Go? | A map is a key-value data structure, like `map[string]int{"key": 42}` |
| 8 | Easy | How do you check if a key exists in a map? | `value, ok := myMap["key"]` - ok is true if key exists |
| 9 | Easy | What is a pointer in Go? | A pointer holds the memory address of a variable. Declared with `*` and accessed with `&` |
| 10 | Easy | How do you define a function in Go? | `func functionName(params) returnType { }` |
| 11 | Easy | What is a struct in Go? | A struct is a collection of fields: `type Person struct { Name string; Age int }` |
| 12 | Easy | How do you create a struct instance? | `p := Person{Name: "John", Age: 30}` or `p := Person{"John", 30}` |
| 13 | Easy | What is an interface in Go? | An interface defines method signatures that types must implement. `type Writer interface { Write([]byte) error }` |
| 14 | Easy | What is the empty interface? | `interface{}` - can hold values of any type, similar to Object in other languages |
| 15 | Easy | How do you handle errors in Go? | Functions return error as last value. Check with `if err != nil { }` |
| 16 | Medium | What are goroutines? | Lightweight threads managed by Go runtime. Created with `go functionName()` |
| 17 | Medium | What are channels? | Channels are used for communication between goroutines. `ch := make(chan int)` |
| 18 | Medium | What is the difference between buffered and unbuffered channels? | Unbuffered channels block until both sender and receiver are ready. Buffered channels can hold values without blocking until full. |
| 19 | Medium | What is the select statement? | Select lets a goroutine wait on multiple channel operations. Non-blocking channel operations. |
| 20 | Medium | What is a method in Go? | A function with a receiver: `func (p Person) GetName() string { return p.Name }` |
| 21 | Medium | What is method set? | The set of methods associated with a type. Pointer receivers have larger method sets than value receivers. |
| 22 | Medium | What is embedding in Go? | Embedding allows composition by including one type in another: `type Manager struct { Person; Department string }` |
| 23 | Medium | What is type assertion? | Extracting underlying concrete value from interface: `value, ok := interfaceVar.(ConcreteType)` |
| 24 | Medium | What is type switch? | Switch statement on type: `switch v := i.(type) { case int: ... case string: ... }` |
| 25 | Medium | What are defer statements? | Defer delays execution until surrounding function returns. LIFO order. |
| 26 | Medium | What is panic and recover? | Panic stops normal execution, recover regains control. Used for error handling in exceptional cases. |
| 27 | Medium | What are closures in Go? | Anonymous functions that capture variables from outer scope |
| 28 | Medium | What is the init() function? | Special function that runs before main(), used for initialization |
| 29 | Medium | What are Go modules? | Dependency management system introduced in Go 1.11. go.mod file defines module |
| 30 | Medium | What is workspace mode vs module mode? | Workspace allows working with multiple modules, module mode works with single module |
| 31 | Hard | Explain Go memory model | Defines when reads of variable in one goroutine can observe writes in another. Happens-before relationship. |
| 32 | Hard | What are memory leaks in Go? | Goroutines not terminating, circular references, large slices holding references |
| 33 | Hard | How does Go garbage collector work? | Concurrent, tri-color mark-and-sweep collector. STW pauses minimized |
| 34 | Hard | What is escape analysis? | Compiler analysis determining if variable can be allocated on stack or must escape to heap |
| 35 | Hard | What are race conditions and how to detect them? | When multiple goroutines access shared data concurrently. Use `go run -race` to detect |
| 36 | Hard | What is sync.Mutex vs sync.RWMutex? | Mutex provides exclusive access, RWMutex allows multiple readers or single writer |
| 37 | Hard | What is sync.WaitGroup? | Waits for collection of goroutines to finish executing. Add(), Done(), Wait() |
| 38 | Hard | What is context package? | Carries deadlines, cancellation signals, and request-scoped values across API boundaries |
| 39 | Hard | What is context.WithTimeout vs context.WithCancel? | WithTimeout automatically cancels after duration, WithCancel requires manual cancellation |
| 40 | Hard | What are worker pools? | Pattern where fixed number of goroutines process jobs from channel |
| 41 | Hard | What is fan-in and fan-out pattern? | Fan-out: distribute work to multiple goroutines. Fan-in: combine results from multiple goroutines |
| 42 | Hard | What are atomic operations? | Low-level operations that complete without interruption. sync/atomic package |
| 43 | Hard | What is sync.Once? | Ensures function is executed only once across multiple goroutine calls |
| 44 | Hard | What is reflection in Go? | Runtime inspection of types and values using reflect package |
| 45 | Hard | What are unsafe operations? | Direct memory access bypassing Go's type safety. unsafe package |
| 46 | Hard | How to implement custom sorting? | Implement sort.Interface (Len, Less, Swap) or use sort.Slice with comparison function |
| 47 | Hard | What is CGO? | Mechanism to call C code from Go using `import "C"` |
| 48 | Hard | What are build constraints? | Conditional compilation using `// +build` tags |
| 49 | Hard | What is Go assembly? | Low-level assembly language for Go runtime and performance-critical code |
| 50 | Hard | How to optimize Go performance? | Profiling with pprof, reducing allocations, efficient algorithms, proper concurrency patterns |
| 51 | Expert | Explain Go scheduler | M:N scheduler maps M goroutines to N OS threads. Work-stealing algorithm |
| 52 | Expert | What is GMP model? | G (goroutine), M (machine/OS thread), P (processor/logical CPU) |
| 53 | Expert | How does channel implementation work internally? | Uses hchan struct with circular buffer, mutex, and goroutine queues |
| 54 | Expert | What are finalizers? | Functions run by GC before object deletion. runtime.SetFinalizer() |
| 55 | Expert | How to implement custom memory allocator? | Use unsafe package and manage memory manually, though rarely needed |
