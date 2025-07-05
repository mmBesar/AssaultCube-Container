# ── STAGE 1: build the AC server binary ─────────────────────────────────────
FROM debian:bookworm-slim AS builder

# install build tools and libraries (incl. SDL2, ENet, OpenAL, etc.)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      build-essential git clang libsdl2-dev zlib1g-dev \
      libogg-dev libvorbis-dev libopenal-dev libenet-dev curl ca-certificates && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /build

# grab the latest AssaultCube source
RUN git clone --depth=1 https://github.com/assaultcube/AC.git .

# enter the C‑side src folder and invoke the dedicated‑server build+install
WORKDIR /build/source/src
# ← this target builds libenet, compiles ac_server, then installs it to ../../bin_unix/$(PLATFORM_PREFIX)_server :contentReference[oaicite:1]{index=1}
RUN make server_install

# ── STAGE 2: package only the server into a minimal image ───────────────────
FROM debian:bookworm-slim

# runtime libs only
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      libsdl2-2.0-0 zlib1g libogg0 libvorbis0a libopenal1 libenet7 && \
    rm -rf /var/lib/apt/lists/*

# copy the built server folder into /ac
COPY --from=builder /build/source/bin_unix /ac

# drop in our entrypoint helper
WORKDIR /ac
COPY entrypoint.sh /ac/entrypoint.sh
RUN chmod +x entrypoint.sh

# default port (UDP)
EXPOSE 28763/udp

ENTRYPOINT ["./entrypoint.sh"]
