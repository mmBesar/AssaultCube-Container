# ── STAGE 1: BUILD THE SERVER ─────────────────────────────────────────────
FROM debian:bookworm-slim AS builder

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      build-essential git clang libsdl2-dev zlib1g-dev \
      libogg-dev libvorbis-dev libopenal-dev libenet-dev \
      curl ca-certificates && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /build

# Clone AssaultCube source
RUN git clone --depth=1 https://github.com/assaultcube/AC.git .

# Build & package the dedicated server
# Run server_install from the 'source' folder to generate package_linux/
WORKDIR /build/source
RUN make clean && make server_install

# ── STAGE 2: RUNTIME IMAGE ─────────────────────────────────────────────────
FROM debian:bookworm-slim

# Runtime dependencies only
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      libsdl2-2.0-0 zlib1g libogg0 libvorbis0a libopenal1 libenet7 && \
    rm -rf /var/lib/apt/lists/*

# Copy the packaged server directory from builder
COPY --from=builder /build/source/package_linux /ac

# Copy your entrypoint wrapper
COPY entrypoint.sh /ac/entrypoint.sh

WORKDIR /ac
RUN chmod +x entrypoint.sh

# Expose UDP port for AssaultCube
EXPOSE 28763/udp

# Launch via wrapper
ENTRYPOINT ["/ac/entrypoint.sh"]
