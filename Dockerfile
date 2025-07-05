# ── STAGE 1: BUILD THE SERVER ─────────────────────────────────────────────
FROM debian:bookworm-slim AS builder

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      build-essential git clang libsdl2-dev zlib1g-dev \
      libogg-dev libvorbis-dev libopenal-dev libenet-dev \
      curl ca-certificates && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /build

# Clone the official AssaultCube repo
RUN git clone --depth=1 https://github.com/assaultcube/AC.git .

# Build the dedicated server binary
WORKDIR /build/source/src
RUN make clean && make server

# ── STAGE 2: RUNTIME IMAGE ─────────────────────────────────────────────────
FROM debian:bookworm-slim

# Install runtime libraries only
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      libsdl2-2.0-0 zlib1g libogg0 libvorbis0a libopenal1 libenet7 && \
    rm -rf /var/lib/apt/lists/*

# Copy built server binary and default config
COPY --from=builder /build/source/bin_unix /ac/bin_unix
COPY --from=builder /build/source/config /ac/config
COPY entrypoint.sh /ac/entrypoint.sh

WORKDIR /ac
RUN chmod +x entrypoint.sh

# Expose default UDP port
EXPOSE 28763/udp

# Entry point uses our wrapper
ENTRYPOINT ["/ac/entrypoint.sh"]
