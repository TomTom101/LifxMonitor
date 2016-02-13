moment = require('moment')
suncalc = require 'suncalc'

Number::mapFloat = (in_min, in_max, out_min, out_max) ->
    return out_min if this < in_min
    return out_max if this > in_max

    parseFloat((this - in_min) * (out_max - out_min) / (in_max - in_min) + out_min)


LightMonitor =
    position:
      lat: 52.5158
      long: 13.4725

    isLate: ->
        times = suncalc.getTimes moment(), @position.lat, @position.long
        moment()
          .between times.sunset, times.sunriseEnd

    clockAngle: (h, m) ->
        m = moment()
            .hours(h)
            .minutes(m)

        .5 * (60 * m.format("h") + m.minutes())

    getBrightness: ->
        moment.duration
            hours: moment().hours()
            minutes: moment().minutes()
        .asHours()

    getCos: (angle) ->
        Math.abs Math.cos angle * (Math.PI/180)


    getBrightnessForRange: (hours, start, end) ->
        angle_start = @getCos @clockAngle start, 0
        angle_end = @getCos @clockAngle end, 0
        angle_now = @getCos @clockAngle hours, 0
        [angle_start, angle_now, angle_end]
#            .mapFloat 0, 359, angle_start, angle_end
        #   a = angle+90
        #+f.toFixed 2

module.exports = LightMonitor
