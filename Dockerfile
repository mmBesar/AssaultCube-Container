# AssaultCube Server Dockerfile
# Multi-stage build for AssaultCube server
FROM ubuntu:22.04 AS builder

# Avoid interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    wget \
    zlib1g-dev \
    libcurl4-openssl-dev \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /build

# Clone AssaultCube source code
RUN git clone --depth 1 https://github.com/assaultcube/AC.git assaultcube

# Build the server binary
WORKDIR /build/assaultcube/source/src
RUN make server

# Runtime stage
FROM ubuntu:22.04

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    zlib1g \
    libcurl4 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user for security
RUN groupadd -r acserver && useradd -r -g acserver acserver

# Set working directory
WORKDIR /opt/assaultcube

# Copy built server binary from builder stage
COPY --from=builder /build/assaultcube/source/src/ac_server ./bin_unix/ac_server

# Copy game data and configuration files
COPY --from=builder /build/assaultcube/config ./config
COPY --from=builder /build/assaultcube/packages ./packages

# Create necessary directories
RUN mkdir -p logs demos screenshots \
    && chown -R acserver:acserver /opt/assaultcube

# Server configuration environment variables with defaults
ENV AC_SERVERNAME="AssaultCube Docker Server"
ENV AC_SERVERPORT="28763"
ENV AC_MAXCLIENTS="12"
ENV AC_MASTERSERVER="1"
ENV AC_SERVERPASSWORD=""
ENV AC_ADMINPASSWORD="admin"
ENV AC_MAPROT="config/maprot.cfg"
ENV AC_SERVERMOTD="Welcome to AssaultCube Server"
ENV AC_SERVERLOG="1"
ENV AC_GAMEMODE="0"
ENV AC_GAMETIME="10"
ENV AC_AUTOTEAM="1"
ENV AC_TEAMKILLPUNISH="1"
ENV AC_MAXPING="400"
ENV AC_CALLVOTE="1"
ENV AC_SHUFFLE="1"
ENV AC_SPECTATE="1"
ENV AC_INTERMISSION="10"
ENV AC_MAXROLL="5"
ENV AC_MAXPITCH="40"
ENV AC_CHEATS="0"
ENV AC_AUTOSENDMAP="1"
ENV AC_SERVERDESC="AssaultCube Server running in Docker"
ENV AC_SERVERURL=""
ENV AC_BANDISCONNECT="20"
ENV AC_BANTHRESHOLD="5"
ENV AC_BANTIME="20"
ENV AC_VOTETHRESHOLD="70"
ENV AC_VOTETIMEOUT="60"
ENV AC_DEMOS="1"
ENV AC_DEMOTIME="15"
ENV AC_VERBOSE="0"

# Create startup script
RUN cat > /opt/assaultcube/start_server.sh << 'EOF'
#!/bin/bash

# Generate server configuration based on environment variables
cat > /opt/assaultcube/config/servercmdline.txt << EOCFG
// AssaultCube server commandline configuration
// Generated from Docker environment variables

// Server name and description
-N "${AC_SERVERNAME}"
-D "${AC_SERVERDESC}"

// Network settings
-f ${AC_SERVERPORT}
-c ${AC_MAXCLIENTS}
-P ${AC_MAXPING}

// Game settings
-m ${AC_GAMEMODE}
-t ${AC_GAMETIME}
-r ${AC_MAPROT}
-i ${AC_INTERMISSION}

// Server behavior
$([ "$AC_MASTERSERVER" = "1" ] && echo "-M" || echo "// Master server registration disabled")
$([ "$AC_AUTOTEAM" = "1" ] && echo "-A" || echo "// Auto-team disabled")
$([ "$AC_TEAMKILLPUNISH" = "1" ] && echo "-K" || echo "// Team kill punishment disabled")
$([ "$AC_CALLVOTE" = "1" ] && echo "-V" || echo "// Call vote disabled")
$([ "$AC_SHUFFLE" = "1" ] && echo "-S" || echo "// Shuffle disabled")
$([ "$AC_SPECTATE" = "1" ] && echo "-E" || echo "// Spectate disabled")
$([ "$AC_CHEATS" = "1" ] && echo "-C" || echo "// Cheats disabled")
$([ "$AC_AUTOSENDMAP" = "1" ] && echo "-F" || echo "// Auto send map disabled")
$([ "$AC_DEMOS" = "1" ] && echo "-W" || echo "// Demos disabled")
$([ "$AC_SERVERLOG" = "1" ] && echo "-L" || echo "// Server logging disabled")
$([ "$AC_VERBOSE" = "1" ] && echo "-v" || echo "// Verbose logging disabled")

// Passwords
$([ -n "$AC_SERVERPASSWORD" ] && echo "-p \"$AC_SERVERPASSWORD\"" || echo "// No server password set")
$([ -n "$AC_ADMINPASSWORD" ] && echo "-a \"$AC_ADMINPASSWORD\"" || echo "// No admin password set")

// Additional settings
-R ${AC_MAXROLL}
-Q ${AC_MAXPITCH}
-B ${AC_BANDISCONNECT}
-G ${AC_BANTHRESHOLD}
-T ${AC_BANTIME}
-Y ${AC_VOTETHRESHOLD}
-I ${AC_VOTETIMEOUT}
-X ${AC_DEMOTIME}

// MOTD
-o "${AC_SERVERMOTD}"

// Server URL
$([ -n "$AC_SERVERURL" ] && echo "-u \"$AC_SERVERURL\"" || echo "// No server URL set")

EOCFG

echo "Starting AssaultCube server..."
echo "Server name: ${AC_SERVERNAME}"
echo "Server port: ${AC_SERVERPORT}"
echo "Max clients: ${AC_MAXCLIENTS}"
echo "Admin password: ${AC_ADMINPASSWORD}"
echo "Configuration written to config/servercmdline.txt"
echo ""

# Start the server
exec ./bin_unix/ac_server "$@"
EOF

RUN chmod +x /opt/assaultcube/start_server.sh

# Switch to non-root user
USER acserver

# Expose server ports
EXPOSE 28763/udp 28764/udp

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD netstat -un | grep :28763 || exit 1

# Start the server
CMD ["/opt/assaultcube/start_server.sh"]
