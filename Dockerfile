# Step 1: Build the Jekyll site
FROM jekyll/jekyll:4.2.0 AS jekyll-build
WORKDIR /srv/jekyll
COPY . .
RUN jekyll build

# Step 2: Build your C++ service
FROM ubuntu:24.04 AS service-build

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
COPY . /service

# Set the working directory
WORKDIR /service/utility

# Run the installation script for oatpp modules
RUN ./install-oatpp-modules.sh

# Set the build directory
WORKDIR /service/build

# Run cmake and make to build your project
RUN cmake ..
RUN make

# Step 3: Create the final container that combines the Jekyll site and your service
FROM ubuntu:24.04

# Copy the built Jekyll site from the first stage
COPY --from=jekyll-build /srv/jekyll/_site /srv/jekyll/_site

# Copy the built service executable from the second stage
COPY --from=service-build /service/build/hls-example-exe /usr/local/bin/hls-example-exe

# Expose the necessary port
EXPOSE 8000

# Set the entrypoint to your C++ service
ENTRYPOINT ["hls-example-exe"]
