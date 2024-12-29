# 3_build_and_run

```
# Step 3: Build and Run the Docker Image

Once the `Dockerfile` is ready, follow these steps to build the image and run the container.

## Build the Docker Image
1. Build the image using the `docker build` command:
   ```bash
   docker build -t hello-world-python .

```

Here:

-t specifies the image name (hello-world-python).
. indicates the current directory contains the Dockerfile.

## Verify the image exists

```
docker images

```

### The  triggered Output must contain
REPOSITORY           TAG       IMAGE ID       CREATED       SIZE
hello-world-python   latest    <image-id>     <timestamp>   <size>



## Run The Docker Image Container

```
docker run hello-world-python

```

O/P: Hello, World!