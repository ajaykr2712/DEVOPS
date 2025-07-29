### Docker

**“What happens under the hood when you run a Docker container?”**

When you execute `docker run`, a sequence of events is triggered to create and start a container:

1.  **Client to Daemon**: The Docker client sends the command to the Docker daemon (`dockerd`).
2.  **Image Check**: The daemon checks if the specified image exists locally. If not, it pulls the image from a configured registry (like Docker Hub).
3.  **Filesystem Layers**: The image is composed of multiple read-only layers. Docker's storage driver (e.g., OverlayFS) stacks these layers to create a unified filesystem.
4.  **Writable Layer**: A thin, writable layer is added on top of the read-only layers. Any changes made by the container (creating/modifying/deleting files) are written to this layer. This is known as the "copy-on-write" mechanism.
5.  **Namespaces**: The daemon creates the container by utilizing Linux namespaces to provide isolation. Each container gets its own:
    *   `pid`: Process IDs
    *   `net`: Network stack (IP address, routing tables, ports)
    *   `mnt`: Filesystem mount points
    *   `ipc`: Inter-process communication
    *   `uts`: Hostname
6.  **Control Groups (cgroups)**: The daemon uses cgroups to enforce resource limits on the container, such as CPU and memory usage.
7.  **Execution**: The daemon executes the command specified in the image's configuration (`CMD` or `ENTRYPOINT`) within the newly created isolated environment.

### Images & Layers

**“Explain how Docker uses layered filesystems for caching.”**

Docker images are built using a layered filesystem. Each instruction in a `Dockerfile` (like `FROM`, `RUN`, `COPY`, `ADD`) creates a new, read-only layer.

**How Caching Works:**

1.  **Layer Immutability**: Each layer is immutable and has a unique hash (checksum).
2.  **Build Process**: When you build a Docker image, the Docker daemon processes each instruction in the `Dockerfile` sequentially.
3.  **Cache Check**: For each instruction, Docker checks its local build cache to see if a layer with the exact same parent layer and instruction already exists.
4.  **Cache Hit**: If a matching layer is found (a "cache hit"), Docker reuses that layer instead of executing the instruction again.
5.  **Cache Miss**: If no matching layer is found, the instruction is executed, and a new layer is created and added to the cache. This is a "cache miss."
6.  **Cache Invalidation**: Once an instruction results in a cache miss, all subsequent instructions in the `Dockerfile` will also result in cache misses and must be re-executed.

This layering and caching mechanism makes image builds significantly faster, as unchanged layers are simply reused from previous builds. It's why you should structure your `Dockerfile` to place frequently changing instructions (like `COPY . .`) as late as possible.

### Volumes vs Bind Mounts

**“When do you use one over the other?”**

Both are ways to persist data outside a container's writable layer, but they serve different purposes.

| Feature | Volumes | Bind Mounts |
| :--- | :--- | :--- |
| **Managed By** | Docker | The user (host system) |
| **Host Path** | Stored in a dedicated area on the host (`/var/lib/docker/volumes/` on Linux). You don't need to know the path. | An arbitrary file/directory on the host that you specify. |
| **Portability** | High. Works across platforms without path issues. | Low. Tied to the host's filesystem structure. |
| **Use Case** | **Production & Data Persistence**: The preferred way to persist data for stateful applications like databases, message queues, or application uploads. | **Development**: Ideal for mounting source code into a container for live-reloading, or for sharing config files from the host. |

**Rule of Thumb:**
*   Use **Volumes** for application data in production.
*   Use **Bind Mounts** for local development and sharing host files.

### K8s Pods

**“How does a ReplicaSet differ from a Deployment?”**

*   **ReplicaSet**: A lower-level Kubernetes controller whose only job is to ensure that a specified number of pod replicas are running at any given time. It's a self-healing mechanism; if a pod dies, the ReplicaSet replaces it. You rarely create a ReplicaSet directly.

