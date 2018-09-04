#!/bin/sh
### BEGIN INIT INFO
# Provides: mtproto-proxy
# Required-Start:       $remote_fs $syslog
# Required-Stop:        $remote_fs $syslog
# Default-Start:        2 3 4 5
# Default-Stop:
# Short-Description:    MTProxy service
### END INIT INFO

set -e

# Must be a valid filename
NAME=mtproto-proxy
PIDFILE=/var/run/$NAME.pid
#This is the command to be run, give the full pathname
DAEMON=/usr/bin/mtproto-proxy
DIR=/opt/MTProxy
DAEMON_OPTS=$(cat ${DIR}/options.txt)
USER=root

export PATH="${PATH:+$PATH:}/usr/sbin:/sbin"

case "$1" in
  start)
        echo -n "Starting daemon: "$NAME
        start-stop-daemon --start --background --pidfile $PIDFILE -d $DIR -m --exec $DAEMON -- $DAEMON_OPTS
        echo "."
        ;;
  stop)
        echo -n "Stopping daemon: "$NAME
        start-stop-daemon --stop --signal TERM --quiet --oknodo --pidfile $PIDFILE
        echo "."
        sleep 3
        ;;
  restart)
        echo -n "Restarting daemon: "$NAME
        start-stop-daemon --stop --signal TERM --quiet --oknodo --retry 30 --pidfile $PIDFILE
        start-stop-daemon --start --background --pidfile $PIDFILE -d $DIR -m --exec $DAEMON -- $DAEMON_OPTS
        echo "."
        ;;

  *)
        echo "Usage: "$1" {start|stop|restart}"
        exit 1
esac

exit 0

