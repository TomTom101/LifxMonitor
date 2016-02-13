LifxClient  = require('node-lifx').Client
lm          = require('./lightmonitor')
moment      = require('moment')
client      = new LifxClient()

delay = (sec, func) -> setInterval func, sec * 1000

states =
    time: null
    light: null


lightOnline = ->
    states.light = on
    timeCheck()
    if states.time is "night"
        fadeOff()

log = (s) ->
    t = moment().toISOString()
    string = "#{t} #{s}"
    console.log string

fadeOff = ->
    bedroom = client.light "d073d512170d"
    if bedroom
      # Fadeoff only when turned on, posibly lost connection and that happens in the middle of the night
      bedroom.getPower (err, power) ->
        if error
          console.error error
        else if power
          log "fadeOff"
          bedroom.off 2 * 60 * 1000

setNightmode = ->
    log "setNightmode"
    bedroom = client.light "d073d512170d"
    if bedroom
        bedroom.color 0, 0, 30, 2500

setDaymode = ->
    log "setDaymode"
    bedroom = client.light "d073d512170d"
    if bedroom
        bedroom.color 0, 0, 100, 6500

timeCheck = ->
    switch states.time
        when 'day'
            if lm.isLate()
                states.time = "night"
                setNightmode()

        when 'night'
            if not lm.isLate()
                states.time = "day"
                setDaymode()
        else
            states.time = if lm.isLate() then "night" else "day"
            timeCheck()
    console.log "Time is #{states.time}"

delay 60, -> timeCheck()


client.on 'light-new', (light) ->
    log "New #{light.id}"
    ## Goes DIRECTLY to fadeoff after 22, no setNightmode
    lightOnline()

client.on 'light-offline', (light) ->
    log "Lost #{light.id}"
    states.light = off

client.on 'light-online', (light) ->
    log "Back #{light.id}"
    lightOnline()

client.init()

log "Started"

###

tag aus
tag ein
abends ein
abends auto-aus
abends aus
morgens auto-ein
morgens auto-aus
morgens aus

###
