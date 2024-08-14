# Use Ubuntu 24.04 as the base image
FROM ubuntu:24.04

# Install necessary dependencies
RUN apt-get update && apt-get install -y \
    cmake \
    g++ \
    git \
    make \
    wget \
    curl \
    unzip \
    libssl-dev \
    libcurl4-openssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Add your service code to the container
ADD . /service

# Set the working directory
WORKDIR /service/utility

# Run the installation script for oatpp modules
RUN ./install-oatpp-modules.sh

# Set the build directory
WORKDIR /service/build

# Run cmake and make to build your project
RUN cmake ..
RUN make

# Expose the required port(s)
EXPOSE 8000 8000

# Define the entrypoint
ENTRYPOINT ["./hls-example-exe"]
