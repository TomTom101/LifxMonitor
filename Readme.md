$ chown pi:pi lifxmonitor.sh && chmod +x lifxmonitor.sh
$ sudo cp lifxmonitor.sh /etc/init.d/
$ sudo update-rc.d lifxmonitor.sh defaults
$ /etc/init.d/lifxmonitor.sh start
