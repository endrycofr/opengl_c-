# Image registry details
IMAGE_REG ?= docker.io
IMAGE_REPO ?= endrycofr/cpp_opengl
IMAGE_TAG ?= latest

# Compiler settings
CXX = g++

# Detect operating system and set compiler flags accordingly
UNAME_S := $(shell uname -s)

ifeq ($(UNAME_S),Linux)
    CXXFLAGS = -I/usr/include -L/usr/lib -lGL -lGLU -lglut -lGLEW
else ifeq ($(UNAME_S),Darwin) # macOS settings
    CXXFLAGS = -I/usr/local/include -lGL -lGLU -lglut -lGLEW
else # Windows settings
    CXXFLAGS = -I/mingw64/include -L/mingw64/lib -lopengl32 -lfreeglut -lglu32 -lglew32 -lglfw3 -lgdi32 -lwinmm
endif

# Source and output files
SRCS = main.cpp
TARGET = main

# Platforms for multi-arch build
PLATFORMS = linux/amd64,linux/arm64

# Phony targets to avoid filename conflicts
.PHONY: all clean docker-check buildx-setup buildx-push buildx-image test

# Default target to build the application
all: $(TARGET)

# Build the main application
$(TARGET): $(SRCS)
	@echo "🔨 Building $(TARGET)..."
	$(CXX) -o $(TARGET) $(SRCS) $(CXXFLAGS) || { echo '❌ Build failed for $(TARGET)'; exit 1; }
	@echo "✅ Build completed for $(TARGET)"

# Clean up generated binaries
clean:
	@echo "🧹 Cleaning up..."
	rm -f $(TARGET)
	@echo "✅ Cleanup completed"

# Check Docker permissions
docker-check:
	@echo "🔍 Checking Docker permissions..."
	@if ! docker info >/dev/null 2>&1; then \
		echo "❌ Docker is not running or you don't have sufficient permissions."; \
		echo "👉 Suggested fixes:"; \
		echo "   1. Add your user to the Docker group:"; \
		echo "      sudo usermod -aG docker $$USER"; \
		echo "   2. Adjust permissions for the Docker socket:"; \
		echo "      sudo chmod 666 /var/run/docker.sock"; \
		echo "   3. Start Docker service:"; \
		echo "      sudo systemctl start docker"; \
		exit 1; \
	fi
	@echo "✅ Docker permissions are valid"

# Setup Docker Buildx for multi-platform builds
buildx-setup: docker-check
	@echo "🔧 Setting up Docker Buildx builder..."
	@if ! docker buildx version >/dev/null 2>&1; then \
		echo "❌ Docker Buildx not available. Ensure Docker version >= 19.03"; \
		exit 1; \
	fi
	docker run --rm --privileged tonistiigi/binfmt --install all || true
	docker buildx rm multiarch-builder || true
	docker buildx create --name multiarch-builder --driver docker-container --bootstrap
	docker buildx use multiarch-builder
	docker buildx inspect --bootstrap
	docker buildx ls
	@echo "✅ Docker Buildx setup completed"

# Multi-platform build and push using Buildx
buildx-push:
	@echo "🚀 Building and pushing multi-arch images for platforms: $(PLATFORMS)..."
	docker buildx build \
		--platform $(PLATFORMS) \
		-t $(IMAGE_REG)/$(IMAGE_REPO):$(IMAGE_TAG) \
		--push \
		. || { echo '❌ Buildx build and push failed'; exit 1; }
	@echo "✅ Successfully built and pushed images for $(PLATFORMS)"

# Multi-arch build without pushing (for local testing)
buildx-image:
	@echo "🔨 Building multi-arch images locally for platforms: $(PLATFORMS)..."
	docker buildx build \
		--platform $(PLATFORMS) \
		-t $(IMAGE_REG)/$(IMAGE_REPO):$(IMAGE_TAG) \
		--load \
		. || { echo '❌ Buildx build failed'; exit 1; }
	@echo "✅ Successfully built images for $(PLATFORMS)"

# Run tests (assuming test target exists)
test: $(TARGET)
	@echo "🧪 Running tests..."
	chmod +x $(TARGET)
	./$(TARGET) || { echo '❌ Test execution failed'; exit 1; }
	@echo "✅ All tests passed"
