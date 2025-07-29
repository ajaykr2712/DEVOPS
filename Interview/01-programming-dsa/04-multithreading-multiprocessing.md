# ⚡ Multithreading vs Multiprocessing - Complete Guide

## 📚 Table of Contents
1. [Threading vs Processing Concepts](#threading-vs-processing-concepts)
2. [Python Threading](#python-threading)
3. [Python Multiprocessing](#python-multiprocessing)
4. [Go Concurrency](#go-concurrency)
5. [Performance Comparisons](#performance-comparisons)
6. [Best Practices](#best-practices)
7. [Interview Questions](#interview-questions)
8. [Interview Questions and Answers](#interview-questions-and-answers)

---

## Threading vs Processing Concepts

### Key Differences

| Aspect | Threading | Multiprocessing |
|--------|-----------|-----------------|
| **Memory** | Shared memory space | Separate memory spaces |
| **Communication** | Shared variables, locks | IPC, pipes, queues |
| **Overhead** | Lower creation overhead | Higher creation overhead |
| **CPU Bound** | Limited by GIL (Python) | True parallelism |
| **I/O Bound** | Excellent performance | Good but overkill |
| **Debugging** | Harder due to race conditions | Easier to debug |
| **Fault Tolerance** | One thread crash affects all | Process isolation |

### When to Use What

```python
# Use Threading for:
# - I/O bound tasks (file operations, network requests)
# - Tasks that need shared state
# - Lightweight concurrency

# Use Multiprocessing for:
# - CPU bound tasks (mathematical computations)
# - Tasks that can be parallelized
# - When you need fault isolation
```

---

## Python Threading

### Basic Threading Concepts

```python
import threading
import time
import queue
from concurrent.futures import ThreadPoolExecutor
import requests

class ThreadingExamples:
    
    def basic_threading(self):
        """Basic thread creation and management"""
        
        def worker(name, delay):
            for i in range(3):
                print(f"Worker {name}: Task {i+1}")
                time.sleep(delay)
            print(f"Worker {name}: Finished")
        
        # Create and start threads
        threads = []
        for i in range(3):
            thread = threading.Thread(
                target=worker, 
                args=(f"Thread-{i}", 0.5),
                name=f"WorkerThread-{i}"
            )
            threads.append(thread)
            thread.start()
        
        # Wait for all threads to complete
        for thread in threads:
            thread.join()
        
        print("All threads completed")
    
    def thread_with_class(self):
        """Thread using class inheritance"""
        
        class WorkerThread(threading.Thread):
            def __init__(self, name, work_items):
                super().__init__()
                self.name = name
                self.work_items = work_items
                self.result = []
            
            def run(self):
                for item in self.work_items:
                    processed = self.process_item(item)
                    self.result.append(processed)
                    time.sleep(0.1)  # Simulate work
            
            def process_item(self, item):
                return f"Processed-{item}"
        
        # Create and start worker threads
        workers = []
        for i in range(3):
            worker = WorkerThread(f"Worker-{i}", list(range(i*3, (i+1)*3)))
            workers.append(worker)
            worker.start()
        
        # Wait and collect results
        for worker in workers:
            worker.join()
            print(f"{worker.name} results: {worker.result}")
    
    def thread_synchronization(self):
        """Thread synchronization with locks and conditions"""
        
        # Shared resources
        shared_counter = 0
        shared_data = []
        
        # Synchronization primitives
        counter_lock = threading.Lock()
        data_lock = threading.RLock()  # Reentrant lock
        condition = threading.Condition()
        
        def increment_counter():
            global shared_counter
            for _ in range(1000):
                with counter_lock:
                    shared_counter += 1
        
        def add_data(worker_id):
            for i in range(5):
                with data_lock:
                    shared_data.append(f"Worker-{worker_id}-Item-{i}")
                time.sleep(0.01)
        
        def consumer():
            consumed = []
            with condition:
                while len(consumed) < 15:  # Wait for all items
                    condition.wait()
                    with data_lock:
                        if shared_data:
                            item = shared_data.pop(0)
                            consumed.append(item)
            print(f"Consumed {len(consumed)} items")
        
        def producer(worker_id):
            for i in range(5):
                with condition:
                    with data_lock:
                        shared_data.append(f"Producer-{worker_id}-Item-{i}")
                    condition.notify_all()
                time.sleep(0.01)
        
        # Test counter with locks
        counter_threads = []
        for i in range(5):
            thread = threading.Thread(target=increment_counter)
            counter_threads.append(thread)
            thread.start()
        
        for thread in counter_threads:
            thread.join()
        
        print(f"Final counter value: {shared_counter}")  # Should be 5000
        
        # Test producer-consumer
        consumer_thread = threading.Thread(target=consumer)
        consumer_thread.start()
        
        producer_threads = []
        for i in range(3):
            thread = threading.Thread(target=producer, args=(i,))
            producer_threads.append(thread)
            thread.start()
        
        for thread in producer_threads:
            thread.join()
        
        consumer_thread.join()
    
    def thread_pool_example(self):
        """Using ThreadPoolExecutor for better thread management"""
        
        def fetch_url(url):
            """Simulate HTTP request"""
            try:
                response = requests.get(url, timeout=5)
                return f"URL: {url}, Status: {response.status_code}, Length: {len(response.content)}"
            except Exception as e:
                return f"URL: {url}, Error: {str(e)}"
        
        def cpu_intensive_task(n):
            """CPU intensive task"""
            total = 0
            for i in range(n):
                total += i ** 2
            return total
        
        urls = [
            'https://httpbin.org/delay/1',
            'https://httpbin.org/delay/2',
            'https://jsonplaceholder.typicode.com/posts/1',
            'https://jsonplaceholder.typicode.com/posts/2'
        ]
        
        # I/O bound tasks - good for threading
        print("I/O Bound Tasks (Threading):")
        start_time = time.time()
        
        with ThreadPoolExecutor(max_workers=4) as executor:
            future_to_url = {executor.submit(fetch_url, url): url for url in urls}
            
            for future in future_to_url:
                result = future.result()
                print(result)
        
        print(f"Threading time: {time.time() - start_time:.2f} seconds")
        
        # CPU bound tasks - poor performance with threading due to GIL
        print("\nCPU Bound Tasks (Threading - Poor Performance):")
        tasks = [100000] * 4
        
        start_time = time.time()
        with ThreadPoolExecutor(max_workers=4) as executor:
            results = list(executor.map(cpu_intensive_task, tasks))
        
        print(f"Threading CPU time: {time.time() - start_time:.2f} seconds")
        print(f"Results: {results}")
    
    def thread_queue_communication(self):
        """Thread communication using queues"""
        
        # Different types of queues
        task_queue = queue.Queue()          # FIFO
        priority_queue = queue.PriorityQueue()  # Priority based
        lifo_queue = queue.LifoQueue()      # LIFO (Stack)
        
        def producer(q, items):
            for item in items:
                q.put(item)
                print(f"Produced: {item}")
                time.sleep(0.1)
            q.put(None)  # Sentinel to signal completion
        
        def consumer(q, name):
            consumed = []
            while True:
                item = q.get()
                if item is None:
                    q.task_done()
                    break
                
                consumed.append(item)
                print(f"Consumer {name} consumed: {item}")
                time.sleep(0.2)
                q.task_done()
            
            print(f"Consumer {name} finished. Total consumed: {len(consumed)}")
        
        # FIFO Queue example
        print("FIFO Queue Example:")
        items = [f"item-{i}" for i in range(5)]
        
        producer_thread = threading.Thread(target=producer, args=(task_queue, items))
        consumer_thread = threading.Thread(target=consumer, args=(task_queue, "A"))
        
        producer_thread.start()
        consumer_thread.start()
        
        producer_thread.join()
        consumer_thread.join()
        
        # Priority Queue example
        print("\nPriority Queue Example:")
        priority_items = [(1, "High Priority"), (3, "Low Priority"), (2, "Medium Priority")]
        
        for priority, item in priority_items:
            priority_queue.put((priority, item))
        
        while not priority_queue.empty():
            priority, item = priority_queue.get()
            print(f"Processing: {item} (Priority: {priority})")
    
    def advanced_threading_patterns(self):
        """Advanced threading patterns"""
        
        # Worker Pool Pattern
        class WorkerPool:
            def __init__(self, num_workers=4):
                self.num_workers = num_workers
                self.task_queue = queue.Queue()
                self.workers = []
                self.running = True
                
                # Start workers
                for i in range(num_workers):
                    worker = threading.Thread(target=self._worker, args=(i,))
                    worker.daemon = True
                    worker.start()
                    self.workers.append(worker)
            
            def _worker(self, worker_id):
                while self.running:
                    try:
                        task = self.task_queue.get(timeout=1)
                        if task is None:
                            break
                        
                        func, args, kwargs = task
                        try:
                            result = func(*args, **kwargs)
                            print(f"Worker {worker_id}: Task completed, result: {result}")
                        except Exception as e:
                            print(f"Worker {worker_id}: Task failed: {e}")
                        
                        self.task_queue.task_done()
                    except queue.Empty:
                        continue
            
            def submit_task(self, func, *args, **kwargs):
                self.task_queue.put((func, args, kwargs))
            
            def shutdown(self):
                self.running = False
                # Add sentinel values to wake up workers
                for _ in self.workers:
                    self.task_queue.put(None)
                
                for worker in self.workers:
                    worker.join()
        
        def sample_task(task_id, duration):
            time.sleep(duration)
            return f"Task {task_id} completed"
        
        # Use worker pool
        pool = WorkerPool(num_workers=3)
        
        # Submit tasks
        for i in range(10):
            pool.submit_task(sample_task, i, 0.5)
        
        # Wait for completion and shutdown
        pool.task_queue.join()
        pool.shutdown()
        
        # Barrier Example - wait for all threads to reach a point
        barrier = threading.Barrier(3)
        
        def worker_with_barrier(worker_id):
            print(f"Worker {worker_id}: Starting phase 1")
            time.sleep(worker_id)  # Different work times
            print(f"Worker {worker_id}: Finished phase 1, waiting at barrier")
            
            barrier.wait()  # Wait for all workers
            
            print(f"Worker {worker_id}: Starting phase 2")
            time.sleep(0.5)
            print(f"Worker {worker_id}: Finished phase 2")
        
        print("\nBarrier Example:")
        barrier_threads = []
        for i in range(3):
            thread = threading.Thread(target=worker_with_barrier, args=(i,))
            barrier_threads.append(thread)
            thread.start()
        
        for thread in barrier_threads:
            thread.join()

# Test threading examples
def test_threading():
    examples = ThreadingExamples()
    
    print("=== Basic Threading ===")
    examples.basic_threading()
    
    print("\n=== Thread with Class ===")
    examples.thread_with_class()
    
    print("\n=== Thread Synchronization ===")
    examples.thread_synchronization()
    
    print("\n=== Thread Queue Communication ===")
    examples.thread_queue_communication()
    
    print("\n=== Advanced Threading Patterns ===")
    examples.advanced_threading_patterns()

# test_threading()  # Uncomment to run
```

---

## Python Multiprocessing

### Basic Multiprocessing Concepts

```python
import multiprocessing
import time
import os
from multiprocessing import Process, Queue, Pipe, Value, Array
from multiprocessing import Pool, Manager, Lock
from concurrent.futures import ProcessPoolExecutor

class MultiprocessingExamples:
    
    def basic_multiprocessing(self):
        """Basic process creation and management"""
        
        def worker_process(name, numbers):
            """Worker process function"""
            print(f"Process {name} (PID: {os.getpid()}) starting")
            
            result = sum(x ** 2 for x in numbers)
            print(f"Process {name}: Sum of squares = {result}")
            
            time.sleep(1)
            print(f"Process {name} finished")
        
        # Create processes
        processes = []
        for i in range(3):
            numbers = list(range(i*100, (i+1)*100))
            process = Process(
                target=worker_process,
                args=(f"Worker-{i}", numbers),
                name=f"WorkerProcess-{i}"
            )
            processes.append(process)
            process.start()
        
        # Wait for all processes to complete
        for process in processes:
            process.join()
        
        print("All processes completed")
    
    def process_communication(self):
        """Inter-process communication using Queue and Pipe"""
        
        def producer(queue, items):
            """Producer process"""
            for item in items:
                queue.put(item)
                print(f"Producer: Added {item}")
                time.sleep(0.1)
            queue.put(None)  # Sentinel
        
        def consumer(queue, consumer_id):
            """Consumer process"""
            consumed = []
            while True:
                item = queue.get()
                if item is None:
                    break
                
                consumed.append(item)
                print(f"Consumer {consumer_id}: Consumed {item}")
                time.sleep(0.2)
            
            print(f"Consumer {consumer_id} finished. Total: {len(consumed)}")
        
        # Queue-based communication
        print("Queue-based Communication:")
        queue = Queue()
        items = [f"item-{i}" for i in range(10)]
        
        producer_process = Process(target=producer, args=(queue, items))
        consumer_processes = [
            Process(target=consumer, args=(queue, 1)),
            Process(target=consumer, args=(queue, 2))
        ]
        
        producer_process.start()
        for p in consumer_processes:
            p.start()
        
        producer_process.join()
        
        # Signal consumers to stop
        for _ in consumer_processes:
            queue.put(None)
        
        for p in consumer_processes:
            p.join()
        
        # Pipe-based communication
        print("\nPipe-based Communication:")
        
        def sender(conn, messages):
            for msg in messages:
                conn.send(msg)
                print(f"Sent: {msg}")
                time.sleep(0.1)
            conn.close()
        
        def receiver(conn):
            received = []
            try:
                while True:
                    msg = conn.recv()
                    received.append(msg)
                    print(f"Received: {msg}")
            except EOFError:
                pass
            
            print(f"Receiver finished. Total received: {len(received)}")
        
        parent_conn, child_conn = Pipe()
        messages = [f"message-{i}" for i in range(5)]
        
        sender_process = Process(target=sender, args=(child_conn, messages))
        receiver_process = Process(target=receiver, args=(parent_conn,))
        
        sender_process.start()
        receiver_process.start()
        
        sender_process.join()
        receiver_process.join()
    
    def shared_memory(self):
        """Shared memory between processes"""
        
        def worker_with_shared_memory(shared_value, shared_array, lock, worker_id):
            """Worker that modifies shared memory"""
            
            for i in range(5):
                with lock:
                    # Modify shared value
                    shared_value.value += 1
                    
                    # Modify shared array
                    shared_array[worker_id] += 1
                    
                    print(f"Worker {worker_id}: shared_value = {shared_value.value}, "
                          f"shared_array[{worker_id}] = {shared_array[worker_id]}")
                
                time.sleep(0.1)
        
        # Create shared memory objects
        shared_value = Value('i', 0)  # 'i' for integer
        shared_array = Array('i', [0] * 4)  # Array of integers
        lock = Lock()
        
        # Create processes
        processes = []
        for i in range(4):
            process = Process(
                target=worker_with_shared_memory,
                args=(shared_value, shared_array, lock, i)
            )
            processes.append(process)
            process.start()
        
        # Wait for completion
        for process in processes:
            process.join()
        
        print(f"Final shared_value: {shared_value.value}")
        print(f"Final shared_array: {list(shared_array)}")
    
    def process_pool_example(self):
        """Using process pools for parallel processing"""
        
        def cpu_intensive_task(n):
            """CPU intensive computation"""
            total = 0
            for i in range(n):
                total += i ** 2
            return total
        
        def factorial(n):
            """Calculate factorial"""
            if n <= 1:
                return 1
            result = 1
            for i in range(2, n + 1):
                result *= i
            return result
        
        numbers = [100000, 200000, 300000, 400000]
        
        # Using Pool.map()
        print("Process Pool with map():")
        start_time = time.time()
        
        with Pool(processes=4) as pool:
            results = pool.map(cpu_intensive_task, numbers)
        
        print(f"Results: {results}")
        print(f"Processing time: {time.time() - start_time:.2f} seconds")
        
        # Using Pool.starmap() for multiple arguments
        print("\nProcess Pool with starmap():")
        factorial_inputs = [(10,), (15,), (20,), (25,)]
        
        with Pool(processes=4) as pool:
            factorial_results = pool.starmap(factorial, factorial_inputs)
        
        print(f"Factorial results: {factorial_results}")
        
        # Using ProcessPoolExecutor (more modern approach)
        print("\nProcessPoolExecutor:")
        start_time = time.time()
        
        with ProcessPoolExecutor(max_workers=4) as executor:
            futures = [executor.submit(cpu_intensive_task, n) for n in numbers]
            executor_results = [future.result() for future in futures]
        
        print(f"Executor results: {executor_results}")
        print(f"Executor time: {time.time() - start_time:.2f} seconds")
    
    def manager_example(self):
        """Using Manager for shared objects"""
        
        def worker_with_manager(shared_dict, shared_list, worker_id):
            """Worker using manager objects"""
            
            # Add to shared dictionary
            shared_dict[f"worker_{worker_id}"] = f"data_from_worker_{worker_id}"
            
            # Add to shared list
            for i in range(3):
                shared_list.append(f"worker_{worker_id}_item_{i}")
                time.sleep(0.1)
            
            print(f"Worker {worker_id} completed")
        
        # Create manager and shared objects
        with Manager() as manager:
            shared_dict = manager.dict()
            shared_list = manager.list()
            
            # Create processes
            processes = []
            for i in range(3):
                process = Process(
                    target=worker_with_manager,
                    args=(shared_dict, shared_list, i)
                )
                processes.append(process)
                process.start()
            
            # Wait for completion
            for process in processes:
                process.join()
            
            print(f"Shared dictionary: {dict(shared_dict)}")
            print(f"Shared list: {list(shared_list)}")
    
    def performance_comparison(self):
        """Compare threading vs multiprocessing performance"""
        
        def cpu_bound_task(n):
            """CPU intensive task"""
            total = 0
            for i in range(n):
                total += i ** 2
            return total
        
        def io_bound_task(duration):
            """I/O bound task simulation"""
            time.sleep(duration)
            return f"Task completed after {duration} seconds"
        
        tasks = [500000] * 4
        io_tasks = [0.5] * 4
        
        # CPU bound - Sequential
        print("CPU Bound - Sequential:")
        start_time = time.time()
        sequential_results = [cpu_bound_task(n) for n in tasks]
        sequential_time = time.time() - start_time
        print(f"Sequential time: {sequential_time:.2f} seconds")
        
        # CPU bound - Multiprocessing
        print("CPU Bound - Multiprocessing:")
        start_time = time.time()
        with ProcessPoolExecutor(max_workers=4) as executor:
            mp_results = list(executor.map(cpu_bound_task, tasks))
        mp_time = time.time() - start_time
        print(f"Multiprocessing time: {mp_time:.2f} seconds")
        print(f"Speedup: {sequential_time / mp_time:.2f}x")
        
        # CPU bound - Threading (poor performance due to GIL)
        print("CPU Bound - Threading (Poor due to GIL):")
        start_time = time.time()
        with ThreadPoolExecutor(max_workers=4) as executor:
            thread_results = list(executor.map(cpu_bound_task, tasks))
        thread_time = time.time() - start_time
        print(f"Threading time: {thread_time:.2f} seconds")
        
        # I/O bound - Threading vs Multiprocessing
        print("\nI/O Bound Comparison:")
        
        # I/O bound - Sequential
        start_time = time.time()
        [io_bound_task(d) for d in io_tasks]
        io_sequential_time = time.time() - start_time
        print(f"I/O Sequential time: {io_sequential_time:.2f} seconds")
        
        # I/O bound - Threading
        start_time = time.time()
        with ThreadPoolExecutor(max_workers=4) as executor:
            list(executor.map(io_bound_task, io_tasks))
        io_thread_time = time.time() - start_time
        print(f"I/O Threading time: {io_thread_time:.2f} seconds")
        
        # I/O bound - Multiprocessing
        start_time = time.time()
        with ProcessPoolExecutor(max_workers=4) as executor:
            list(executor.map(io_bound_task, io_tasks))
        io_mp_time = time.time() - start_time
        print(f"I/O Multiprocessing time: {io_mp_time:.2f} seconds")

# Test multiprocessing examples
def test_multiprocessing():
    examples = MultiprocessingExamples()
    
    print("=== Basic Multiprocessing ===")
    examples.basic_multiprocessing()
    
    print("\n=== Process Communication ===")
    examples.process_communication()
    
    print("\n=== Shared Memory ===")
    examples.shared_memory()
    
    print("\n=== Process Pool ===")
    examples.process_pool_example()
    
    print("\n=== Manager Example ===")
    examples.manager_example()
    
    print("\n=== Performance Comparison ===")
    examples.performance_comparison()

# Uncomment to run
# if __name__ == "__main__":
#     test_multiprocessing()
```

---

## Go Concurrency

### Goroutines and Channels

```go
package main

import (
    "context"
    "fmt"
    "runtime"
    "sync"
    "time"
)

// Basic Goroutine Examples
func basicGoroutines() {
    fmt.Println("=== Basic Goroutines ===")
    
    // Simple goroutine
    go func() {
        for i := 0; i < 3; i++ {
            fmt.Printf("Goroutine: %d\n", i)
            time.Sleep(100 * time.Millisecond)
        }
    }()
    
    // Multiple goroutines
    var wg sync.WaitGroup
    
    for i := 0; i < 3; i++ {
        wg.Add(1)
        go func(id int) {
            defer wg.Done()
            for j := 0; j < 3; j++ {
                fmt.Printf("Worker %d: Task %d\n", id, j)
                time.Sleep(50 * time.Millisecond)
            }
        }(i)
    }
    
    time.Sleep(500 * time.Millisecond) // Let first goroutine finish
    wg.Wait() // Wait for workers
    fmt.Println("All goroutines completed")
}

// Channel Communication
func channelCommunication() {
    fmt.Println("\n=== Channel Communication ===")
    
    // Unbuffered channel
    ch := make(chan string)
    
    go func() {
        ch <- "Hello from goroutine"
    }()
    
    message := <-ch
    fmt.Println("Received:", message)
    
    // Buffered channel
    bufferedCh := make(chan int, 3)
    
    // Send without blocking
    bufferedCh <- 1
    bufferedCh <- 2
    bufferedCh <- 3
    
    // Receive all values
    for i := 0; i < 3; i++ {
        value := <-bufferedCh
        fmt.Printf("Buffered channel value: %d\n", value)
    }
    
    // Producer-Consumer pattern
    jobs := make(chan int, 5)
    results := make(chan int, 5)
    
    // Producer
    go func() {
        for i := 1; i <= 5; i++ {
            jobs <- i
        }
        close(jobs)
    }()
    
    // Consumer
    go func() {
        for job := range jobs {
            result := job * job
            results <- result
        }
        close(results)
    }()
    
    // Collect results
    for result := range results {
        fmt.Printf("Result: %d\n", result)
    }
}

// Select Statement Examples
func selectStatements() {
    fmt.Println("\n=== Select Statements ===")
    
    ch1 := make(chan string)
    ch2 := make(chan string)
    
    go func() {
        time.Sleep(1 * time.Second)
        ch1 <- "Channel 1"
    }()
    
    go func() {
        time.Sleep(2 * time.Second)
        ch2 <- "Channel 2"
    }()
    
    for i := 0; i < 2; i++ {
        select {
        case msg1 := <-ch1:
            fmt.Println("Received from ch1:", msg1)
        case msg2 := <-ch2:
            fmt.Println("Received from ch2:", msg2)
        case <-time.After(3 * time.Second):
            fmt.Println("Timeout!")
        }
    }
    
    // Non-blocking select with default
    ch := make(chan string, 1)
    
    select {
    case ch <- "message":
        fmt.Println("Sent message")
    default:
        fmt.Println("Channel not ready")
    }
    
    select {
    case msg := <-ch:
        fmt.Println("Received:", msg)
    default:
        fmt.Println("No message available")
    }
}

// Worker Pool Pattern
func workerPool() {
    fmt.Println("\n=== Worker Pool Pattern ===")
    
    const numWorkers = 3
    const numJobs = 9
    
    jobs := make(chan int, numJobs)
    results := make(chan int, numJobs)
    
    // Start workers
    var wg sync.WaitGroup
    for w := 1; w <= numWorkers; w++ {
        wg.Add(1)
        go worker(w, jobs, results, &wg)
    }
    
    // Send jobs
    for j := 1; j <= numJobs; j++ {
        jobs <- j
    }
    close(jobs)
    
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

func worker(id int, jobs <-chan int, results chan<- int, wg *sync.WaitGroup) {
    defer wg.Done()
    for job := range jobs {
        fmt.Printf("Worker %d processing job %d\n", id, job)
        time.Sleep(100 * time.Millisecond)
        results <- job * 2
    }
}

// Context for Cancellation
func contextExample() {
    fmt.Println("\n=== Context Example ===")
    
    ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
    defer cancel()
    
    go doWork(ctx, "Worker1")
    go doWork(ctx, "Worker2")
    
    time.Sleep(3 * time.Second)
}

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

// Advanced Concurrency Patterns
func advancedPatterns() {
    fmt.Println("\n=== Advanced Patterns ===")
    
    // Fan-out, Fan-in pattern
    fanOutFanIn()
    
    // Pipeline pattern
    pipeline()
}

func fanOutFanIn() {
    fmt.Println("Fan-out, Fan-in Pattern:")
    
    // Input generator
    input := make(chan int)
    go func() {
        for i := 1; i <= 10; i++ {
            input <- i
        }
        close(input)
    }()
    
    // Fan-out to multiple workers
    worker1 := fanOut(input, "Worker1")
    worker2 := fanOut(input, "Worker2")
    worker3 := fanOut(input, "Worker3")
    
    // Fan-in results
    results := fanIn(worker1, worker2, worker3)
    
    // Collect results
    for result := range results {
        fmt.Printf("Final result: %s\n", result)
    }
}

func fanOut(input <-chan int, name string) <-chan string {
    output := make(chan string)
    go func() {
        defer close(output)
        for num := range input {
            result := fmt.Sprintf("%s processed %d", name, num*num)
            output <- result
            time.Sleep(100 * time.Millisecond)
        }
    }()
    return output
}

func fanIn(inputs ...<-chan string) <-chan string {
    output := make(chan string)
    var wg sync.WaitGroup
    
    for _, input := range inputs {
        wg.Add(1)
        go func(ch <-chan string) {
            defer wg.Done()
            for value := range ch {
                output <- value
            }
        }(input)
    }
    
    go func() {
        wg.Wait()
        close(output)
    }()
    
    return output
}

func pipeline() {
    fmt.Println("\nPipeline Pattern:")
    
    // Stage 1: Generate numbers
    numbers := make(chan int)
    go func() {
        defer close(numbers)
        for i := 1; i <= 5; i++ {
            numbers <- i
        }
    }()
    
    // Stage 2: Square numbers
    squares := make(chan int)
    go func() {
        defer close(squares)
        for num := range numbers {
            squares <- num * num
        }
    }()
    
    // Stage 3: Add prefix
    results := make(chan string)
    go func() {
        defer close(results)
        for square := range squares {
            results <- fmt.Sprintf("Square: %d", square)
        }
    }()
    
    // Consume final results
    for result := range results {
        fmt.Println(result)
    }
}

func main() {
    fmt.Printf("GOMAXPROCS: %d\n", runtime.GOMAXPROCS(0))
    fmt.Printf("NumCPU: %d\n", runtime.NumCPU())
    
    basicGoroutines()
    channelCommunication()
    selectStatements()
    workerPool()
    contextExample()
    advancedPatterns()
    
    fmt.Println("\nAll examples completed")
}
```

---

## Performance Comparisons

### Benchmarking Threading vs Multiprocessing

```python
import time
import threading
import multiprocessing
from concurrent.futures import ThreadPoolExecutor, ProcessPoolExecutor
import numpy as np

class PerformanceBenchmarks:
    
    def __init__(self):
        self.cpu_bound_size = 1000000
        self.io_bound_delay = 0.1
        self.num_tasks = 8
    
    def cpu_intensive_task(self, n):
        """CPU intensive computation"""
        total = 0
        for i in range(n):
            total += i * i
        return total
    
    def io_intensive_task(self, delay):
        """I/O intensive simulation"""
        time.sleep(delay)
        return f"Task completed after {delay}s"
    
    def memory_intensive_task(self, size):
        """Memory intensive computation"""
        data = np.random.random(size)
        result = np.sum(data ** 2)
        return result
    
    def benchmark_cpu_bound(self):
        """Benchmark CPU bound tasks"""
        print("=== CPU Bound Task Benchmarks ===")
        
        tasks = [self.cpu_bound_size] * self.num_tasks
        
        # Sequential execution
        start_time = time.perf_counter()
        sequential_results = [self.cpu_intensive_task(n) for n in tasks]
        sequential_time = time.perf_counter() - start_time
        print(f"Sequential: {sequential_time:.2f}s")
        
        # Threading (poor performance due to GIL)
        start_time = time.perf_counter()
        with ThreadPoolExecutor(max_workers=self.num_tasks) as executor:
            thread_results = list(executor.map(self.cpu_intensive_task, tasks))
        thread_time = time.perf_counter() - start_time
        print(f"Threading: {thread_time:.2f}s (Speedup: {sequential_time/thread_time:.2f}x)")
        
        # Multiprocessing
        start_time = time.perf_counter()
        with ProcessPoolExecutor(max_workers=self.num_tasks) as executor:
            process_results = list(executor.map(self.cpu_intensive_task, tasks))
        process_time = time.perf_counter() - start_time
        print(f"Multiprocessing: {process_time:.2f}s (Speedup: {sequential_time/process_time:.2f}x)")
        
        # Verify results are the same
        assert sequential_results == thread_results == process_results
        print("✓ All results verified identical")
    
    def benchmark_io_bound(self):
        """Benchmark I/O bound tasks"""
        print("\n=== I/O Bound Task Benchmarks ===")
        
        tasks = [self.io_bound_delay] * self.num_tasks
        
        # Sequential execution
        start_time = time.perf_counter()
        sequential_results = [self.io_intensive_task(delay) for delay in tasks]
        sequential_time = time.perf_counter() - start_time
        print(f"Sequential: {sequential_time:.2f}s")
        
        # Threading (excellent performance)
        start_time = time.perf_counter()
        with ThreadPoolExecutor(max_workers=self.num_tasks) as executor:
            thread_results = list(executor.map(self.io_intensive_task, tasks))
        thread_time = time.perf_counter() - start_time
        print(f"Threading: {thread_time:.2f}s (Speedup: {sequential_time/thread_time:.2f}x)")
        
        # Multiprocessing (good but with overhead)
        start_time = time.perf_counter()
        with ProcessPoolExecutor(max_workers=self.num_tasks) as executor:
            process_results = list(executor.map(self.io_intensive_task, tasks))
        process_time = time.perf_counter() - start_time
        print(f"Multiprocessing: {process_time:.2f}s (Speedup: {sequential_time/process_time:.2f}x)")
        
        print("✓ I/O bound tasks completed")
    
    def benchmark_memory_usage(self):
        """Benchmark memory intensive tasks"""
        print("\n=== Memory Usage Benchmarks ===")
        
        import psutil
        import os
        
        def get_memory_usage():
            process = psutil.Process(os.getpid())
            return process.memory_info().rss / 1024 / 1024  # MB
        
        tasks = [100000] * 4  # Smaller for memory demo
        
        print(f"Initial memory usage: {get_memory_usage():.2f} MB")
        
        # Sequential execution
        start_memory = get_memory_usage()
        start_time = time.perf_counter()
        sequential_results = [self.memory_intensive_task(size) for size in tasks]
        sequential_time = time.perf_counter() - start_time
        end_memory = get_memory_usage()
        print(f"Sequential: {sequential_time:.2f}s, Memory: {end_memory - start_memory:.2f} MB")
        
        # Threading (shared memory)
        start_memory = get_memory_usage()
        start_time = time.perf_counter()
        with ThreadPoolExecutor(max_workers=4) as executor:
            thread_results = list(executor.map(self.memory_intensive_task, tasks))
        thread_time = time.perf_counter() - start_time
        end_memory = get_memory_usage()
        print(f"Threading: {thread_time:.2f}s, Memory: {end_memory - start_memory:.2f} MB")
        
        # Note: Multiprocessing memory usage is harder to measure as it uses separate processes
        print("Note: Multiprocessing uses separate memory spaces per process")
    
    def run_all_benchmarks(self):
        """Run all performance benchmarks"""
        print(f"Running benchmarks on {multiprocessing.cpu_count()} CPU cores")
        print(f"Tasks per benchmark: {self.num_tasks}")
        print("-" * 50)
        
        self.benchmark_cpu_bound()
        self.benchmark_io_bound()
        self.benchmark_memory_usage()

# Memory and Resource Management Examples
class ResourceManagement:
    
    def demonstrate_gil_impact(self):
        """Demonstrate Python GIL impact"""
        print("=== Python GIL Impact Demonstration ===")
        
        def cpu_task():
            # Pure Python computation (affected by GIL)
            total = 0
            for i in range(10000000):
                total += i
            return total
        
        def numpy_task():
            # NumPy computation (releases GIL)
            import numpy as np
            data = np.arange(10000000)
            return np.sum(data)
        
        # Pure Python with threading (GIL limited)
        start_time = time.perf_counter()
        with ThreadPoolExecutor(max_workers=4) as executor:
            futures = [executor.submit(cpu_task) for _ in range(4)]
            results = [f.result() for f in futures]
        python_thread_time = time.perf_counter() - start_time
        print(f"Pure Python Threading: {python_thread_time:.2f}s")
        
        # NumPy with threading (can release GIL)
        start_time = time.perf_counter()
        with ThreadPoolExecutor(max_workers=4) as executor:
            futures = [executor.submit(numpy_task) for _ in range(4)]
            results = [f.result() for f in futures]
        numpy_thread_time = time.perf_counter() - start_time
        print(f"NumPy Threading: {numpy_thread_time:.2f}s")
        
        # Multiprocessing comparison
        start_time = time.perf_counter()
        with ProcessPoolExecutor(max_workers=4) as executor:
            futures = [executor.submit(cpu_task) for _ in range(4)]
            results = [f.result() for f in futures]
        multiprocess_time = time.perf_counter() - start_time
        print(f"Multiprocessing: {multiprocess_time:.2f}s")

# Test benchmarks
def test_performance():
    benchmarks = PerformanceBenchmarks()
    benchmarks.run_all_benchmarks()
    
    print("\n" + "="*50)
    
    resource_mgmt = ResourceManagement()
    resource_mgmt.demonstrate_gil_impact()

# Uncomment to run benchmarks
# test_performance()
```

---

## Best Practices

### Threading Best Practices

1. **Use ThreadPoolExecutor** instead of creating threads manually
2. **Always use locks** for shared mutable state
3. **Prefer Queue** for thread communication
4. **Use threading for I/O bound tasks**
5. **Avoid shared state** when possible
6. **Use context managers** for resource management

### Multiprocessing Best Practices

1. **Use ProcessPoolExecutor** for CPU-bound tasks
2. **Minimize data transfer** between processes
3. **Use appropriate IPC mechanisms**
4. **Handle process cleanup** properly
5. **Consider memory usage** of separate processes
6. **Use appropriate number of workers** (usually CPU count)

### Go Concurrency Best Practices

1. **Don't communicate by sharing memory; share memory by communicating**
2. **Use channels** for communication between goroutines
3. **Close channels** when done sending
4. **Use select** for non-blocking operations
5. **Use context** for cancellation
6. **Avoid goroutine leaks**

---

## Interview Questions

### Q1: Explain the difference between threading and multiprocessing

**Answer:**
- **Threading**: Shares memory space, lighter weight, good for I/O bound tasks, limited by GIL in Python
- **Multiprocessing**: Separate memory spaces, heavier weight, good for CPU bound tasks, true parallelism

### Q2: What is the Python GIL and how does it affect performance?

**Answer:**
The Global Interpreter Lock (GIL) is a mutex that protects access to Python objects, preventing multiple threads from executing Python bytecode simultaneously. This means:
- Threading provides no benefit for CPU-bound pure Python code
- I/O bound tasks can still benefit from threading
- NumPy/C extensions can release the GIL
- Multiprocessing bypasses the GIL

### Q3: How do you handle race conditions?

**Answer:**
```python
# Use locks, queues, or other synchronization primitives
import threading

shared_resource = 0
lock = threading.Lock()

def safe_increment():
    global shared_resource
    with lock:
        shared_resource += 1  # Protected by lock

# Or use thread-safe data structures
import queue
safe_queue = queue.Queue()  # Thread-safe
```

### Q4: What are the trade-offs between different concurrency models?

**Answer:**
- **Threading**: Low overhead, shared memory, race conditions possible
- **Multiprocessing**: High overhead, process isolation, true parallelism
- **Async/Await**: Single-threaded, event-driven, great for I/O bound
- **Go Goroutines**: Lightweight, CSP model, built-in scheduler

### Q5: How do you choose between threading and multiprocessing?

**Answer:**
```python
# Use Threading for:
# - I/O bound tasks (file operations, network requests)
# - Tasks requiring shared state
# - When memory usage is a concern

# Use Multiprocessing for:
# - CPU bound tasks (mathematical computations)
# - Tasks that can be parallelized independently
# - When you need fault isolation
```

---

## Interview Questions and Answers

| # | Difficulty | Question | Answer |
|---|------------|----------|---------|
| 1 | Easy | What is multithreading? | Concurrent execution of multiple threads within a single process |
| 2 | Easy | What is multiprocessing? | Running multiple processes simultaneously, each with separate memory space |
| 3 | Easy | Difference between thread and process? | Threads share memory within process, processes have separate memory spaces |
| 4 | Easy | What is the GIL in Python? | Global Interpreter Lock - prevents multiple threads from executing Python bytecode simultaneously |
| 5 | Easy | When to use threading vs multiprocessing? | Threading for I/O-bound tasks, multiprocessing for CPU-bound tasks |
| 6 | Easy | What is a race condition? | When multiple threads access shared data simultaneously leading to unpredictable results |
| 7 | Easy | What is thread synchronization? | Coordinating thread execution to prevent race conditions and ensure data consistency |
| 8 | Easy | What is a mutex? | Mutual exclusion lock ensuring only one thread accesses critical section at a time |
| 9 | Easy | What is a deadlock? | Situation where threads wait for each other indefinitely, preventing progress |
| 10 | Easy | What is context switching? | OS switching CPU from one thread/process to another, saving and restoring state |
| 11 | Easy | What is a semaphore? | Synchronization primitive controlling access to resource pool with counter |
| 12 | Easy | What is thread pool? | Collection of pre-created threads that execute tasks from queue |
| 13 | Easy | What is atomic operation? | Operation that completes without interruption, appearing instantaneous to other threads |
| 14 | Easy | What is thread safety? | Property ensuring correct behavior when accessed by multiple threads concurrently |
| 15 | Easy | What is blocking vs non-blocking? | Blocking waits for operation completion, non-blocking returns immediately |
| 16 | Medium | How does Python threading work with GIL? | GIL allows only one thread to execute Python bytecode, good for I/O-bound tasks |
| 17 | Medium | What is threading.Lock vs threading.RLock? | Lock can't be acquired by same thread twice, RLock (reentrant) can be |
| 18 | Medium | What is threading.Condition? | Synchronization primitive allowing threads to wait for specific condition |
| 19 | Medium | What is Queue in threading? | Thread-safe data structure for passing data between threads |
| 20 | Medium | What is concurrent.futures? | High-level interface for asynchronously executing callables with ThreadPoolExecutor/ProcessPoolExecutor |
| 21 | Medium | What is multiprocessing.Pool? | Process pool for parallel execution of functions across multiple processes |
| 22 | Medium | What is multiprocessing.Queue vs Queue.Queue? | multiprocessing.Queue works across processes, Queue.Queue within single process |
| 23 | Medium | What is shared memory in multiprocessing? | Memory segment accessible by multiple processes using multiprocessing.shared_memory |
| 24 | Medium | What is pickle in multiprocessing? | Serialization mechanism for passing objects between processes |
| 25 | Medium | What is fork vs spawn in multiprocessing? | Fork clones parent process, spawn creates new process from scratch |
| 26 | Medium | What are Go goroutines? | Lightweight threads managed by Go runtime, much more efficient than OS threads |
| 27 | Medium | What are Go channels? | Communication mechanism between goroutines, can be buffered or unbuffered |
| 28 | Medium | What is select statement in Go? | Allows goroutine to wait on multiple channel operations simultaneously |
| 29 | Medium | What is WaitGroup in Go? | Synchronization primitive to wait for collection of goroutines to complete |
| 30 | Medium | What is Mutex vs RWMutex in Go? | Mutex provides exclusive access, RWMutex allows multiple readers or single writer |
| 31 | Hard | Explain producer-consumer pattern | One thread produces data, another consumes it using synchronized queue |
| 32 | Hard | What is reader-writer problem? | Multiple readers can access simultaneously, but writers need exclusive access |
| 33 | Hard | What is dining philosophers problem? | Classic synchronization problem demonstrating deadlock and starvation |
| 34 | Hard | How to avoid deadlocks? | Lock ordering, timeout mechanisms, deadlock detection algorithms |
| 35 | Hard | What is lock-free programming? | Programming without locks using atomic operations and memory ordering |
| 36 | Hard | What is compare-and-swap (CAS)? | Atomic operation comparing memory value and swapping if equal |
| 37 | Hard | What is memory barrier? | Hardware/software mechanism ensuring memory operation ordering |
| 38 | Hard | What is false sharing? | Performance problem when threads modify different variables in same cache line |
| 39 | Hard | What is thread affinity? | Binding thread to specific CPU core to improve cache locality |
| 40 | Hard | What is work stealing? | Load balancing technique where idle threads steal work from busy threads |
| 41 | Hard | How to handle exceptions in threads? | Use try-catch blocks, exception queues, or callback mechanisms |
| 42 | Hard | What is asyncio in Python? | Asynchronous programming framework using event loop and coroutines |
| 43 | Hard | Difference between concurrent and parallel? | Concurrent: tasks appear simultaneous, Parallel: tasks actually execute simultaneously |
| 44 | Hard | What is thread local storage? | Per-thread storage allowing each thread to have own copy of data |
| 45 | Hard | What is priority inversion? | High-priority task blocked by low-priority task holding shared resource |
| 46 | Expert | What is memory ordering? | Rules about when memory operations become visible to other threads |
| 47 | Expert | What is ABA problem? | Issue with compare-and-swap when value changes and changes back |
| 48 | Expert | What is lock-free vs wait-free? | Lock-free: some thread makes progress, Wait-free: all threads make progress |
| 49 | Expert | What is memory model? | Abstract specification of how memory operations behave in multithreaded environment |
| 50 | Expert | What is hazard pointer? | Memory management technique for lock-free data structures |
| 51 | Expert | What is RCU (Read-Copy-Update)? | Synchronization mechanism allowing lock-free reads and careful updates |
| 52 | Expert | What is transactional memory? | Programming model where groups of memory operations execute atomically |
| 53 | Expert | What is actor model? | Concurrent computation model with actors communicating via messages |
| 54 | Expert | What is CSP (Communicating Sequential Processes)? | Concurrency model using channels for communication (basis for Go) |
| 55 | Expert | What is software transactional memory? | Optimistic concurrency control using transactions instead of locks |

## 🎯 Key Takeaways

1. **Understand the GIL's impact** on Python threading
2. **Know when to use each approach** based on task type
3. **Practice with synchronization primitives** (locks, queues, conditions)
4. **Learn Go's concurrency model** for comparison
5. **Benchmark your specific use case** to make informed decisions
6. **Consider memory usage and overhead** in your choice
7. **Handle resource cleanup and error cases** properly
