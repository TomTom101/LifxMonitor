// Generated by CoffeeScript 1.10.0
var LifxClient, client, delay, fadeOff, lightOnline, lm, setDaymode, setNightmode, states, timeCheck;

LifxClient = require('node-lifx').Client;

lm = require('./lightmonitor');

client = new LifxClient();

delay = function(sec, func) {
  return setInterval(func, sec * 1000);
};

states = {
  time: null,
  light: null
};

client.on('light-new', function(light) {
  console.log("New " + light.id);
  return lightOnline();
});

client.on('light-offline', function(light) {
  console.log("Lost " + light.id);
  return states.light = false;
});

client.on('light-online', function(light) {
  console.log("Back " + light.id);
  return lightOnline();
});

lightOnline = function() {
  states.light = true;
  timeCheck();
  if (states.time === "night") {
    return fadeOff();
  }
};

fadeOff = function() {
  var bedroom;
  bedroom = client.light("d073d512170d");
  if (bedroom) {
    console.log("fadeOff");
    return bedroom.off(2 * 60 * 1000);
  }
};

setNightmode = function() {
  var bedroom;
  console.log("setNightmode");
  bedroom = client.light("d073d512170d");
  if (bedroom) {
    return bedroom.color(0, 0, 30, 2500);
  }
};

setDaymode = function() {
  var bedroom;
  console.log("setDaymode");
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

client.init();


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
