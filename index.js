var LifxClient, client, delay, fadeOff, isPowered, lightOnline, lm, log, moment, setDaymode, setNightmode, states, timeCheck;

LifxClient = require('node-lifx').Client;

lm = require('./lightmonitor');

moment = require('moment');

client = new LifxClient();

delay = function(sec, func) {
  return setInterval(func, sec * 1000);
};

states = {
  time: null,
  light: null
};

lightOnline = function() {
  var bedroom;
  states.light = true;
  timeCheck();
  bedroom = client.light("d073d512170d");
  if (bedroom) {
    bedroom.getWifiInfo(function(error, data) {
      if (error) {
        return console.error(error);
      } else {
        return console.log(data.signal);
      }
    });
  }
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

isPowered = function() {
  var bedroom;
  bedroom = client.light("d073d512170d");
  return bedroom != null ? bedroom.getPower(function(error, power) {
    if (error) {
      console.error(error);
    }
    return power === 1;
  }) : void 0;
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
      if (lm.isLate()) {
        return setNightmode();
      }
      break;
    case 'night':
      if (!lm.isLate()) {
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

client.init();

log("Started");


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
