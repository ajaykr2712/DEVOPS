# 🧩 Data Structures & Algorithms - Complete Interview Guide

## 📚 Table of Contents
1. [Arrays & Strings](#arrays--strings)
2. [Hashing](#hashing)
3. [Linked Lists](#linked-lists)
4. [Trees](#trees)
5. [Graphs](#graphs)
6. [Dynamic Programming](#dynamic-programming)
7. [Recursion & Backtracking](#recursion--backtracking)
8. [System-Level Problems](#system-level-problems)
9. [Interview Questions and Answers](#interview-questions-and-answers)

---

## Arrays & Strings

### Array Fundamentals

```python
# Time Complexity Cheat Sheet
# Access: O(1)
# Search: O(n)
# Insertion: O(n) - worst case (beginning), O(1) - end
# Deletion: O(n) - worst case

class ArrayProblems:
    
    def two_sum(self, nums, target):
        """
        Given array and target, return indices of two numbers that add to target.
        Time: O(n), Space: O(n)
        """
        seen = {}  # value -> index
        for i, num in enumerate(nums):
            complement = target - num
            if complement in seen:
                return [seen[complement], i]
            seen[num] = i
        return []
    
    def three_sum(self, nums):
        """
        Find all unique triplets that sum to zero.
        Time: O(n²), Space: O(1) excluding result
        """
        nums.sort()
        result = []
        
        for i in range(len(nums) - 2):
            # Skip duplicates for first element
            if i > 0 and nums[i] == nums[i-1]:
                continue
                
            left, right = i + 1, len(nums) - 1
            
            while left < right:
                current_sum = nums[i] + nums[left] + nums[right]
                
                if current_sum == 0:
                    result.append([nums[i], nums[left], nums[right]])
                    
                    # Skip duplicates
                    while left < right and nums[left] == nums[left + 1]:
                        left += 1
                    while left < right and nums[right] == nums[right - 1]:
                        right -= 1
                    
                    left += 1
                    right -= 1
                elif current_sum < 0:
                    left += 1
                else:
                    right -= 1
        
        return result
    
    def max_subarray_sum(self, nums):
        """
        Maximum sum of contiguous subarray (Kadane's Algorithm).
        Time: O(n), Space: O(1)
        """
        max_sum = current_sum = nums[0]
        
        for num in nums[1:]:
            current_sum = max(num, current_sum + num)
            max_sum = max(max_sum, current_sum)
        
        return max_sum
    
    def product_except_self(self, nums):
        """
        Array where each element is product of all other elements.
        Time: O(n), Space: O(1) excluding output
        """
        n = len(nums)
        result = [1] * n
        
        # Left pass
        for i in range(1, n):
            result[i] = result[i-1] * nums[i-1]
        
        # Right pass
        right = 1
        for i in range(n-1, -1, -1):
            result[i] *= right
            right *= nums[i]
        
        return result
    
    def rotate_array(self, nums, k):
        """
        Rotate array to the right by k steps.
        Time: O(n), Space: O(1)
        """
        n = len(nums)
        k %= n
        
        def reverse(start, end):
            while start < end:
                nums[start], nums[end] = nums[end], nums[start]
                start += 1
                end -= 1
        
        reverse(0, n - 1)      # Reverse entire array
        reverse(0, k - 1)      # Reverse first k elements
        reverse(k, n - 1)      # Reverse remaining elements
    
    def merge_intervals(self, intervals):
        """
        Merge overlapping intervals.
        Time: O(n log n), Space: O(1) excluding result
        """
        if not intervals:
            return []
        
        intervals.sort(key=lambda x: x[0])
        merged = [intervals[0]]
        
        for current in intervals[1:]:
            last = merged[-1]
            
            if current[0] <= last[1]:  # Overlap
                merged[-1] = [last[0], max(last[1], current[1])]
            else:
                merged.append(current)
        
        return merged

# Example usage and test cases
def test_array_problems():
    ap = ArrayProblems()
    
    # Two Sum
    print("Two Sum:", ap.two_sum([2, 7, 11, 15], 9))  # [0, 1]
    
    # Three Sum
    print("Three Sum:", ap.three_sum([-1, 0, 1, 2, -1, -4]))  # [[-1, -1, 2], [-1, 0, 1]]
    
    # Max Subarray
    print("Max Subarray:", ap.max_subarray_sum([-2, 1, -3, 4, -1, 2, 1, -5, 4]))  # 6
    
    # Product Except Self
    print("Product Except Self:", ap.product_except_self([1, 2, 3, 4]))  # [24, 12, 8, 6]
    
    # Rotate Array
    nums = [1, 2, 3, 4, 5, 6, 7]
    ap.rotate_array(nums, 3)
    print("Rotated Array:", nums)  # [5, 6, 7, 1, 2, 3, 4]
    
    # Merge Intervals
    print("Merge Intervals:", ap.merge_intervals([[1,3],[2,6],[8,10],[15,18]]))  # [[1,6],[8,10],[15,18]]

test_array_problems()
```

### String Algorithms

```python
class StringProblems:
    
    def is_palindrome(self, s):
        """
        Check if string is palindrome (ignoring case and non-alphanumeric).
        Time: O(n), Space: O(1)
        """
        left, right = 0, len(s) - 1
        
        while left < right:
            while left < right and not s[left].isalnum():
                left += 1
            while left < right and not s[right].isalnum():
                right -= 1
            
            if s[left].lower() != s[right].lower():
                return False
            
            left += 1
            right -= 1
        
        return True
    
    def longest_substring_without_repeating(self, s):
        """
        Length of longest substring without repeating characters.
        Time: O(n), Space: O(min(m,n)) where m is charset size
        """
        char_index = {}
        max_length = 0
        start = 0
        
        for end, char in enumerate(s):
            if char in char_index and char_index[char] >= start:
                start = char_index[char] + 1
            
            char_index[char] = end
            max_length = max(max_length, end - start + 1)
        
        return max_length
    
    def group_anagrams(self, strs):
        """
        Group strings that are anagrams.
        Time: O(n * k log k), Space: O(n * k)
        where n = number of strings, k = max length of string
        """
        from collections import defaultdict
        
        groups = defaultdict(list)
        
        for s in strs:
            # Sort characters to create key
            key = ''.join(sorted(s))
            groups[key].append(s)
        
        return list(groups.values())
    
    def min_window_substring(self, s, t):
        """
        Minimum window substring containing all characters of t.
        Time: O(|s| + |t|), Space: O(|s| + |t|)
        """
        from collections import Counter, defaultdict
        
        if not s or not t:
            return ""
        
        dict_t = Counter(t)
        required = len(dict_t)
        
        # Sliding window
        left = right = 0
        formed = 0
        window_counts = defaultdict(int)
        
        # Result: (window length, left, right)
        ans = float("inf"), None, None
        
        while right < len(s):
            # Add character from right to window
            char = s[right]
            window_counts[char] += 1
            
            # Check if current character has reached desired frequency
            if char in dict_t and window_counts[char] == dict_t[char]:
                formed += 1
            
            # Try to contract window
            while left <= right and formed == required:
                char = s[left]
                
                # Update result if this window is smaller
                if right - left + 1 < ans[0]:
                    ans = (right - left + 1, left, right)
                
                # Remove character from left
                window_counts[char] -= 1
                if char in dict_t and window_counts[char] < dict_t[char]:
                    formed -= 1
                
                left += 1
            
            right += 1
        
        return "" if ans[0] == float("inf") else s[ans[1]:ans[2] + 1]
```

---

## Hashing

### Hash Table Implementation

```python
class HashTable:
    def __init__(self, initial_capacity=10):
        self.capacity = initial_capacity
        self.size = 0
        self.buckets = [[] for _ in range(self.capacity)]
        self.load_factor_threshold = 0.75
    
    def _hash(self, key):
        """Simple hash function using built-in hash()"""
        return hash(key) % self.capacity
    
    def _resize(self):
        """Resize hash table when load factor exceeds threshold"""
        old_buckets = self.buckets
        self.capacity *= 2
        self.size = 0
        self.buckets = [[] for _ in range(self.capacity)]
        
        # Rehash all existing key-value pairs
        for bucket in old_buckets:
            for key, value in bucket:
                self.put(key, value)
    
    def put(self, key, value):
        """Insert or update key-value pair"""
        index = self._hash(key)
        bucket = self.buckets[index]
        
        # Check if key already exists
        for i, (k, v) in enumerate(bucket):
            if k == key:
                bucket[i] = (key, value)  # Update existing
                return
        
        # Add new key-value pair
        bucket.append((key, value))
        self.size += 1
        
        # Check if resize is needed
        if self.size > self.capacity * self.load_factor_threshold:
            self._resize()
```

---

## Linked Lists

### Linked List Implementation and Problems

```python
class ListNode:
    def __init__(self, val=0, next=None):
        self.val = val
        self.next = next

class LinkedListProblems:
    
    def reverse_list(self, head):
        """
        Reverse a linked list.
        Time: O(n), Space: O(1)
        """
        prev = None
        current = head
        
        while current:
            next_temp = current.next
            current.next = prev
            prev = current
            current = next_temp
        
        return prev
    
    def has_cycle(self, head):
        """
        Detect cycle in linked list (Floyd's Algorithm).
        Time: O(n), Space: O(1)
        """
        if not head or not head.next:
            return False
        
        slow = fast = head
        
        while fast and fast.next:
            slow = slow.next
            fast = fast.next.next
            
            if slow == fast:
                return True
        
        return False
    
    def merge_two_sorted_lists(self, l1, l2):
        """
        Merge two sorted linked lists.
        Time: O(n + m), Space: O(1)
        """
        dummy = ListNode(0)
        current = dummy
        
        while l1 and l2:
            if l1.val <= l2.val:
                current.next = l1
                l1 = l1.next
            else:
                current.next = l2
                l2 = l2.next
            current = current.next
        
        # Attach remaining nodes
        current.next = l1 or l2
        
        return dummy.next
```

---

## Trees

### Binary Tree Implementation and Problems

```python
class TreeNode:
    def __init__(self, val=0, left=None, right=None):
        self.val = val
        self.left = left
        self.right = right

class TreeProblems:
    
    def inorder_traversal(self, root):
        """
        Inorder traversal (Left, Root, Right).
        Time: O(n), Space: O(h) where h is height
        """
        result = []
        
        def inorder(node):
            if node:
                inorder(node.left)
                result.append(node.val)
                inorder(node.right)
        
        inorder(root)
        return result
    
    def level_order_traversal(self, root):
        """
        Level order traversal (BFS).
        Time: O(n), Space: O(w) where w is max width
        """
        if not root:
            return []
        
        from collections import deque
        
        result = []
        queue = deque([root])
        
        while queue:
            level_size = len(queue)
            level = []
            
            for _ in range(level_size):
                node = queue.popleft()
                level.append(node.val)
                
                if node.left:
                    queue.append(node.left)
                if node.right:
                    queue.append(node.right)
            
            result.append(level)
        
        return result
    
    def max_depth(self, root):
        """
        Maximum depth of binary tree.
        Time: O(n), Space: O(h)
        """
        if not root:
            return 0
        
        return 1 + max(self.max_depth(root.left), self.max_depth(root.right))
    
    def validate_bst(self, root):
        """
        Validate if tree is a valid BST.
        Time: O(n), Space: O(h)
        """
        def validate(node, min_val, max_val):
            if not node:
                return True
            
            if node.val <= min_val or node.val >= max_val:
                return False
            
            return (validate(node.left, min_val, node.val) and 
                    validate(node.right, node.val, max_val))
        
        return validate(root, float('-inf'), float('inf'))
```

---

## Graphs

### Graph Implementation and Algorithms

```python
from collections import defaultdict, deque

class Graph:
    def __init__(self):
        self.graph = defaultdict(list)
        self.vertices = set()
    
    def add_edge(self, u, v, directed=False):
        """Add edge between vertices u and v"""
        self.graph[u].append(v)
        self.vertices.add(u)
        self.vertices.add(v)
        
        if not directed:
            self.graph[v].append(u)
    
    def dfs(self, start, visited=None):
        """Depth-First Search"""
        if visited is None:
            visited = set()
        
        visited.add(start)
        result = [start]
        
        for neighbor in self.graph[start]:
            if neighbor not in visited:
                result.extend(self.dfs(neighbor, visited))
        
        return result
    
    def bfs(self, start):
        """Breadth-First Search"""
        visited = set()
        queue = deque([start])
        visited.add(start)
        result = []
        
        while queue:
            vertex = queue.popleft()
            result.append(vertex)
            
            for neighbor in self.graph[vertex]:
                if neighbor not in visited:
                    visited.add(neighbor)
                    queue.append(neighbor)
        
        return result
    
    def has_cycle_directed(self):
        """Detect cycle in directed graph using DFS"""
        WHITE, GRAY, BLACK = 0, 1, 2
        colors = {v: WHITE for v in self.vertices}
        
        def dfs_visit(node):
            if colors[node] == GRAY:
                return True  # Back edge found, cycle detected
            
            if colors[node] == BLACK:
                return False
            
            colors[node] = GRAY
            
            for neighbor in self.graph[node]:
                if dfs_visit(neighbor):
                    return True
            
            colors[node] = BLACK
            return False
        
        for vertex in self.vertices:
            if colors[vertex] == WHITE:
                if dfs_visit(vertex):
                    return True
        
        return False
    
    def topological_sort(self):
        """Topological sort using DFS"""
        visited = set()
        stack = []
        
        def dfs_visit(node):
            visited.add(node)
            
            for neighbor in self.graph[node]:
                if neighbor not in visited:
                    dfs_visit(neighbor)
            
            stack.append(node)
        
        for vertex in self.vertices:
            if vertex not in visited:
                dfs_visit(vertex)
        
        return stack[::-1]  # Reverse to get correct order
    
    def shortest_path_unweighted(self, start, end):
        """Shortest path in unweighted graph using BFS"""
        if start == end:
            return [start]
        
        visited = set()
        queue = deque([(start, [start])])
        visited.add(start)
        
        while queue:
            vertex, path = queue.popleft()
            
            for neighbor in self.graph[vertex]:
                if neighbor == end:
                    return path + [neighbor]
                
                if neighbor not in visited:
                    visited.add(neighbor)
                    queue.append((neighbor, path + [neighbor]))
        
        return None  # No path found

class WeightedGraph:
    def __init__(self):
        self.graph = defaultdict(list)
        self.vertices = set()
    
    def add_edge(self, u, v, weight, directed=False):
        """Add weighted edge"""
        self.graph[u].append((v, weight))
        self.vertices.add(u)
        self.vertices.add(v)
        
        if not directed:
            self.graph[v].append((u, weight))
    
    def dijkstra(self, start):
        """Dijkstra's shortest path algorithm"""
        import heapq
        
        distances = {v: float('inf') for v in self.vertices}
        distances[start] = 0
        pq = [(0, start)]
        visited = set()
        
        while pq:
            current_dist, current_vertex = heapq.heappop(pq)
            
            if current_vertex in visited:
                continue
            
            visited.add(current_vertex)
            
            for neighbor, weight in self.graph[current_vertex]:
                distance = current_dist + weight
                
                if distance < distances[neighbor]:
                    distances[neighbor] = distance
                    heapq.heappush(pq, (distance, neighbor))
        
        return distances
    
    def bellman_ford(self, start):
        """Bellman-Ford algorithm (handles negative weights)"""
        distances = {v: float('inf') for v in self.vertices}
        distances[start] = 0
        
        # Relax edges repeatedly
        for _ in range(len(self.vertices) - 1):
            for u in self.vertices:
                for v, weight in self.graph[u]:
                    if distances[u] != float('inf') and distances[u] + weight < distances[v]:
                        distances[v] = distances[u] + weight
        
        # Check for negative cycles
        for u in self.vertices:
            for v, weight in self.graph[u]:
                if distances[u] != float('inf') and distances[u] + weight < distances[v]:
                    return None  # Negative cycle detected
        
        return distances

# Graph Problems
class GraphProblems:
    
    def num_islands(self, grid):
        """
        Count number of islands in 2D grid.
        Time: O(m*n), Space: O(m*n)
        """
        if not grid or not grid[0]:
            return 0
        
        rows, cols = len(grid), len(grid[0])
        visited = set()
        islands = 0
        
        def dfs(r, c):
            if (r, c) in visited or r < 0 or r >= rows or c < 0 or c >= cols or grid[r][c] == '0':
                return
            
            visited.add((r, c))
            
            # Visit all 4 directions
            directions = [(0, 1), (1, 0), (0, -1), (-1, 0)]
            for dr, dc in directions:
                dfs(r + dr, c + dc)
        
        for r in range(rows):
            for c in range(cols):
                if grid[r][c] == '1' and (r, c) not in visited:
                    dfs(r, c)
                    islands += 1
        
        return islands
    
    def course_schedule(self, num_courses, prerequisites):
        """
        Check if all courses can be finished (cycle detection).
        Time: O(V + E), Space: O(V + E)
        """
        graph = defaultdict(list)
        
        for course, prereq in prerequisites:
            graph[prereq].append(course)
        
        WHITE, GRAY, BLACK = 0, 1, 2
        colors = [WHITE] * num_courses
        
        def has_cycle(node):
            if colors[node] == GRAY:
                return True
            
            if colors[node] == BLACK:
                return False
            
            colors[node] = GRAY
            
            for neighbor in graph[node]:
                if has_cycle(neighbor):
                    return True
            
            colors[node] = BLACK
            return False
        
        for i in range(num_courses):
            if colors[i] == WHITE:
                if has_cycle(i):
                    return False
        
        return True
    
    def clone_graph(self, node):
        """
        Clone an undirected graph.
        Time: O(V + E), Space: O(V)
        """
        if not node:
            return None
        
        visited = {}
        
        def clone(original):
            if original in visited:
                return visited[original]
            
            copy = Node(original.val)
            visited[original] = copy
            
            for neighbor in original.neighbors:
                copy.neighbors.append(clone(neighbor))
            
            return copy
        
        return clone(node)

# Test the graph implementations
def test_graph_problems():
    # Test unweighted graph
    g = Graph()
    g.add_edge(0, 1)
    g.add_edge(0, 2)
    g.add_edge(1, 2)
    g.add_edge(2, 3)
    
    print("DFS from 0:", g.dfs(0))
    print("BFS from 0:", g.bfs(0))
    print("Shortest path 0->3:", g.shortest_path_unweighted(0, 3))
    
    # Test weighted graph
    wg = WeightedGraph()
    wg.add_edge('A', 'B', 4)
    wg.add_edge('A', 'C', 2)
    wg.add_edge('B', 'C', 1)
    wg.add_edge('B', 'D', 5)
    wg.add_edge('C', 'D', 8)
    
    print("Dijkstra from A:", wg.dijkstra('A'))
    
    # Test graph problems
    gp = GraphProblems()
    
    # Islands problem
    grid = [
        ['1','1','1','1','0'],
        ['1','1','0','1','0'],
        ['1','1','0','0','0'],
        ['0','0','0','0','0']
    ]
    print("Number of islands:", gp.num_islands(grid))
    
    # Course schedule
    print("Can finish courses:", gp.course_schedule(2, [[1,0]]))  # True
    print("Can finish courses:", gp.course_schedule(2, [[1,0],[0,1]]))  # False

test_graph_problems()
```

---

## Dynamic Programming

### DP Fundamentals and Classic Problems

```python
class DynamicProgramming:
    
    def fibonacci(self, n):
        """
        Fibonacci sequence with memoization.
        Time: O(n), Space: O(n)
        """
        memo = {}
        
        def fib(num):
            if num in memo:
                return memo[num]
            
            if num <= 1:
                return num
            
            memo[num] = fib(num - 1) + fib(num - 2)
            return memo[num]
        
        return fib(n)
    
    def fibonacci_iterative(self, n):
        """
        Fibonacci with space optimization.
        Time: O(n), Space: O(1)
        """
        if n <= 1:
            return n
        
        prev, curr = 0, 1
        for _ in range(2, n + 1):
            prev, curr = curr, prev + curr
        
        return curr
    
    def climbing_stairs(self, n):
        """
        Number of ways to climb n stairs (1 or 2 steps at a time).
        Time: O(n), Space: O(1)
        """
        if n <= 2:
            return n
        
        prev1, prev2 = 1, 2
        for _ in range(3, n + 1):
            curr = prev1 + prev2
            prev1, prev2 = prev2, curr
        
        return prev2
    
    def coin_change(self, coins, amount):
        """
        Minimum coins needed to make amount.
        Time: O(amount * len(coins)), Space: O(amount)
        """
        dp = [float('inf')] * (amount + 1)
        dp[0] = 0
        
        for i in range(1, amount + 1):
            for coin in coins:
                if coin <= i:
                    dp[i] = min(dp[i], dp[i - coin] + 1)
        
        return dp[amount] if dp[amount] != float('inf') else -1
    
    def longest_increasing_subsequence(self, nums):
        """
        Length of longest increasing subsequence.
        Time: O(n²), Space: O(n)
        """
        if not nums:
            return 0
        
        dp = [1] * len(nums)
        
        for i in range(1, len(nums)):
            for j in range(i):
                if nums[j] < nums[i]:
                    dp[i] = max(dp[i], dp[j] + 1)
        
        return max(dp)
    
    def longest_common_subsequence(self, text1, text2):
        """
        Length of longest common subsequence.
        Time: O(m*n), Space: O(m*n)
        """
        m, n = len(text1), len(text2)
        dp = [[0] * (n + 1) for _ in range(m + 1)]
        
        for i in range(1, m + 1):
            for j in range(1, n + 1):
                if text1[i-1] == text2[j-1]:
                    dp[i][j] = dp[i-1][j-1] + 1
                else:
                    dp[i][j] = max(dp[i-1][j], dp[i][j-1])
        
        return dp[m][n]
    
    def knapsack_01(self, weights, values, capacity):
        """
        0/1 Knapsack problem.
        Time: O(n*capacity), Space: O(n*capacity)
        """
        n = len(weights)
        dp = [[0] * (capacity + 1) for _ in range(n + 1)]
        
        for i in range(1, n + 1):
            for w in range(1, capacity + 1):
                # Don't include current item
                dp[i][w] = dp[i-1][w]
                
                # Include current item if possible
                if weights[i-1] <= w:
                    dp[i][w] = max(dp[i][w], 
                                   dp[i-1][w - weights[i-1]] + values[i-1])
        
        return dp[n][capacity]
    
    def edit_distance(self, word1, word2):
        """
        Minimum edit distance (Levenshtein distance).
        Time: O(m*n), Space: O(m*n)
        """
        m, n = len(word1), len(word2)
        dp = [[0] * (n + 1) for _ in range(m + 1)]
        
        # Initialize base cases
        for i in range(m + 1):
            dp[i][0] = i
        for j in range(n + 1):
            dp[0][j] = j
        
        for i in range(1, m + 1):
            for j in range(1, n + 1):
                if word1[i-1] == word2[j-1]:
                    dp[i][j] = dp[i-1][j-1]
                else:
                    dp[i][j] = 1 + min(
                        dp[i-1][j],    # deletion
                        dp[i][j-1],    # insertion
                        dp[i-1][j-1]   # substitution
                    )
        
        return dp[m][n]
    
    def house_robber(self, nums):
        """
        Maximum money that can be robbed without robbing adjacent houses.
        Time: O(n), Space: O(1)
        """
        if not nums:
            return 0
        if len(nums) == 1:
            return nums[0]
        
        prev2 = nums[0]
        prev1 = max(nums[0], nums[1])
        
        for i in range(2, len(nums)):
            curr = max(prev1, prev2 + nums[i])
            prev2, prev1 = prev1, curr
        
        return prev1
    
    def word_break(self, s, word_dict):
        """
        Check if string can be segmented into words from dictionary.
        Time: O(n³), Space: O(n)
        """
        dp = [False] * (len(s) + 1)
        dp[0] = True
        word_set = set(word_dict)
        
        for i in range(1, len(s) + 1):
            for j in range(i):
                if dp[j] and s[j:i] in word_set:
                    dp[i] = True
                    break
        
        return dp[len(s)]
    
    def max_subarray_2d(self, matrix):
        """
        Maximum sum rectangle in 2D matrix (Kadane's 2D extension).
        Time: O(n²*m), Space: O(m)
        """
        if not matrix or not matrix[0]:
            return 0
        
        rows, cols = len(matrix), len(matrix[0])
        max_sum = float('-inf')
        
        for top in range(rows):
            temp = [0] * cols
            
            for bottom in range(top, rows):
                # Add current row to temp array
                for col in range(cols):
                    temp[col] += matrix[bottom][col]
                
                # Apply Kadane's algorithm on temp array
                current_sum = max_sum_1d = temp[0]
                for i in range(1, cols):
                    current_sum = max(temp[i], current_sum + temp[i])
                    max_sum_1d = max(max_sum_1d, current_sum)
                
                max_sum = max(max_sum, max_sum_1d)
        
        return max_sum

# Test DP problems
def test_dp_problems():
    dp = DynamicProgramming()
    
    print("DP Problems:")
    print("Fibonacci(10):", dp.fibonacci(10))  # 55
    print("Climbing stairs(5):", dp.climbing_stairs(5))  # 8
    print("Coin change([1,3,4], 6):", dp.coin_change([1, 3, 4], 6))  # 2
    print("LIS([10,9,2,5,3,7,101,18]):", dp.longest_increasing_subsequence([10,9,2,5,3,7,101,18]))  # 4
    print("LCS('abcde', 'ace'):", dp.longest_common_subsequence("abcde", "ace"))  # 3
    print("0/1 Knapsack:", dp.knapsack_01([1,3,4,5], [1,4,5,7], 7))  # 9
    print("Edit distance('horse', 'ros'):", dp.edit_distance("horse", "ros"))  # 3
    print("House robber([2,7,9,3,1]):", dp.house_robber([2,7,9,3,1]))  # 12
    print("Word break('leetcode', ['leet','code']):", dp.word_break("leetcode", ["leet", "code"]))  # True

test_dp_problems()
```

---

## Recursion & Backtracking

### Recursive Algorithms and Backtracking Problems

```python
class RecursionBacktracking:
    
    def permutations(self, nums):
        """
        Generate all permutations of a list.
        Time: O(n! * n), Space: O(n! * n)
        """
        result = []
        
        def backtrack(current_perm):
            if len(current_perm) == len(nums):
                result.append(current_perm[:])
                return
            
            for num in nums:
                if num not in current_perm:
                    current_perm.append(num)
                    backtrack(current_perm)
                    current_perm.pop()
        
        backtrack([])
        return result
    
    def combinations(self, n, k):
        """
        Generate all combinations of k numbers from 1 to n.
        Time: O(C(n,k) * k), Space: O(C(n,k) * k)
        """
        result = []
        
        def backtrack(start, current_combo):
            if len(current_combo) == k:
                result.append(current_combo[:])
                return
            
            for i in range(start, n + 1):
                current_combo.append(i)
                backtrack(i + 1, current_combo)
                current_combo.pop()
        
        backtrack(1, [])
        return result
    
    def subsets(self, nums):
        """
        Generate all subsets (power set).
        Time: O(2^n * n), Space: O(2^n * n)
        """
        result = []
        
        def backtrack(start, current_subset):
            result.append(current_subset[:])
            
            for i in range(start, len(nums)):
                current_subset.append(nums[i])
                backtrack(i + 1, current_subset)
                current_subset.pop()
        
        backtrack(0, [])
        return result
    
    def n_queens(self, n):
        """
        Solve N-Queens problem.
        Time: O(n!), Space: O(n²)
        """
        result = []
        board = [['.' for _ in range(n)] for _ in range(n)]
        
        def is_safe(row, col):
            # Check column
            for i in range(row):
                if board[i][col] == 'Q':
                    return False
            
            # Check diagonal (top-left to bottom-right)
            i, j = row - 1, col - 1
            while i >= 0 and j >= 0:
                if board[i][j] == 'Q':
                    return False
                i -= 1
                j -= 1
            
            # Check diagonal (top-right to bottom-left)
            i, j = row - 1, col + 1
            while i >= 0 and j < n:
                if board[i][j] == 'Q':
                    return False
                i -= 1
                j += 1
            
            return True
        
        def solve(row):
            if row == n:
                result.append([''.join(row) for row in board])
                return
            
            for col in range(n):
                if is_safe(row, col):
                    board[row][col] = 'Q'
                    solve(row + 1)
                    board[row][col] = '.'
        
        solve(0)
        return result
    
    def sudoku_solver(self, board):
        """
        Solve Sudoku puzzle.
        Time: O(9^(n*n)), Space: O(n*n)
        """
        def is_valid(row, col, num):
            # Check row
            for c in range(9):
                if board[row][c] == num:
                    return False
            
            # Check column
            for r in range(9):
                if board[r][col] == num:
                    return False
            
            # Check 3x3 box
            start_row = (row // 3) * 3
            start_col = (col // 3) * 3
            for r in range(start_row, start_row + 3):
                for c in range(start_col, start_col + 3):
                    if board[r][c] == num:
                        return False
            
            return True
        
        def solve():
            for row in range(9):
                for col in range(9):
                    if board[row][col] == '.':
                        for num in '123456789':
                            if is_valid(row, col, num):
                                board[row][col] = num
                                if solve():
                                    return True
                                board[row][col] = '.'
                        return False
            return True
        
        return solve()
    
    def word_search(self, board, word):
        """
        Search for word in 2D board.
        Time: O(m*n*4^L), Space: O(L) where L is word length
        """
        if not board or not board[0]:
            return False
        
        rows, cols = len(board), len(board[0])
        
        def backtrack(row, col, index):
            if index == len(word):
                return True
            
            if (row < 0 or row >= rows or col < 0 or col >= cols or 
                board[row][col] != word[index]):
                return False
            
            # Mark cell as visited
            temp = board[row][col]
            board[row][col] = '#'
            
            # Search in all 4 directions
            found = (backtrack(row + 1, col, index + 1) or
                     backtrack(row - 1, col, index + 1) or
                     backtrack(row, col + 1, index + 1) or
                     backtrack(row, col - 1, index + 1))
            
            # Restore cell
            board[row][col] = temp
            
            return found
        
        for row in range(rows):
            for col in range(cols):
                if backtrack(row, col, 0):
                    return True
        
        return False
    
    def generate_parentheses(self, n):
        """
        Generate all valid parentheses combinations.
        Time: O(4^n / √n), Space: O(4^n / √n)
        """
        result = []
        
        def backtrack(current, open_count, close_count):
            if len(current) == 2 * n:
                result.append(current)
                return
            
            if open_count < n:
                backtrack(current + '(', open_count + 1, close_count)
            
            if close_count < open_count:
                backtrack(current + ')', open_count, close_count + 1)
        
        backtrack('', 0, 0)
        return result
    
    def letter_combinations(self, digits):
        """
        Letter combinations of phone number.
        Time: O(4^n), Space: O(4^n)
        """
        if not digits:
            return []
        
        phone = {
            '2': 'abc', '3': 'def', '4': 'ghi', '5': 'jkl',
            '6': 'mno', '7': 'pqrs', '8': 'tuv', '9': 'wxyz'
        }
        
        result = []
        
        def backtrack(index, current):
            if index == len(digits):
                result.append(current)
                return
            
            letters = phone[digits[index]]
            for letter in letters:
                backtrack(index + 1, current + letter)
        
        backtrack(0, '')
        return result

# Test recursion and backtracking
def test_recursion_backtracking():
    rb = RecursionBacktracking()
    
    print("Recursion & Backtracking:")
    print("Permutations([1,2,3]):", rb.permutations([1, 2, 3]))
    print("Combinations(4,2):", rb.combinations(4, 2))
    print("Subsets([1,2,3]):", rb.subsets([1, 2, 3]))
    print("Generate parentheses(3):", rb.generate_parentheses(3))
    print("Letter combinations('23'):", rb.letter_combinations('23'))
    
    # N-Queens for small n
    print("4-Queens solutions:", len(rb.n_queens(4)))

test_recursion_backtracking()
```

---

## System-Level Problems

### LRU Cache, Rate Limiter, Thread-Safe Designs

```python
import threading
import time
from collections import OrderedDict
from threading import Lock, RLock

class LRUCache:
    """
    Least Recently Used Cache implementation.
    Time: O(1) for get and put operations
    Space: O(capacity)
    """
    
    def __init__(self, capacity):
        self.capacity = capacity
        self.cache = OrderedDict()
        self.lock = Lock()  # Thread-safe version
    
    def get(self, key):
        with self.lock:
            if key in self.cache:
                # Move to end (most recently used)
                value = self.cache.pop(key)
                self.cache[key] = value
                return value
            return -1
    
    def put(self, key, value):
        with self.lock:
            if key in self.cache:
                # Update existing key
                self.cache.pop(key)
            elif len(self.cache) >= self.capacity:
                # Remove least recently used
                self.cache.popitem(last=False)
            
            self.cache[key] = value

class TokenBucketRateLimiter:
    """
    Token Bucket Rate Limiter implementation.
    """
    
    def __init__(self, capacity, refill_rate):
        self.capacity = capacity
        self.tokens = capacity
        self.refill_rate = refill_rate  # tokens per second
        self.last_refill = time.time()
        self.lock = Lock()
    
    def _refill(self):
        """Refill tokens based on time elapsed"""
        now = time.time()
        tokens_to_add = (now - self.last_refill) * self.refill_rate
        self.tokens = min(self.capacity, self.tokens + tokens_to_add)
        self.last_refill = now
    
    def allow_request(self, tokens_needed=1):
        """Check if request is allowed"""
        with self.lock:
            self._refill()
            
            if self.tokens >= tokens_needed:
                self.tokens -= tokens_needed
                return True
            return False

class SlidingWindowRateLimiter:
    """
    Sliding Window Rate Limiter implementation.
    """
    
    def __init__(self, max_requests, window_size):
        self.max_requests = max_requests
        self.window_size = window_size  # in seconds
        self.requests = {}  # user_id -> list of timestamps
        self.lock = Lock()
    
    def allow_request(self, user_id):
        """Check if request is allowed for user"""
        with self.lock:
            now = time.time()
            
            if user_id not in self.requests:
                self.requests[user_id] = []
            
            # Remove old requests outside window
            user_requests = self.requests[user_id]
            self.requests[user_id] = [
                req_time for req_time in user_requests 
                if now - req_time < self.window_size
            ]
            
            # Check if under limit
            if len(self.requests[user_id]) < self.max_requests:
                self.requests[user_id].append(now)
                return True
            
            return False

class ThreadSafeCounter:
    """
    Thread-safe counter with atomic operations.
    """
    
    def __init__(self, initial_value=0):
        self._value = initial_value
        self._lock = RLock()
    
    def increment(self, amount=1):
        with self._lock:
            self._value += amount
            return self._value
    
    def decrement(self, amount=1):
        with self._lock:
            self._value -= amount
            return self._value
    
    @property
    def value(self):
        with self._lock:
            return self._value
    
    def reset(self):
        with self._lock:
            self._value = 0

class ThreadSafeMap:
    """
    Thread-safe map implementation.
    """
    
    def __init__(self):
        self._data = {}
        self._lock = RLock()
    
    def put(self, key, value):
        with self._lock:
            self._data[key] = value
    
    def get(self, key, default=None):
        with self._lock:
            return self._data.get(key, default)
    
    def remove(self, key):
        with self._lock:
            return self._data.pop(key, None)
    
    def contains(self, key):
        with self._lock:
            return key in self._data
    
    def size(self):
        with self._lock:
            return len(self._data)
    
    def keys(self):
        with self._lock:
            return list(self._data.keys())

class ProducerConsumerQueue:
    """
    Thread-safe producer-consumer queue with blocking operations.
    """
    
    def __init__(self, capacity):
        self.capacity = capacity
        self.queue = []
        self.lock = Lock()
        self.not_full = threading.Condition(self.lock)
        self.not_empty = threading.Condition(self.lock)
    
    def put(self, item, timeout=None):
        """Put item in queue (blocks if full)"""
        with self.not_full:
            while len(self.queue) >= self.capacity:
                if not self.not_full.wait(timeout):
                    return False
            
            self.queue.append(item)
            self.not_empty.notify()
            return True
    
    def get(self, timeout=None):
        """Get item from queue (blocks if empty)"""
        with self.not_empty:
            while not self.queue:
                if not self.not_empty.wait(timeout):
                    return None
            
            item = self.queue.pop(0)
            self.not_full.notify()
            return item
    
    def size(self):
        with self.lock:
            return len(self.queue)

class ConnectionPool:
    """
    Thread-safe connection pool.
    """
    
    def __init__(self, create_connection, max_connections=10):
        self.create_connection = create_connection
        self.max_connections = max_connections
        self.pool = []
        self.active_connections = 0
        self.lock = Lock()
        self.available = threading.Condition(self.lock)
    
    def get_connection(self, timeout=None):
        """Get connection from pool"""
        with self.available:
            while not self.pool and self.active_connections >= self.max_connections:
                if not self.available.wait(timeout):
                    return None
            
            if self.pool:
                connection = self.pool.pop()
            else:
                connection = self.create_connection()
                self.active_connections += 1
            
            return connection
    
    def return_connection(self, connection):
        """Return connection to pool"""
        with self.available:
            self.pool.append(connection)
            self.available.notify()
    
    def close_all(self):
        """Close all connections"""
        with self.lock:
            for conn in self.pool:
                if hasattr(conn, 'close'):
                    conn.close()
            self.pool.clear()
            self.active_connections = 0

# Example usage and testing
def test_system_level_problems():
    print("System-Level Problems Testing:")
    
    # Test LRU Cache
    print("\n1. LRU Cache:")
    lru = LRUCache(2)
    lru.put(1, 1)
    lru.put(2, 2)
    print(f"Get 1: {lru.get(1)}")  # 1
    lru.put(3, 3)  # evicts key 2
    print(f"Get 2: {lru.get(2)}")  # -1 (not found)
    
    # Test Rate Limiter
    print("\n2. Token Bucket Rate Limiter:")
    rate_limiter = TokenBucketRateLimiter(capacity=5, refill_rate=1)
    
    for i in range(7):
        allowed = rate_limiter.allow_request()
        print(f"Request {i+1}: {'Allowed' if allowed else 'Denied'}")
        if i == 4:  # After 5 requests, wait to refill
            time.sleep(1.1)
    
    # Test Thread-Safe Counter
    print("\n3. Thread-Safe Counter:")
    counter = ThreadSafeCounter()
    
    def increment_worker():
        for _ in range(1000):
            counter.increment()
    
    threads = []
    for _ in range(5):
        thread = threading.Thread(target=increment_worker)
        threads.append(thread)
        thread.start()
    
    for thread in threads:
        thread.join()
    
    print(f"Final counter value: {counter.value}")  # Should be 5000
    
    # Test Producer-Consumer
    print("\n4. Producer-Consumer Queue:")
    queue = ProducerConsumerQueue(capacity=3)
    
    def producer():
        for i in range(5):
            queue.put(f"item-{i}")
            print(f"Produced: item-{i}")
            time.sleep(0.1)
    
    def consumer():
        for _ in range(5):
            item = queue.get(timeout=1)
            if item:
                print(f"Consumed: {item}")
            time.sleep(0.2)
    
    producer_thread = threading.Thread(target=producer)
    consumer_thread = threading.Thread(target=consumer)
    
    producer_thread.start()
    consumer_thread.start()
    
    producer_thread.join()
    consumer_thread.join()

# Run tests
test_system_level_problems()
```

---

## Interview Questions and Answers

| # | Difficulty | Question | Answer |
|---|------------|----------|---------|
| 1 | Easy | What is time complexity? | A measure of how algorithm runtime grows with input size. O(1), O(log n), O(n), O(n²), etc. |
| 2 | Easy | What is space complexity? | Amount of memory an algorithm uses relative to input size |
| 3 | Easy | What is Big O notation? | Mathematical notation describing upper bound of algorithm complexity |
| 4 | Easy | What is the time complexity of array access? | O(1) - constant time as arrays support random access |
| 5 | Easy | How do you reverse a string? | Two pointers approach: swap characters from start and end moving inward |
| 6 | Easy | What is a hash table? | Data structure storing key-value pairs with O(1) average lookup time |
| 7 | Easy | What causes hash collisions? | When different keys produce same hash value |
| 8 | Easy | What is a linked list? | Linear data structure where elements point to next element |
| 9 | Easy | Difference between array and linked list? | Arrays: random access O(1), fixed size. Lists: sequential access O(n), dynamic size |
| 10 | Easy | What is a stack? | LIFO (Last In First Out) data structure with push/pop operations |
| 11 | Easy | What is a queue? | FIFO (First In First Out) data structure with enqueue/dequeue operations |
| 12 | Easy | What is recursion? | Function calling itself with base case to prevent infinite recursion |
| 13 | Easy | What is the base case in recursion? | Condition that stops recursive calls to prevent infinite recursion |
| 14 | Easy | What is a binary tree? | Tree data structure where each node has at most two children |
| 15 | Easy | What is tree traversal? | Process of visiting all nodes in tree: inorder, preorder, postorder, level-order |
| 16 | Medium | Find two sum in array | Use hash map to store complements. O(n) time, O(n) space |
| 17 | Medium | Detect cycle in linked list | Floyd's cycle detection (tortoise and hare) - two pointers at different speeds |
| 18 | Medium | Find middle of linked list | Two pointers: slow moves 1 step, fast moves 2 steps |
| 19 | Medium | Merge two sorted arrays | Two pointers approach comparing elements from both arrays |
| 20 | Medium | Valid parentheses problem | Use stack to track opening brackets, pop when closing bracket matches |
| 21 | Medium | Binary search implementation | Divide and conquer: compare with middle, eliminate half each iteration |
| 22 | Medium | What is dynamic programming? | Optimization technique storing results of subproblems to avoid recomputation |
| 23 | Medium | Memoization vs tabulation? | Memoization: top-down recursive with cache. Tabulation: bottom-up iterative |
| 24 | Medium | Longest common subsequence | DP problem: build table comparing characters from both strings |
| 25 | Medium | Fibonacci with DP | Store previous results: F(n) = F(n-1) + F(n-2) |
| 26 | Medium | Coin change problem | DP: minimum coins needed to make amount using given denominations |
| 27 | Medium | What is backtracking? | Trial and error approach: explore solution, backtrack if invalid |
| 28 | Medium | N-Queens problem | Backtracking: place queens avoiding attacks, backtrack if no valid position |
| 29 | Medium | Generate all permutations | Backtracking: swap elements, recurse, backtrack to try other combinations |
| 30 | Medium | Subset generation | Backtracking or bit manipulation to generate all possible subsets |
| 31 | Hard | Implement LRU Cache | Hash map + doubly linked list for O(1) get/put operations |
| 32 | Hard | Serialize/deserialize binary tree | Convert tree to string representation and back |
| 33 | Hard | Word ladder problem | BFS to find shortest transformation path between words |
| 34 | Hard | Merge k sorted lists | Priority queue or divide and conquer approach |
| 35 | Hard | Maximum subarray sum | Kadane's algorithm: track current and maximum sum |
| 36 | Hard | Lowest common ancestor in BST | Use BST property: compare with root value to determine direction |
| 37 | Hard | Graph cycle detection | DFS with color coding: white, gray, black nodes |
| 38 | Hard | Topological sorting | DFS or Kahn's algorithm for ordering dependencies |
| 39 | Hard | Dijkstra's shortest path | Priority queue with distance tracking for weighted graphs |
| 40 | Hard | Union-Find data structure | Disjoint set with path compression and union by rank |
| 41 | Hard | Sliding window maximum | Deque storing indices of array elements in decreasing order |
| 42 | Hard | Edit distance (Levenshtein) | DP: minimum operations to transform one string to another |
| 43 | Hard | Regular expression matching | DP with state transitions for pattern matching |
| 44 | Hard | Longest increasing subsequence | DP with binary search optimization to O(n log n) |
| 45 | Hard | Maximum flow problem | Ford-Fulkerson or Edmonds-Karp algorithm |
| 46 | Expert | Segment tree implementation | Binary tree for range queries and updates in O(log n) |
| 47 | Expert | Fenwick tree (BIT) | Compact data structure for prefix sum queries |
| 48 | Expert | Trie (prefix tree) | Tree for string operations, autocomplete, spell check |
| 49 | Expert | KMP string matching | Linear time string search using failure function |
| 50 | Expert | Manacher's algorithm | Linear time palindrome detection in strings |
| 51 | Expert | Heavy-light decomposition | Tree decomposition technique for path queries |
| 52 | Expert | Persistent data structures | Immutable versions preserving previous states |
| 53 | Expert | Suffix array and LCP | String processing for pattern matching and repetition finding |
| 54 | Expert | Convex hull algorithms | Graham scan, Jarvis march for computational geometry |
| 55 | Expert | Fast Fourier Transform | Algorithm for polynomial multiplication in O(n log n) |
