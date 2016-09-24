$ pm2 start src/index.js
$ pm2 save

On restart, hci0 might be DOWN, restart w/

$ sudo hciconfig hci0 up
$ sudo systemctl restart flix
