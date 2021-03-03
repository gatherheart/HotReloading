#!/bin/bash
#
# Start up daemon process to rebuild changed sources
#
# $Id: //depot/HotReloading/start_daemon.sh#8 $
#

cd "$(dirname $0)"

if [ -f "/tmp/injecting_storyboard.txt" ]; then
    rm /tmp/injecting_storyboard.txt
    exit 0
fi

DERIVED_LOGS="$(dirname $(dirname $SYMROOT))/Logs/Build"

LAST_LOG=`ls -t $DERIVED_LOGS/*.xcactivitylog | head -n 1`

# kill any existing daemon process
kill -9 `ps auxww | grep debug/injectiond | grep -v grep | awk '{ print $2 }'`

# rebuild daemon
env -i PATH="/usr/bin:/bin:/usr/sbin:/sbin" swift build &&

rm -f .build/debug/Contents && ln -s "$PWD/Contents" .build/debug &&

# run in background passing project file
# passing a list of additinal directories to watch
(.build/debug/injectiond "$PROJECT_FILE_PATH" "$DERIVED_LOGS" `gunzip <$LAST_LOG | tr '\r' '\n' | grep -e '  cd ' | sort -u | grep -v DerivedData | awk '{ print $2 }'` >/tmp/hot_reloading.log 2>&1 &)