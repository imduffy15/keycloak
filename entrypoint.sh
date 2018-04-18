#!/bin/bash

/opt/jboss/docker-entrypoint.sh $@ > /proc/1/fd/1 2>/proc/1/fd/2 & KEYCLOAK_PID=$!

/opt/jboss/keycloak/bin/configure.sh /proc/1/fd/1 2>/proc/1/fd/2 & CONFIGURE_PID=$!

_term() { 
  echo "Caught SIGTERM signal!" 
  kill -TERM "$KEYCLOAK_PID" 2>/dev/null
  kill -TERM "$CONFIGURE_ID" 2>/dev/null
}

trap _term SIGTERM

wait $KEYCLOAK_PID
exit $?

