#!/bin/bash

JAVA_VERSION=$(sed -ne 's/java.version=\(.*\)/\1/p' project/build.properties 2>/dev/null || echo "1.7")
JAVA_HOME=$(find /usr/lib/jvm -name "java-*-${JAVA_VERSION:-1.7}*" | sort | tail -n 1)

export JAVA_HOME

/usr/bin/sbt -java-home "$JAVA_HOME" "$@"
