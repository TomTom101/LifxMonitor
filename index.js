var LifxClient, client, delay, fadeOff, lightOnline, lm, log, moment, setDaymode, setNightmode, states, timeCheck;

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
  states.light = true;
  timeCheck();
  if (states.time === "night") {
    return fadeOff();
  }
};

log = function(s) {
  var string, t;
  t = moment().toISOString();
  string = t + " " + s;
  return console.log(string);
};

fadeOff = function() {
  var bedroom;
  bedroom = client.light("d073d512170d");
  if (bedroom) {
    return bedroom.getPower(function(err, power) {
      if (error) {
        return console.error(error);
      } else if (power) {
        log("fadeOff");
        return bedroom.off(2 * 60 * 1000);
      }
    });
  }
};

setNightmode = function() {
  var bedroom;
  log("setNightmode");
  bedroom = client.light("d073d512170d");
  if (bedroom) {
    return bedroom.color(0, 0, 30, 2500);
  }
};

setDaymode = function() {
  var bedroom;
  log("setDaymode");
  bedroom = client.light("d073d512170d");
  if (bedroom) {
    return bedroom.color(0, 0, 100, 6500);
  }
};

timeCheck = function() {
  switch (states.time) {
    case 'day':
      if (lm.isLate()) {
        states.time = "night";
        return setNightmode();
      }
      break;
    case 'night':
      if (!lm.isLate()) {
        states.time = "day";
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
