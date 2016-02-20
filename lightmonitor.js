var LightMonitor, moment, suncalc;

moment = require('moment');

suncalc = require('suncalc');

Number.prototype.mapFloat = function(in_min, in_max, out_min, out_max) {
  if (this < in_min) {
    return out_min;
  }
  if (this > in_max) {
    return out_max;
  }
  return parseFloat((this - in_min) * (out_max - out_min) / (in_max - in_min) + out_min);
};

LightMonitor = {
  position: {
    lat: 52.5158,
    long: 13.4725
  },
  isLate: function() {
    return !this.isDay();
  },
  isDay: function() {
    var times;
    times = suncalc.getTimes(moment(), this.position.lat, this.position.long);
    return moment().isBetween(times.sunriseEnd, times.nauticalDusk);
  },
  clockAngle: function(h, m) {
    m = moment().hours(h).minutes(m);
    return .5 * (60 * m.format("h") + m.minutes());
  },
  getBrightness: function() {
    return moment.duration({
      hours: moment().hours(),
      minutes: moment().minutes()
    }).asHours();
  },
  getCos: function(angle) {
    return Math.abs(Math.cos(angle * (Math.PI / 180)));
  },
  getBrightnessForRange: function(hours, start, end) {
    var angle_end, angle_now, angle_start;
    angle_start = this.getCos(this.clockAngle(start, 0));
    angle_end = this.getCos(this.clockAngle(end, 0));
    angle_now = this.getCos(this.clockAngle(hours, 0));
    return [angle_start, angle_now, angle_end];
  }
};

module.exports = LightMonitor;
