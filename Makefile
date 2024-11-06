IMAGE_REG ?= docker.io
IMAGE_REPO ?= endrycofr/cpp_opengl  # Pastikan username sesuai dengan akun Docker Hub Anda
IMAGE_TAG ?= latest

# Compiler
CXX = g++

# Check the operating system
UNAME_S := $(shell uname -s)

# Compiler flags for different operating systems
ifeq ($(UNAME_S),Linux)
    CXXFLAGS = -I/usr/include -L/usr/lib -lGL -lGLU -lglut -lGLEW
  
else ifeq ($(UNAME_S),Darwin) # macOS is treated like Unix
    CXXFLAGS = -I/usr/local/include -lGL -lGLU -lglut -lGLEW

else # Windows
    CXXFLAGS = -I/mingw64/include -L/mingw64/lib -lopengl32 -lfreeglut -lglu32 -lglew32 -lglfw3 -lgdi32 -lwinmm

endif

# Source files
SRCS = main.cpp


# Output binaries
TARGET = main


# Explicitly define supported platforms
PLATFORMS = linux/amd64,linux/arm64

# Phony targets
.PHONY: all clean image push buildx-image buildx-push buildx-setup test

# Default target to build both main and test applications
all: $(TARGET) 

# Build the main application
$(TARGET): $(SRCS)
	$(CXX) -o $(TARGET) $(SRCS) $(CXXFLAGS) || { echo 'Build failed for $(TARGET)'; exit 1; }


# Clean target to remove compiled files
clean:
	rm -f $(TARGET) 

# Setup buildx builder with multi-platform support
buildx-setup:
	@echo "🔧 Setting up Docker Buildx builder..."
	docker buildx rm multiarch-builder || true
	docker buildx create --name multiarch-builder --driver docker-container --bootstrap
	docker buildx use multiarch-builder
	docker buildx inspect --bootstrap

# Multi-platform build and push using buildx
buildx-push: buildx-setup
	@echo "🚀 Building and pushing multi-arch images for platforms: $(PLATFORMS)"
	docker buildx build \
		--platform $(PLATFORMS) \
		-t $(IMAGE_REG)/$(IMAGE_REPO):$(IMAGE_TAG) \
		--push \
		. || { echo '❌ Buildx build and push failed'; exit 1; }
	@echo "✅ Successfully built and pushed images for AMD64 and ARM64"


# Build multi-arch images locally without pushing
buildx-image: buildx-setup
	@echo "🔨 Building multi-arch images locally for platforms: $(PLATFORMS)"
	docker buildx build \
		--platform $(PLATFORMS) \
		-t $(IMAGE_REG)/$(IMAGE_REPO):$(IMAGE_TAG) \
		--load \
		. || { echo '❌ Buildx build failed'; exit 1; }
	@echo "✅ Successfully built images for AMD64 and ARM64"

test: $(TEST_TARGET)
	@echo "Running tests..."
	chmod +x $(TEST_TARGET)
	./$(TEST_TARGET) || { echo 'Test execution failed'; exit 1; }