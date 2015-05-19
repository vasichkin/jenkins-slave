# Is the location of the SBT launcher JAR file.
LAUNCHJAR="/usr/bin/sbt-launch.jar"

# Customization: this may define JAVA_OPTS.
SBTCONF=$HOME/.sbtconfig
if [ -f "$SBTCONF" ]; then
    . $SBTCONF
fi
if [ -z "$JAVA_OPTS" ]; then
    # Ensure enough heap space is created for sbt.  These settings are
    # the default settings from Typesafe's sbt wrapper.
    JAVA_OPTS="-XX:+CMSClassUnloadingEnabled -Xms1536m -Xmx4096m -XX:MaxPermSize=384m -XX:ReservedCodeCacheSize=192m -Dfile.encoding=UTF8"
fi

# Assume java is already in the shell path.
exec java $JAVA_OPTS -jar "$LAUNCHJAR" "$@"
