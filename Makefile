# Used by `image`, `push` & `deploy` targets, override as required
IMAGE_REG ?= docker.io
IMAGE_REPO ?= endrycofr/cpp_opengl
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
TEST_SRCS = test_opengl.cpp

# Output binaries
TARGET = main.exe
TEST_TARGET = opengl_test.exe

# Phony targets
.PHONY: all clean image push

# Default target to build both main and test applications
all: $(TARGET) $(TEST_TARGET)

# Build the main application
$(TARGET): $(SRCS)
	$(CXX) -o $(TARGET) $(SRCS) $(CXXFLAGS) || { echo 'Build failed for $(TARGET)'; exit 1; }

# Build the test application
$(TEST_TARGET): $(TEST_SRCS)
	$(CXX) -o $(TEST_TARGET) $(TEST_SRCS) $(CXXFLAGS) || { echo 'Build failed for $(TEST_TARGET)'; exit 1; }

# Clean target to remove compiled files
clean:
	rm -f $(TARGET) $(TEST_TARGET)

# Image target to build container image from Dockerfile
image:  ## 🔨 Build container image from Dockerfile 
	docker build . --file build/Dockerfile --tag $(IMAGE_REG)/$(IMAGE_REPO):$(IMAGE_TAG) || { echo 'Docker build failed'; exit 1; }

# Push target to push container image to registry 
push:  ## 📤 Push container image to registry 
	docker push $(IMAGE_REG)/$(IMAGE_REPO):$(IMAGE_TAG) || { echo 'Docker push failed'; exit 1; }


test:
	./$(TEST_TARGET) || { echo 'Test execution failed'; exit 1; }
