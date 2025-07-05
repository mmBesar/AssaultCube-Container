# Use a lightweight Debian base image
FROM debian:bookworm-slim

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    git \
    libsdl1.2-dev \
    zlib1g-dev \
    libogg-dev \
    libvorbis-dev \
    libopenal-dev \
    libenet-dev \
    curl \
    ca-certificates && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /opt

# Clone AssaultCube repo (unofficial mirror or original source if available)
RUN git clone --depth=1 https://github.com/assaultcube/AC.git

# Build server
WORKDIR /opt/AC/source/src
RUN make server

# Set working directory to game root
WORKDIR /opt/AC

# Expose default server port (UDP)
EXPOSE 28763/udp

# Default command to run the AssaultCube server
CMD ["./server.sh", "-n"]
