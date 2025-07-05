#!/usr/bin/env sh
# entrypoint.sh — turn ENV into ac_server switches

ARGS=""

# Server description ("-n"): shown in master‑server list :contentReference[oaicite:2]{index=2}
[ -n "$SERVER_NAME" ] && ARGS="$ARGS -n \"$SERVER_NAME\""

# Max clients ("-c"): how many players to allow :contentReference[oaicite:3]{index=3}
[ -n "$MAX_CLIENTS" ] && ARGS="$ARGS -c $MAX_CLIENTS"

# Map‑rotation file ("-r"): path relative to cwd
[ -n "$MAP_ROTATION" ] && ARGS="$ARGS -r \"$MAP_ROTATION\""

# Masterserver override ("-m"): e.g. "-mlocalhost" for LAN‑only
[ -n "$MASTER_SERVER" ] && ARGS="$ARGS -m \"$MASTER_SERVER\""

# Auth key ("-Y"): 64‑hex chars to register publicly
[ -n "$AUTH_KEY" ] && ARGS="$ARGS -Y $AUTH_KEY"

# Any extra switches
[ -n "$EXTRA_OPTS" ] && ARGS="$ARGS $EXTRA_OPTS"

# exec the real server binary
exec ./native_server $ARGS