*   **Deployment**: A higher-level controller that manages the lifecycle of your application. It uses a ReplicaSet underneath to manage the pods but adds crucial features on top, most importantly **declarative updates and rollbacks**.

When you update a Deployment (e.g., change the container image version), it orchestrates a **rolling update**:
1.  It creates a new ReplicaSet with the updated specification.
2.  It gradually scales up the new ReplicaSet while scaling down the old one.
3.  This ensures a zero-downtime update.
4.  It also keeps the old ReplicaSet around, allowing you to easily roll back to a previous version if something goes wrong.

**In short:** Use a **Deployment** to manage your stateless applications. The Deployment will create and manage ReplicaSets for you.

### ConfigMap/Secrets

**“How do you inject a Secret into a pod?”**

Secrets are used to store sensitive data like passwords, API keys, and TLS certificates. There are three primary ways to inject them into a pod:

1.  **As Environment Variables**: The key-value pairs from the Secret are exposed as environment variables inside the container.

    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
      name: my-pod
    spec:
      containers:
      - name: my-container
        image: redis
        envFrom:
        - secretRef:
            name: my-secret # Name of the Secret object
    ```

2.  **As Files in a Volume**: The Secret's data is mounted as files into a specific directory inside the container. This is generally more secure than environment variables.

    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
      name: my-pod
    spec:
      containers:
      - name: my-container
        image: my-app
        volumeMounts:
        - name: secret-volume
          mountPath: "/etc/secrets"
          readOnly: true
      volumes:
      - name: secret-volume
        secret:
          secretName: my-secret
    ```

3.  **Using `imagePullSecrets`**: A special type of secret used to authenticate with a private container registry to pull images.

    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
      name: private-reg-pod
    spec:
      containers:
      - name: my-container
        image: my-private-registry/my-app:1.0
      imagePullSecrets:
      - name: my-registry-key
    ```

### Probes

**“Difference between Liveness and Readiness?”**

Probes are health checks that the kubelet performs on containers.

*   **Liveness Probe**: Answers the question, "**Is this container running correctly?**"
    *   If the liveness probe fails, the kubelet will kill the container and restart it according to its `restartPolicy`.
    *   **Use Case**: To detect deadlocks or applications that have become unresponsive but are still running. It helps turn a broken application into a restarted one.

*   **Readiness Probe**: Answers the question, "**Is this container ready to serve traffic?**"
    *   If the readiness probe fails, the container is *not* killed. Instead, its pod's IP address is removed from the endpoints of all Services it belongs to.
    *   **Use Case**: To signal that an application is temporarily unable to serve requests, for example, while it's starting up and loading data, or when it's overloaded. This prevents traffic from being sent to a pod that isn't ready for it.

| Probe | If it Fails... | Purpose |
| :--- | :--- | :--- |
| **Liveness** | Container is restarted. | Recover from a broken state. |
| **Readiness** | Pod is removed from Service endpoints. | Don't send traffic to a pod that isn't ready. |

### Job/CronJob

**“How would you schedule a DB cleanup job in K8s?”**

You would use a **CronJob**.

*   A **Job** is a Kubernetes object that creates one or more pods and ensures that a specified number of them successfully terminate. It's for running a task once.
*   A **CronJob** is a higher-level object that manages Jobs on a repeating schedule, defined in the standard Cron format.

To schedule a nightly database cleanup job, you would define a `CronJob` resource like this:

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: db-cleanup
spec:
  # Run every day at 2 AM
  schedule: "0 2 * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: cleanup-container
            image: my-db-cleanup-tool:latest # Your container image
            args:
            - "--prune-old-records"
            - "--days=30"
            envFrom:
            - secretRef:
                name: db-credentials # Use a secret for DB credentials
          restartPolicy: OnFailure # Or Never
```

This `CronJob` will create a new `Job` every day at 2 AM, which in turn will run a pod to execute your cleanup script.
