#!/bin/sh -

### BEGIN INIT INFO
# Provides:             flix
# Required-Start:       $all
# Required-Stop:        $all
# Default-Start:        2 3 4 5
# Default-Stop:         0 1 6
# Short-Description:    Run flix daemon
### END INIT INFO

DIR=/home/pi/flix
DAEMON=${DIR}/sdk/bin/armv6l/flicd
DAEMON_OPTS="-d -f ${DIR}/db/flic.sqlite3"
DAEMON_NAME=flix

# This next line determines what user the script runs as.
DAEMON_USER=root

# The process ID of the script when it runs is stored here:
PIDFILE=/var/run/$DAEMON_NAME.pid

. /lib/lsb/init-functions

do_start () {
    log_daemon_msg "Starting system $DAEMON_NAME daemon"
    start-stop-daemon --start --background --pidfile $PIDFILE --make-pidfile --user $DAEMON_USER --chuid $DAEMON_USER --startas $DAEMON -- $DAEMON_OPTS
    log_end_msg $?
}
do_stop () {
    log_daemon_msg "Stopping system $DAEMON_NAME daemon"
    start-stop-daemon --stop --pidfile $PIDFILE --retry 10
    log_end_msg $?
}

case "$1" in
  start|stop)
      do_${1}
      ;;

  restart|reload|force-reload)
      do_stop
      do_start
      ;;

  status)
      status_of_proc "$DAEMON_NAME" "$DAEMON" && exit 0 || exit $?
      ;;

  *)

  echo "Usage: /etc/init.d/flix {start|stop}"
  exit 1
  ;;
esac
exit 0
