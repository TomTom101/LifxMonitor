var FlicChannel, FlicClient, FlicScanner, LifxClient, ambients, app, btnListener, button, client, delay, express, fadeOff, fliclib, getPower, http, isPowered, lightOnline, listenToButton, lm, log, moment, nClicks, setColor, setDaymode, setNextColor, setNightmode, states, timeCheck, turnPower;

LifxClient = require('node-lifx').Client;

lm = require('./lightmonitor');

moment = require('moment');

client = new LifxClient();

express = require('express');

app = express();

http = require('http').Server(app);

fliclib = require("./fliclibNodeJs");

btnListener = require("./ButtonListener");

FlicClient = fliclib.FlicClient;

FlicChannel = fliclib.FlicConnectionChannel;

FlicScanner = fliclib.FlicScanner;

button = new FlicClient("localhost", 5551);

delay = function(sec, func) {
  return setInterval(func, sec * 1000);
};

states = {
  time: null,
  light: null,
  ambient: 0
};

ambients = [[0, 0, 100, 6500], [0, 0, 30, 2500]];

nClicks = function(count) {
  return console.log("Main got a " + count + " clicks reported");
};

btnListener.callbacks = {
  nClicks: nClicks
};

listenToButton = function(bdAddr) {
  var cc;
  cc = new FlicChannel(bdAddr);
  button.addConnectionChannel(cc);
  cc.on("buttonUpOrDown", btnListener.listen.bind(btnListener));
  return cc.on("connectionStatusChanged", function(connectionStatus, disconnectReason) {
    var ref;
    return console.log(bdAddr + " " + connectionStatus + ((ref = connectionStatus === "Disconnected") != null ? ref : " " + {
      disconnectReason: ""
    }));
  });
};

lightOnline = function() {
  states.light = true;
  timeCheck();
  if (states.time === "night") {
    return fadeOff();
  }
};

log = function(s) {
  var string, t;
  t = moment().format();
  string = t + " " + s;
  return console.log(string);
};

fadeOff = function() {
  var bedroom;
  bedroom = client.light("d073d512170d");
  if (bedroom) {
    return bedroom.getPower(function(error, power) {
      if (error) {
        return console.error(error);
      } else if (power) {
        log("fadeOff");
        return bedroom.off(2 * 60 * 1000);
      }
    });
  }
};

turnPower = function(state) {
  var bedroom;
  bedroom = client.light("d073d512170d");
  if (bedroom) {
    return bedroom[state](0, function(error, power) {
      return console.log("turned " + state);
    });
  }
};

isPowered = function(cb) {
  var bedroom;
  bedroom = client.light("d073d512170d");
  return bedroom.getPower(function(error, power) {
    if (error) {
      console.error(error);
    }
    return power === 1;
  });
};

getPower = function(cb) {
  var bedroom;
  bedroom = client.light("d073d512170d");
  if (bedroom) {
    return bedroom.getPower(function(error, power) {
      if (error) {
        console.error(error);
      }
      return cb(power);
    });
  }
};

setColor = function(index) {
  var bedroom;
  bedroom = client.light("d073d512170d");
  if (bedroom) {
    console.log("set to ambient " + index + " " + ambients[index]);
    bedroom["color"].apply(bedroom, ambients[index]);
    return states.ambient = index;
  }
};

setNextColor = function() {
  var next;
  next = states.ambient + 1;
  if (next === ambients.length) {
    next = 0;
  }
  return setColor(next);
};

setNightmode = function() {
  var bedroom;
  log("setNightmode");
  bedroom = client.light("d073d512170d");
  if (bedroom) {
    return bedroom.color(0, 0, 30, 2500, 0, function(error) {
      if (error == null) {
        log(" success!");
        return states.time = "night";
      } else {
        return log("failed with " + error + ".");
      }
    });
  } else {
    return log(" failed.");
  }
};

setDaymode = function() {
  var bedroom;
  log("setDaymode");
  if (isPowered()) {
    states.time = "day";
    return false;
  }
  bedroom = client.light("d073d512170d");
  if (bedroom) {
    bedroom.color(0, 0, 100, 6500);
    return states.time = "day";
  }
};

timeCheck = function() {
  switch (states.time) {
    case 'day':
      if (lm.isLate() && states.light) {
        return setNightmode();
      }
      break;
    case 'night':
      if (!lm.isLate() && states.light) {
        return setDaymode();
      }
      break;
    default:
      return states.time = lm.isLate() ? "night" : "day";
  }
};

delay(60, function() {
  return timeCheck();
});

client.on('light-new', function(light) {
  log("New " + light.id);
  return lightOnline();
});

client.on('light-offline', function(light) {
  log("Lost " + light.id);
  return states.light = false;
});

client.on('light-online', function(light) {
  log("Back " + light.id);
  return lightOnline();
});

button.once("ready", function() {
  console.log("Connected to daemon!");
  return button.getInfo(function(info) {
    return info.bdAddrOfVerifiedButtons.forEach(function(bdAddr) {
      return listenToButton(bdAddr);
    });
  });
});

button.on("bluetoothControllerStateChange", function(state) {
  return console.log("Bluetooth controller state change: " + state);
});

button.on("newVerifiedButton", function(bdAddr) {
  console.log("A new button was added: " + bdAddr);
  return listenToButton(bdAddr);
});

button.on("error", function(error) {
  return console.log("Daemon connection error: " + error);
});

button.on("close", function(hadError) {
  return console.log("Connection to daemon is now closed");
});

client.init();

log("Started");

app.get('/esp/:action', function(req, res) {
  switch (req.params.action) {
    case "1":
      getPower(function(power) {
        var state;
        state = power > 0 ? "off" : "on";
        return turnPower(state);
      });
      break;
    case "2":
      turnPower("on");
      fadeOff();
      break;
    case "3":
      setNextColor();
      break;
    default:
      console.log("unknown action " + req.params.action);
  }
  return res.send("Hello ESP, got " + req.params.action);
});

http.listen(3002, function() {
  return console.log('listening on *:3002');
});


/*

tag aus
tag ein
abends ein
abends auto-aus
abends aus
morgens auto-ein
morgens auto-aus
morgens aus
 */
