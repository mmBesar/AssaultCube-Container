#!/usr/bin/env sh
# entrypoint.sh — map ENV variables to ac_server CLI switches

ARGS=""

[ -n "$SERVER_NAME" ]   && ARGS="$ARGS -n '$SERVER_NAME'"
[ -n "$MAX_CLIENTS" ]   && ARGS="$ARGS -c $MAX_CLIENTS"
[ -n "$MAP_ROTATION" ]  && ARGS="$ARGS -r $MAP_ROTATION"
[ -n "$MASTER_SERVER" ] && ARGS="$ARGS -m $MASTER_SERVER"
[ -n "$AUTH_KEY" ]      && ARGS="$ARGS -Y $AUTH_KEY"
[ -n "$EXTRA_OPTS" ]    && ARGS="$ARGS $EXTRA_OPTS"

# Include custom servercmdline if mounted
[ -f config/servercmdline.txt ] && ARGS="$ARGS -C config/servercmdline.txt"

# Launch AssaultCube via its provided script
exec ./server.sh $ARGS
