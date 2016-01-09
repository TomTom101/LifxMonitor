moment = require('moment')

Number::mapFloat = (in_min, in_max, out_min, out_max) ->
    return out_min if this < in_min
    return out_max if this > in_max

    parseFloat((this - in_min) * (out_max - out_min) / (in_max - in_min) + out_min)


LightMonitor =
    isLate: ->
        moment().hours() >= 22 || moment().hours() <= 8

    getBrightness: ->
        moment.duration
            hours: moment().hours()
            minutes: moment().minutes()
        .asHours()
        #angle.mapFloat


    getBrightnessForRange: (hours, start, end) ->
        angle = hours.mapFloat start, end, 0, 180
        #   a = angle+90
        f = Math.abs Math.cos angle * (Math.PI/180)
        +f.toFixed 2

module.exports = LightMonitor
