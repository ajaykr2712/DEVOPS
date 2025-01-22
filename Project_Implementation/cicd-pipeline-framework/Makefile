# Variables
IMAGE_NAME = cicd-pipeline-framework
IMAGE_TAG = $(shell date +%s)

# Docker commands
docker-build:
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) .

docker-run:
	docker run -p 3000:3000 $(IMAGE_NAME):$(IMAGE_TAG)

# Clean up
docker-clean:
	docker rmi $(IMAGE_NAME):$(IMAGE_TAG)

# Development commands
install:
	npm install

start:
	npm start

test:
	npm test
