#!/bin/sh -

### BEGIN INIT INFO
# Provides:             LifxMonitor
# Required-Start:
# Required-Stop:
# Default-Start:        2 3 4 5
# Default-Stop:         0 1 6
# Short-Description:    Monitor LIFX activity and do stuff
### END INIT INFO

export NODE_PATH=$NODE_PATH:/usr/local/bin
export HOME=/root
NODESCRIPT=/home/pi/LifxMonitor/

case "$1" in
  start)
    sudo -u pi forever start -p /home/pi/.forever --sourceDir=$NODESCRIPT index.js
    ;;
  stop)
    sudo -u pi forever stop -p /home/pi/.forever ${NODESCRIPT}index.js
    ;;
  *)

  echo "Usage: /etc/init.d/LifxMonitor {start|stop}"
  exit 1
  ;;
esac
exit 0
