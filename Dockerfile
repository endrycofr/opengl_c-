# Use the Ubuntu base image
FROM ubuntu:latest

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    g++ \
    libgl1-mesa-dev \
    freeglut3-dev \
    libglew-dev \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /app

# Copy your source files into the container
COPY . .

# Build the application
RUN make

# Command to run the application
CMD ["./main"]