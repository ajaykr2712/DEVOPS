# System Design Fundamentals

## Table of Contents
1. [Overview](#overview)
2. [Test Framework Architecture Design](#test-framework-architecture-design)
3. [Log Pipeline Design](#log-pipeline-design)
4. [Retry Mechanisms & Queue Systems](#retry-mechanisms--queue-systems)
5. [Rate Limiting](#rate-limiting)
6. [Caching & CDN](#caching--cdn)
7. [API Gateway Design](#api-gateway-design)
8. [Database Design Patterns](#database-design-patterns)
9. [Microservices Communication](#microservices-communication)
10. [Scalability Patterns](#scalability-patterns)
11. [Interview Questions & Answers](#interview-questions--answers)

## Overview

System design involves creating architectures that are scalable, reliable, maintainable, and performant. Key principles include:

- **Scalability**: Handle increasing load
- **Reliability**: System continues to work correctly
- **Availability**: System remains operational
- **Consistency**: Data remains consistent across the system
- **Partition Tolerance**: System continues despite network failures

## Test Framework Architecture Design

### Scalable Test Framework Design

```python
from abc import ABC, abstractmethod
from typing import Dict, List, Any, Optional, Callable
from dataclasses import dataclass
from enum import Enum
import asyncio
import json
import time
from concurrent.futures import ThreadPoolExecutor, ProcessPoolExecutor

class TestStatus(Enum):
    PENDING = "pending"
    RUNNING = "running"
    PASSED = "passed"
    FAILED = "failed"
    SKIPPED = "skipped"

@dataclass
class TestResult:
    test_id: str
    name: str
    status: TestStatus
    duration: float
    error_message: Optional[str] = None
    metadata: Dict[str, Any] = None

class TestExecutor(ABC):
    @abstractmethod
    async def execute(self, test_case: 'TestCase') -> TestResult:
        pass

class ParallelTestExecutor(TestExecutor):
    def __init__(self, max_workers: int = 10):
        self.max_workers = max_workers
        self.thread_pool = ThreadPoolExecutor(max_workers=max_workers)
    
    async def execute(self, test_case: 'TestCase') -> TestResult:
        loop = asyncio.get_event_loop()
        start_time = time.time()
        
        try:
            # Execute test in thread pool to avoid blocking
            result = await loop.run_in_executor(
                self.thread_pool, 
                test_case.run
            )
            
            duration = time.time() - start_time
            return TestResult(
                test_id=test_case.id,
                name=test_case.name,
                status=TestStatus.PASSED if result else TestStatus.FAILED,
                duration=duration,
                metadata=test_case.metadata
            )
            
        except Exception as e:
            duration = time.time() - start_time
            return TestResult(
                test_id=test_case.id,
                name=test_case.name,
                status=TestStatus.FAILED,
                duration=duration,
                error_message=str(e),
                metadata=test_case.metadata
            )

class TestCase:
    def __init__(self, id: str, name: str, test_func: Callable, 
                 setup: Optional[Callable] = None, 
                 teardown: Optional[Callable] = None,
                 metadata: Optional[Dict] = None):
        self.id = id
        self.name = name
        self.test_func = test_func
        self.setup = setup
        self.teardown = teardown
        self.metadata = metadata or {}
    
    def run(self) -> bool:
        try:
            if self.setup:
                self.setup()
            
            result = self.test_func()
            return result if result is not None else True
            
        finally:
            if self.teardown:
                self.teardown()

class TestSuite:
    def __init__(self, name: str, executor: TestExecutor):
        self.name = name
        self.test_cases: List[TestCase] = []
        self.executor = executor
        self.filters: List[Callable[[TestCase], bool]] = []
    
    def add_test(self, test_case: TestCase):
        self.test_cases.append(test_case)
    
    def add_filter(self, filter_func: Callable[[TestCase], bool]):
        self.filters.append(filter_func)
    
    def get_filtered_tests(self) -> List[TestCase]:
        filtered_tests = self.test_cases
        for filter_func in self.filters:
            filtered_tests = [t for t in filtered_tests if filter_func(t)]
        return filtered_tests
    
    async def run(self) -> List[TestResult]:
        tests_to_run = self.get_filtered_tests()
        
        # Execute tests concurrently
        tasks = [self.executor.execute(test) for test in tests_to_run]
        results = await asyncio.gather(*tasks, return_exceptions=True)
        
        # Handle any exceptions from test execution
        final_results = []
        for i, result in enumerate(results):
            if isinstance(result, Exception):
                final_results.append(TestResult(
                    test_id=tests_to_run[i].id,
                    name=tests_to_run[i].name,
                    status=TestStatus.FAILED,
                    duration=0.0,
                    error_message=str(result)
                ))
            else:
                final_results.append(result)
        
        return final_results

class TestRunner:
    def __init__(self):
        self.suites: List[TestSuite] = []
        self.reporters: List['TestReporter'] = []
    
    def add_suite(self, suite: TestSuite):
        self.suites.append(suite)
    
    def add_reporter(self, reporter: 'TestReporter'):
        self.reporters.append(reporter)
    
    async def run_all(self) -> Dict[str, List[TestResult]]:
        all_results = {}
        
        for suite in self.suites:
            print(f"Running test suite: {suite.name}")
            results = await suite.run()
            all_results[suite.name] = results
            
            # Report results
            for reporter in self.reporters:
                await reporter.report(suite.name, results)
        
        return all_results

class TestReporter(ABC):
    @abstractmethod
    async def report(self, suite_name: str, results: List[TestResult]):
        pass

class JSONReporter(TestReporter):
    def __init__(self, output_file: str):
        self.output_file = output_file
    
    async def report(self, suite_name: str, results: List[TestResult]):
        report_data = {
            "suite": suite_name,
            "timestamp": time.time(),
            "summary": {
                "total": len(results),
                "passed": len([r for r in results if r.status == TestStatus.PASSED]),
                "failed": len([r for r in results if r.status == TestStatus.FAILED]),
                "total_duration": sum(r.duration for r in results)
            },
            "results": [
                {
                    "test_id": r.test_id,
                    "name": r.name,
                    "status": r.status.value,
                    "duration": r.duration,
                    "error_message": r.error_message,
                    "metadata": r.metadata
                }
                for r in results
            ]
        }
        
        with open(f"{self.output_file}_{suite_name}.json", "w") as f:
            json.dump(report_data, f, indent=2)

# Example usage
async def example_test_framework():
    # Create test functions
    def test_api_health():
        # Simulate API health check
        time.sleep(0.1)
        return True
    
    def test_database_connection():
        # Simulate database test
        time.sleep(0.2)
        return True
    
    def test_authentication():
        # Simulate auth test
        time.sleep(0.1)
        raise Exception("Authentication failed")
    
    # Create test cases
    tests = [
        TestCase("test1", "API Health Check", test_api_health, 
                metadata={"category": "health", "priority": "high"}),
        TestCase("test2", "Database Connection", test_database_connection,
                metadata={"category": "database", "priority": "medium"}),
        TestCase("test3", "Authentication", test_authentication,
                metadata={"category": "auth", "priority": "high"})
    ]
    
    # Create executor and suite
    executor = ParallelTestExecutor(max_workers=5)
    suite = TestSuite("Integration Tests", executor)
    
    for test in tests:
        suite.add_test(test)
    
    # Add filter for high priority tests only
    suite.add_filter(lambda t: t.metadata.get("priority") == "high")
    
    # Create runner and reporter
    runner = TestRunner()
    runner.add_suite(suite)
    runner.add_reporter(JSONReporter("test_results"))
    
    # Run tests
    results = await runner.run_all()
    
    for suite_name, suite_results in results.items():
        print(f"\nSuite: {suite_name}")
        for result in suite_results:
            print(f"  {result.name}: {result.status.value} ({result.duration:.2f}s)")

# Run the example
# asyncio.run(example_test_framework())
```

## Log Pipeline Design

### Scalable Log Processing Pipeline

```python
import asyncio
import json
import time
from typing import Dict, List, Any, Optional, Callable
from dataclasses import dataclass, asdict
from abc import ABC, abstractmethod
from datetime import datetime
import hashlib
import logging

@dataclass
class LogEntry:
    timestamp: str
    level: str
    service: str
    message: str
    metadata: Dict[str, Any]
    trace_id: Optional[str] = None
    span_id: Optional[str] = None

class LogProcessor(ABC):
    @abstractmethod
    async def process(self, log_entry: LogEntry) -> LogEntry:
        pass

class EnrichmentProcessor(LogProcessor):
    """Add additional metadata to log entries"""
    
    def __init__(self, enrichment_data: Dict[str, Any]):
        self.enrichment_data = enrichment_data
    
    async def process(self, log_entry: LogEntry) -> LogEntry:
        # Add enrichment data
        log_entry.metadata.update(self.enrichment_data)
        
        # Add computed fields
        log_entry.metadata['processed_at'] = datetime.utcnow().isoformat()
        log_entry.metadata['log_hash'] = hashlib.md5(
            f"{log_entry.timestamp}{log_entry.message}".encode()
        ).hexdigest()
        
        return log_entry

class FilterProcessor(LogProcessor):
    """Filter logs based on criteria"""
    
    def __init__(self, filter_func: Callable[[LogEntry], bool]):
        self.filter_func = filter_func
    
    async def process(self, log_entry: LogEntry) -> Optional[LogEntry]:
        if self.filter_func(log_entry):
            return log_entry
        return None

class TransformProcessor(LogProcessor):
    """Transform log entry fields"""
    
    def __init__(self, transformations: Dict[str, Callable[[Any], Any]]):
        self.transformations = transformations
    
    async def process(self, log_entry: LogEntry) -> LogEntry:
        for field, transform_func in self.transformations.items():
            if hasattr(log_entry, field):
                setattr(log_entry, field, transform_func(getattr(log_entry, field)))
        
        return log_entry

class LogOutput(ABC):
    @abstractmethod
    async def write(self, log_entries: List[LogEntry]):
        pass

class ElasticsearchOutput(LogOutput):
    def __init__(self, es_client, index_pattern: str = "logs-%Y.%m.%d"):
        self.es_client = es_client
        self.index_pattern = index_pattern
    
    async def write(self, log_entries: List[LogEntry]):
        bulk_data = []
        
        for entry in log_entries:
            index_name = datetime.now().strftime(self.index_pattern)
            
            # Prepare bulk insert data
            bulk_data.append({
                "index": {"_index": index_name}
            })
            bulk_data.append(asdict(entry))
        
        if bulk_data:
            # Simulate Elasticsearch bulk insert
            print(f"Writing {len(log_entries)} log entries to Elasticsearch")
            # await self.es_client.bulk(bulk_data)

class FileOutput(LogOutput):
    def __init__(self, file_path: str):
        self.file_path = file_path
    
    async def write(self, log_entries: List[LogEntry]):
        with open(self.file_path, "a") as f:
            for entry in log_entries:
                f.write(json.dumps(asdict(entry)) + "\n")

class LogPipeline:
    def __init__(self, batch_size: int = 100, flush_interval: int = 5):
        self.processors: List[LogProcessor] = []
        self.outputs: List[LogOutput] = []
        self.batch_size = batch_size
        self.flush_interval = flush_interval
        self.buffer: List[LogEntry] = []
        self.last_flush = time.time()
        self.running = False
    
    def add_processor(self, processor: LogProcessor):
        self.processors.append(processor)
    
    def add_output(self, output: LogOutput):
        self.outputs.append(output)
    
    async def process_log(self, log_entry: LogEntry):
        """Process a single log entry through the pipeline"""
        processed_entry = log_entry
        
        for processor in self.processors:
            processed_entry = await processor.process(processed_entry)
            if processed_entry is None:  # Filtered out
                return
        
        # Add to buffer
        self.buffer.append(processed_entry)
        
        # Check if we should flush
        if (len(self.buffer) >= self.batch_size or 
            time.time() - self.last_flush >= self.flush_interval):
            await self.flush()
    
    async def flush(self):
        """Flush buffered logs to outputs"""
        if not self.buffer:
            return
        
        logs_to_flush = self.buffer.copy()
        self.buffer.clear()
        self.last_flush = time.time()
        
        # Write to all outputs
        for output in self.outputs:
            try:
                await output.write(logs_to_flush)
            except Exception as e:
                print(f"Error writing to output: {e}")
    
    async def start_background_flush(self):
        """Start background task to flush logs periodically"""
        self.running = True
        while self.running:
            await asyncio.sleep(self.flush_interval)
            await self.flush()
    
    def stop(self):
        self.running = False

class LogShipper:
    """Ships logs from multiple sources to the pipeline"""
    
    def __init__(self, pipeline: LogPipeline):
        self.pipeline = pipeline
        self.sources: List[LogSource] = []
    
    def add_source(self, source: 'LogSource'):
        self.sources.append(source)
    
    async def start_shipping(self):
        """Start shipping logs from all sources"""
        tasks = []
        
        # Start pipeline background flush
        tasks.append(asyncio.create_task(self.pipeline.start_background_flush()))
        
        # Start all log sources
        for source in self.sources:
            tasks.append(asyncio.create_task(source.start_reading(self.pipeline)))
        
        await asyncio.gather(*tasks)

class LogSource(ABC):
    @abstractmethod
    async def start_reading(self, pipeline: LogPipeline):
        pass

class FileLogSource(LogSource):
    def __init__(self, file_path: str, service_name: str):
        self.file_path = file_path
        self.service_name = service_name
    
    async def start_reading(self, pipeline: LogPipeline):
        """Simulate reading from a log file"""
        counter = 0
        while True:
            # Simulate log entry
            log_entry = LogEntry(
                timestamp=datetime.utcnow().isoformat(),
                level="INFO",
                service=self.service_name,
                message=f"Log message {counter}",
                metadata={"source": "file", "file_path": self.file_path}
            )
            
            await pipeline.process_log(log_entry)
            counter += 1
            await asyncio.sleep(1)  # Simulate log frequency

class KafkaLogSource(LogSource):
    def __init__(self, topic: str, consumer_group: str):
        self.topic = topic
        self.consumer_group = consumer_group
    
    async def start_reading(self, pipeline: LogPipeline):
        """Simulate reading from Kafka"""
        counter = 0
        while True:
            # Simulate Kafka message
            log_data = {
                "timestamp": datetime.utcnow().isoformat(),
                "level": "INFO",
                "service": "kafka-service",
                "message": f"Kafka message {counter}",
                "metadata": {"topic": self.topic, "partition": 0}
            }
            
            log_entry = LogEntry(**log_data)
            await pipeline.process_log(log_entry)
            counter += 1
            await asyncio.sleep(0.5)

# Example usage
async def example_log_pipeline():
    # Create pipeline
    pipeline = LogPipeline(batch_size=50, flush_interval=3)
    
    # Add processors
    pipeline.add_processor(EnrichmentProcessor({
        "environment": "production",
        "datacenter": "us-west-1"
    }))
    
    pipeline.add_processor(FilterProcessor(
        lambda log: log.level in ["ERROR", "WARN", "INFO"]
    ))
    
    pipeline.add_processor(TransformProcessor({
        "message": lambda msg: msg.upper()
    }))
    
    # Add outputs
    pipeline.add_output(FileOutput("processed_logs.jsonl"))
    # pipeline.add_output(ElasticsearchOutput(es_client))
    
    # Create log shipper
    shipper = LogShipper(pipeline)
    shipper.add_source(FileLogSource("/var/log/app.log", "web-service"))
    shipper.add_source(KafkaLogSource("application-logs", "log-processor"))
    
    # Start shipping (would run indefinitely in production)
    try:
        await asyncio.wait_for(shipper.start_shipping(), timeout=10.0)
    except asyncio.TimeoutError:
        pipeline.stop()
        print("Log pipeline stopped")

# Run the example
# asyncio.run(example_log_pipeline())
```

## Retry Mechanisms & Queue Systems

### Robust Retry and Queue Implementation

```python
import asyncio
import time
import json
import random
from typing import Any, Callable, Optional, Dict, List
from dataclasses import dataclass, asdict
from enum import Enum
from abc import ABC, abstractmethod
import heapq
from datetime import datetime, timedelta

class RetryStrategy(Enum):
    FIXED = "fixed"
    EXPONENTIAL = "exponential"
    LINEAR = "linear"

@dataclass
class RetryConfig:
    max_attempts: int = 3
    strategy: RetryStrategy = RetryStrategy.EXPONENTIAL
    base_delay: float = 1.0
    max_delay: float = 60.0
    jitter: bool = True
    retryable_exceptions: tuple = (Exception,)

class RetryableError(Exception):
    pass

class NonRetryableError(Exception):
    pass

async def retry_async(config: RetryConfig):
    """Decorator for async functions with retry logic"""
    def decorator(func: Callable):
        async def wrapper(*args, **kwargs):
            last_exception = None
            
            for attempt in range(config.max_attempts):
                try:
                    return await func(*args, **kwargs)
                
                except config.retryable_exceptions as e:
                    last_exception = e
                    
                    if attempt == config.max_attempts - 1:
                        break
                    
                    # Calculate delay
                    delay = calculate_delay(config, attempt)
                    print(f"Attempt {attempt + 1} failed: {e}. Retrying in {delay:.2f}s")
                    await asyncio.sleep(delay)
                
                except Exception as e:
                    # Non-retryable exception
                    raise e
            
            raise last_exception
        
        return wrapper
    return decorator

def calculate_delay(config: RetryConfig, attempt: int) -> float:
    """Calculate retry delay based on strategy"""
    if config.strategy == RetryStrategy.FIXED:
        delay = config.base_delay
    elif config.strategy == RetryStrategy.LINEAR:
        delay = config.base_delay * (attempt + 1)
    elif config.strategy == RetryStrategy.EXPONENTIAL:
        delay = config.base_delay * (2 ** attempt)
    else:
        delay = config.base_delay
    
    # Apply max delay
    delay = min(delay, config.max_delay)
    
    # Add jitter
    if config.jitter:
        delay += random.uniform(0, delay * 0.1)
    
    return delay

@dataclass
class Task:
    id: str
    payload: Dict[str, Any]
    priority: int = 0
    max_retries: int = 3
    retry_count: int = 0
    created_at: float = None
    scheduled_at: float = None
    
    def __post_init__(self):
        if self.created_at is None:
            self.created_at = time.time()
        if self.scheduled_at is None:
            self.scheduled_at = time.time()
    
    def __lt__(self, other):
        # For priority queue (lower priority number = higher priority)
        return (self.priority, self.scheduled_at) < (other.priority, other.scheduled_at)

class TaskProcessor(ABC):
    @abstractmethod
    async def process(self, task: Task) -> bool:
        """Process a task. Return True if successful, False to retry"""
        pass

class Queue(ABC):
    @abstractmethod
    async def enqueue(self, task: Task):
        pass
    
    @abstractmethod
    async def dequeue(self) -> Optional[Task]:
        pass
    
    @abstractmethod
    async def requeue(self, task: Task, delay: float = 0):
        pass

class InMemoryQueue(Queue):
    def __init__(self):
        self.queue = []
        self.delayed_queue = []
        self.lock = asyncio.Lock()
    
    async def enqueue(self, task: Task):
        async with self.lock:
            heapq.heappush(self.queue, task)
    
    async def dequeue(self) -> Optional[Task]:
        async with self.lock:
            # Move ready delayed tasks to main queue
            current_time = time.time()
            while self.delayed_queue and self.delayed_queue[0][0] <= current_time:
                _, task = heapq.heappop(self.delayed_queue)
                heapq.heappush(self.queue, task)
            
            if self.queue:
                return heapq.heappop(self.queue)
            return None
    
    async def requeue(self, task: Task, delay: float = 0):
        if delay > 0:
            task.scheduled_at = time.time() + delay
            async with self.lock:
                heapq.heappush(self.delayed_queue, (task.scheduled_at, task))
        else:
            await self.enqueue(task)

class RedisQueue(Queue):
    """Redis-based queue implementation"""
    def __init__(self, redis_client, queue_name: str):
        self.redis = redis_client
        self.queue_name = queue_name
        self.delayed_queue_name = f"{queue_name}:delayed"
    
    async def enqueue(self, task: Task):
        task_data = json.dumps(asdict(task))
        await self.redis.lpush(self.queue_name, task_data)
    
    async def dequeue(self) -> Optional[Task]:
        # Move ready delayed tasks first
        await self._process_delayed_tasks()
        
        # Get task from main queue
        task_data = await self.redis.brpop(self.queue_name, timeout=1)
        if task_data:
            _, data = task_data
            task_dict = json.loads(data)
            return Task(**task_dict)
        return None
    
    async def requeue(self, task: Task, delay: float = 0):
        if delay > 0:
            task.scheduled_at = time.time() + delay
            task_data = json.dumps(asdict(task))
            await self.redis.zadd(
                self.delayed_queue_name, 
                {task_data: task.scheduled_at}
            )
        else:
            await self.enqueue(task)
    
    async def _process_delayed_tasks(self):
        """Move ready delayed tasks to main queue"""
        current_time = time.time()
        ready_tasks = await self.redis.zrangebyscore(
            self.delayed_queue_name, 0, current_time
        )
        
        if ready_tasks:
            pipe = self.redis.pipeline()
            for task_data in ready_tasks:
                pipe.lpush(self.queue_name, task_data)
                pipe.zrem(self.delayed_queue_name, task_data)
            await pipe.execute()

class TaskWorker:
    def __init__(self, queue: Queue, processor: TaskProcessor, 
                 worker_id: str, max_concurrent: int = 5):
        self.queue = queue
        self.processor = processor
        self.worker_id = worker_id
        self.max_concurrent = max_concurrent
        self.running = False
        self.semaphore = asyncio.Semaphore(max_concurrent)
    
    async def start(self):
        """Start processing tasks"""
        self.running = True
        print(f"Worker {self.worker_id} started")
        
        while self.running:
            try:
                task = await self.queue.dequeue()
                if task:
                    # Process task with concurrency limit
                    asyncio.create_task(self._process_task_with_retry(task))
                else:
                    # No tasks available, short sleep
                    await asyncio.sleep(0.1)
            
            except Exception as e:
                print(f"Worker {self.worker_id} error: {e}")
                await asyncio.sleep(1)
    
    async def _process_task_with_retry(self, task: Task):
        """Process task with retry logic"""
        async with self.semaphore:
            try:
                success = await self.processor.process(task)
                
                if not success and task.retry_count < task.max_retries:
                    # Retry with exponential backoff
                    task.retry_count += 1
                    delay = 2 ** task.retry_count
                    print(f"Task {task.id} failed, retrying in {delay}s (attempt {task.retry_count})")
                    await self.queue.requeue(task, delay)
                elif not success:
                    print(f"Task {task.id} failed permanently after {task.retry_count} retries")
                else:
                    print(f"Task {task.id} completed successfully")
            
            except Exception as e:
                print(f"Error processing task {task.id}: {e}")
                if task.retry_count < task.max_retries:
                    task.retry_count += 1
                    await self.queue.requeue(task, 2 ** task.retry_count)
    
    def stop(self):
        self.running = False

# Example processor implementations
class EmailProcessor(TaskProcessor):
    async def process(self, task: Task) -> bool:
        """Process email sending task"""
        email_data = task.payload
        print(f"Sending email to {email_data.get('to')} with subject '{email_data.get('subject')}'")
        
        # Simulate processing
        await asyncio.sleep(0.5)
        
        # Simulate random failures
        if random.random() < 0.3:
            raise RetryableError("SMTP server temporarily unavailable")
        
        return True

class DataProcessingTask(TaskProcessor):
    async def process(self, task: Task) -> bool:
        """Process data transformation task"""
        data = task.payload
        print(f"Processing data batch {data.get('batch_id')} with {data.get('record_count')} records")
        
        # Simulate processing time
        await asyncio.sleep(1.0)
        
        # Simulate occasional failures
        if random.random() < 0.2:
            return False  # Will be retried
        
        return True

# Example usage
async def example_queue_system():
    # Create queue and processors
    queue = InMemoryQueue()
    email_processor = EmailProcessor()
    data_processor = DataProcessingTask()
    
    # Create workers
    email_worker = TaskWorker(queue, email_processor, "email-worker-1")
    data_worker = TaskWorker(queue, data_processor, "data-worker-1")
    
    # Add some tasks
    tasks = [
        Task("email-1", {"to": "user1@example.com", "subject": "Welcome!"}, priority=1),
        Task("email-2", {"to": "user2@example.com", "subject": "Reminder"}, priority=2),
        Task("data-1", {"batch_id": "batch-001", "record_count": 1000}, priority=1),
        Task("data-2", {"batch_id": "batch-002", "record_count": 500}, priority=3),
    ]
    
    for task in tasks:
        await queue.enqueue(task)
    
    # Start workers
    worker_tasks = [
        asyncio.create_task(email_worker.start()),
        asyncio.create_task(data_worker.start())
    ]
    
    # Let workers run for a while
    try:
        await asyncio.wait_for(asyncio.gather(*worker_tasks), timeout=10.0)
    except asyncio.TimeoutError:
        email_worker.stop()
        data_worker.stop()
        print("Queue system stopped")

# Example retry decorator usage
@retry_async(RetryConfig(
    max_attempts=3,
    strategy=RetryStrategy.EXPONENTIAL,
    base_delay=1.0,
    retryable_exceptions=(RetryableError, ConnectionError)
))
async def unreliable_api_call():
    """Simulate an unreliable API call"""
    if random.random() < 0.7:
        raise RetryableError("API temporarily unavailable")
    return {"status": "success", "data": "important data"}

# Run examples
# asyncio.run(example_queue_system())
```

## Rate Limiting

### Advanced Rate Limiting Implementation

```python
import time
import asyncio
import json
from typing import Dict, Optional, Tuple
from dataclasses import dataclass
from abc import ABC, abstractmethod
from enum import Enum
import hashlib

class RateLimitAlgorithm(Enum):
    TOKEN_BUCKET = "token_bucket"
    SLIDING_WINDOW = "sliding_window"
    FIXED_WINDOW = "fixed_window"
    SLIDING_WINDOW_LOG = "sliding_window_log"

@dataclass
class RateLimitConfig:
    requests_per_second: float
    burst_size: int
    algorithm: RateLimitAlgorithm = RateLimitAlgorithm.TOKEN_BUCKET

class RateLimitResult:
    def __init__(self, allowed: bool, retry_after: Optional[float] = None, 
                 remaining: Optional[int] = None):
        self.allowed = allowed
        self.retry_after = retry_after
        self.remaining = remaining

class RateLimiter(ABC):
    @abstractmethod
    async def is_allowed(self, key: str) -> RateLimitResult:
        pass

class TokenBucketLimiter(RateLimiter):
    def __init__(self, config: RateLimitConfig):
        self.config = config
        self.buckets: Dict[str, Dict] = {}
    
    async def is_allowed(self, key: str) -> RateLimitResult:
        current_time = time.time()
        
        if key not in self.buckets:
            self.buckets[key] = {
                "tokens": self.config.burst_size,
                "last_refill": current_time
            }
        
        bucket = self.buckets[key]
        
        # Refill tokens
        time_passed = current_time - bucket["last_refill"]
        new_tokens = time_passed * self.config.requests_per_second
        bucket["tokens"] = min(
            self.config.burst_size,
            bucket["tokens"] + new_tokens
        )
        bucket["last_refill"] = current_time
        
        if bucket["tokens"] >= 1:
            bucket["tokens"] -= 1
            return RateLimitResult(
                allowed=True,
                remaining=int(bucket["tokens"])
            )
        else:
            retry_after = (1 - bucket["tokens"]) / self.config.requests_per_second
            return RateLimitResult(
                allowed=False,
                retry_after=retry_after,
                remaining=0
            )

class SlidingWindowLimiter(RateLimiter):
    def __init__(self, config: RateLimitConfig, window_size: int = 60):
        self.config = config
        self.window_size = window_size
        self.windows: Dict[str, Dict] = {}
    
    async def is_allowed(self, key: str) -> RateLimitResult:
        current_time = time.time()
        window_start = int(current_time) - self.window_size
        
        if key not in self.windows:
            self.windows[key] = {}
        
        window = self.windows[key]
        
        # Clean old entries
        expired_keys = [k for k in window.keys() if k < window_start]
        for k in expired_keys:
            del window[k]
        
        # Count requests in current window
        request_count = sum(window.values())
        max_requests = int(self.config.requests_per_second * self.window_size)
        
        if request_count < max_requests:
            # Add current request
            current_second = int(current_time)
            window[current_second] = window.get(current_second, 0) + 1
            
            return RateLimitResult(
                allowed=True,
                remaining=max_requests - request_count - 1
            )
        else:
            return RateLimitResult(
                allowed=False,
                retry_after=1.0,  # Try again in 1 second
                remaining=0
            )

class DistributedRateLimiter(RateLimiter):
    """Redis-based distributed rate limiter"""
    
    def __init__(self, redis_client, config: RateLimitConfig, key_prefix: str = "rate_limit"):
        self.redis = redis_client
        self.config = config
        self.key_prefix = key_prefix
    
    async def is_allowed(self, key: str) -> RateLimitResult:
        redis_key = f"{self.key_prefix}:{key}"
        
        if self.config.algorithm == RateLimitAlgorithm.TOKEN_BUCKET:
            return await self._token_bucket_check(redis_key)
        elif self.config.algorithm == RateLimitAlgorithm.SLIDING_WINDOW:
            return await self._sliding_window_check(redis_key)
        else:
            return await self._fixed_window_check(redis_key)
    
    async def _token_bucket_check(self, redis_key: str) -> RateLimitResult:
        lua_script = """
        local key = KEYS[1]
        local capacity = tonumber(ARGV[1])
        local refill_rate = tonumber(ARGV[2])
        local current_time = tonumber(ARGV[3])
        
        local bucket = redis.call('HMGET', key, 'tokens', 'last_refill')
        local tokens = tonumber(bucket[1]) or capacity
        local last_refill = tonumber(bucket[2]) or current_time
        
        -- Refill tokens
        local time_passed = current_time - last_refill
        local new_tokens = math.min(capacity, tokens + (time_passed * refill_rate))
        
        if new_tokens >= 1 then
            new_tokens = new_tokens - 1
            redis.call('HMSET', key, 'tokens', new_tokens, 'last_refill', current_time)
            redis.call('EXPIRE', key, 3600)
            return {1, math.floor(new_tokens)}
        else
            redis.call('HMSET', key, 'tokens', new_tokens, 'last_refill', current_time)
            redis.call('EXPIRE', key, 3600)
            return {0, 0, (1 - new_tokens) / refill_rate}
        end
        """
        
        result = await self.redis.eval(
            lua_script, 1, redis_key,
            self.config.burst_size,
            self.config.requests_per_second,
            time.time()
        )
        
        if result[0] == 1:
            return RateLimitResult(allowed=True, remaining=result[1])
        else:
            return RateLimitResult(allowed=False, retry_after=result[2], remaining=0)
    
    async def _sliding_window_check(self, redis_key: str) -> RateLimitResult:
        window_size = 60  # 60 seconds
        current_time = time.time()
        window_start = current_time - window_size
        
        pipe = self.redis.pipeline()
        pipe.zremrangebyscore(redis_key, 0, window_start)
        pipe.zcard(redis_key)
        pipe.zadd(redis_key, {str(current_time): current_time})
        pipe.expire(redis_key, window_size)
        
        results = await pipe.execute()
        request_count = results[1]
        
        max_requests = int(self.config.requests_per_second * window_size)
        
        if request_count < max_requests:
            return RateLimitResult(
                allowed=True,
                remaining=max_requests - request_count - 1
            )
        else:
            # Remove the request we just added since it's not allowed
            await self.redis.zrem(redis_key, str(current_time))
            return RateLimitResult(allowed=False, retry_after=1.0, remaining=0)
    
    async def _fixed_window_check(self, redis_key: str) -> RateLimitResult:
        window_size = 60  # 60 seconds
        current_window = int(time.time() / window_size)
        window_key = f"{redis_key}:{current_window}"
        
        current_count = await self.redis.incr(window_key)
        if current_count == 1:
            await self.redis.expire(window_key, window_size)
        
        max_requests = int(self.config.requests_per_second * window_size)
        
        if current_count <= max_requests:
            return RateLimitResult(
                allowed=True,
                remaining=max_requests - current_count
            )
        else:
            return RateLimitResult(allowed=False, retry_after=window_size, remaining=0)

class RateLimitMiddleware:
    """Rate limiting middleware for web applications"""
    
    def __init__(self, rate_limiter: RateLimiter, 
                 key_func: callable = None):
        self.rate_limiter = rate_limiter
        self.key_func = key_func or self._default_key_func
    
    def _default_key_func(self, request) -> str:
        """Default key function using client IP"""
        return request.get("client_ip", "unknown")
    
    async def __call__(self, request, handler):
        """Middleware function"""
        key = self.key_func(request)
        result = await self.rate_limiter.is_allowed(key)
        
        if not result.allowed:
            # Rate limit exceeded
            response = {
                "error": "Rate limit exceeded",
                "retry_after": result.retry_after
            }
            return self._create_response(response, status=429, headers={
                "Retry-After": str(int(result.retry_after or 1)),
                "X-RateLimit-Remaining": "0"
            })
        
        # Add rate limit headers to response
        response = await handler(request)
        if hasattr(response, 'headers'):
            response.headers["X-RateLimit-Remaining"] = str(result.remaining or 0)
        
        return response
    
    def _create_response(self, data, status=200, headers=None):
        """Create response object (implementation depends on framework)"""
        return {
            "status": status,
            "body": json.dumps(data),
            "headers": headers or {}
        }

# Advanced rate limiting with multiple tiers
class TieredRateLimiter:
    def __init__(self, redis_client):
        self.redis = redis_client
        self.tiers = {
            "free": RateLimitConfig(requests_per_second=1, burst_size=10),
            "premium": RateLimitConfig(requests_per_second=10, burst_size=100),
            "enterprise": RateLimitConfig(requests_per_second=100, burst_size=1000)
        }
        self.limiters = {
            tier: DistributedRateLimiter(redis_client, config, f"tier_{tier}")
            for tier, config in self.tiers.items()
        }
    
    async def is_allowed(self, user_id: str, tier: str) -> RateLimitResult:
        if tier not in self.limiters:
            tier = "free"  # Default to free tier
        
        return await self.limiters[tier].is_allowed(user_id)

# Circuit breaker pattern for rate limiting
class CircuitBreakerRateLimiter:
    def __init__(self, rate_limiter: RateLimiter, failure_threshold: int = 5,
                 recovery_timeout: float = 60.0):
        self.rate_limiter = rate_limiter
        self.failure_threshold = failure_threshold
        self.recovery_timeout = recovery_timeout
        self.failure_count = 0
        self.last_failure_time = None
        self.state = "closed"  # closed, open, half_open
    
    async def is_allowed(self, key: str) -> RateLimitResult:
        current_time = time.time()
        
        # Check if circuit should be half-open
        if (self.state == "open" and 
            self.last_failure_time and 
            current_time - self.last_failure_time > self.recovery_timeout):
            self.state = "half_open"
        
        # If circuit is open, deny all requests
        if self.state == "open":
            return RateLimitResult(
                allowed=False,
                retry_after=self.recovery_timeout - (current_time - self.last_failure_time)
            )
        
        try:
            result = await self.rate_limiter.is_allowed(key)
            
            # Reset on success
            if result.allowed and self.state == "half_open":
                self.state = "closed"
                self.failure_count = 0
            
            return result
        
        except Exception:
            self.failure_count += 1
            self.last_failure_time = current_time
            
            if self.failure_count >= self.failure_threshold:
                self.state = "open"
            
            return RateLimitResult(allowed=False, retry_after=1.0)

# Example usage
async def example_rate_limiting():
    # Create rate limiter
    config = RateLimitConfig(
        requests_per_second=5,
        burst_size=10,
        algorithm=RateLimitAlgorithm.TOKEN_BUCKET
    )
    limiter = TokenBucketLimiter(config)
    
    # Simulate requests
    for i in range(20):
        result = await limiter.is_allowed("user123")
        print(f"Request {i+1}: {'ALLOWED' if result.allowed else 'DENIED'} "
              f"(remaining: {result.remaining}, retry_after: {result.retry_after})")
        
        if not result.allowed and result.retry_after:
            await asyncio.sleep(result.retry_after)
        else:
            await asyncio.sleep(0.1)

# Run the example
# asyncio.run(example_rate_limiting())
```

## Interview Questions and Answers

| # | Difficulty | Question | Answer |
|---|------------|----------|---------|
| 1 | Easy | What is system design? | Process of defining architecture, components, and interfaces for systems |
| 2 | Easy | What is scalability? | System's ability to handle increased load gracefully |
| 3 | Easy | What is horizontal vs vertical scaling? | Horizontal adds more machines, vertical adds power to existing machine |
| 4 | Easy | What is load balancer? | Component distributing incoming requests across multiple servers |
| 5 | Easy | What is database? | Organized collection of structured information or data |
| 6 | Easy | What is caching? | Storing frequently accessed data in faster storage layer |
| 7 | Easy | What is CDN? | Content Delivery Network - distributed system for delivering content |
| 8 | Easy | What is API? | Application Programming Interface - set of protocols for building software |
| 9 | Easy | What is microservices? | Architectural approach with independent, deployable services |
| 10 | Easy | What is monolith? | Single deployable unit containing all application functionality |
| 11 | Easy | What is CAP theorem? | Consistency, Availability, Partition tolerance - can only guarantee two |
| 12 | Easy | What is ACID properties? | Atomicity, Consistency, Isolation, Durability for database transactions |
| 13 | Easy | What is eventual consistency? | System will become consistent over time without immediate guarantee |
| 14 | Easy | What is redundancy? | Having backup components to handle failures |
| 15 | Easy | What is failover? | Switching to backup system when primary system fails |
| 16 | Medium | Design a URL shortener like bit.ly | Use hash function for URLs, database for mapping, caching for popular URLs |
| 17 | Medium | Design a chat application | WebSocket connections, message queues, user presence, message history storage |
| 18 | Medium | Design a rate limiter | Token bucket, sliding window, or fixed window algorithms with Redis |
| 19 | Medium | Design a notification system | Queue-based system with different channels (email, SMS, push) |
| 20 | Medium | Design a file storage system | Chunking, replication, metadata storage, consistent hashing |
| 21 | Medium | What is sharding? | Horizontal partitioning of database across multiple machines |
| 22 | Medium | What is replication? | Maintaining copies of data across multiple nodes |
| 23 | Medium | What is consensus algorithm? | Method for distributed systems to agree on single value (Raft, Paxos) |
| 24 | Medium | What is message queue? | Component enabling asynchronous communication between services |
| 25 | Medium | What is pub/sub pattern? | Publisher sends messages to topic, subscribers receive relevant messages |
| 26 | Medium | What is circuit breaker? | Pattern preventing calls to failing service to avoid cascading failures |
| 27 | Medium | What is bulkhead pattern? | Isolating resources to prevent total system failure |
| 28 | Medium | What is retry mechanism? | Automatically retrying failed operations with backoff strategies |
| 29 | Medium | What is idempotency? | Property where multiple identical requests have same effect |
| 30 | Medium | What is database indexing? | Data structure improving query performance |
| 31 | Hard | Design Twitter/social media feed | Timeline generation, fan-out strategies, caching, content ranking |
| 32 | Hard | Design Uber/ride-sharing system | Location services, matching algorithms, real-time tracking, pricing |
| 33 | Hard | Design distributed cache | Consistent hashing, replication, eviction policies, hot-spotting |
| 34 | Hard | Design search engine | Web crawling, indexing, ranking algorithms, distributed storage |
| 35 | Hard | Design video streaming platform | Video encoding, CDN, adaptive bitrate, metadata storage |
| 36 | Hard | Design payment system | Double-entry bookkeeping, ACID transactions, fraud detection, reconciliation |
| 37 | Hard | Design monitoring system | Metrics collection, time-series database, alerting, visualization |
| 38 | Hard | Design recommendation system | Collaborative filtering, content-based filtering, machine learning pipeline |
| 39 | Hard | What is data partitioning strategies? | Range, hash, directory-based partitioning methods |
| 40 | Hard | What is distributed locking? | Coordinating access to shared resources across multiple machines |
| 41 | Hard | What is leader election? | Process of designating single node as coordinator in distributed system |
| 42 | Hard | What is vector clocks? | Algorithm for determining partial ordering of events in distributed systems |
| 43 | Hard | What is Byzantine fault tolerance? | Handling arbitrary failures including malicious behavior |
| 44 | Hard | What is bloom filter? | Probabilistic data structure for testing set membership |
| 45 | Hard | What is consistent hashing? | Technique for distributing data across changing number of nodes |
| 46 | Expert | Design global distributed system | Multi-region deployment, data consistency, latency optimization |
| 47 | Expert | Design real-time analytics system | Stream processing, lambda architecture, hot/cold storage |
| 48 | Expert | Design ML inference platform | Model serving, A/B testing, feature stores, monitoring |
| 49 | Expert | Design IoT data platform | Device management, telemetry ingestion, time-series processing |
| 50 | Expert | Design blockchain system | Consensus mechanisms, merkle trees, smart contracts, scaling |
| 51 | Expert | What is event sourcing? | Storing state changes as sequence of events |
| 52 | Expert | What is CQRS? | Command Query Responsibility Segregation - separate read/write models |
| 53 | Expert | What is saga pattern? | Managing distributed transactions across microservices |
| 54 | Expert | What is data mesh? | Decentralized data architecture with domain ownership |
| 55 | Expert | What is chaos engineering in system design? | Building resilient systems through controlled failure injection |
