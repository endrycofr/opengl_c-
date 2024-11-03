
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

# Output binary
TARGET = main.exe # Use .exe extension for Windows

# Default target
all: $(TARGET)

# Rule to build the target
$(TARGET): $(SRCS)
	$(CXX) -o $@ $^ $(CXXFLAGS)

# Clean target to remove compiled files
clean:
	rm -f $(TARGET)


image:  ## 🔨 Build container image from Dockerfile 
	docker build . --file build/Dockerfile \
	--tag $(IMAGE_REG)/$(IMAGE_REPO):$(IMAGE_TAG)

push:  ## 📤 Push container image to registry 
	docker push $(IMAGE_REG)/$(IMAGE_REPO):$(IMAGE_TAG)