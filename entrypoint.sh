#!/usr/bin/env sh
# entrypoint.sh — map ENV variables to ac_server CLI switches

ARGS=""

# Server name (description)
[ -n "$SERVER_NAME" ]   && ARGS="$ARGS -n '$SERVER_NAME'"
# Max clients
[ -n "$MAX_CLIENTS" ]   && ARGS="$ARGS -c $MAX_CLIENTS"
# Map rotation file
[ -n "$MAP_ROTATION" ]  && ARGS="$ARGS -r $MAP_ROTATION"
# Masterserver (e.g. 'localhost')
[ -n "$MASTER_SERVER" ] && ARGS="$ARGS -m $MASTER_SERVER"
# Auth key for public registration
[ -n "$AUTH_KEY" ]      && ARGS="$ARGS -Y $AUTH_KEY"
# Extra options
[ -n "$EXTRA_OPTS" ]    && ARGS="$ARGS $EXTRA_OPTS"

# If user mounted a custom servercmdline.txt, include it
if [ -f config/servercmdline.txt ]; then
  ARGS="$ARGS -C config/servercmdline.txt"
fi

exec ./server.sh $ARGS
