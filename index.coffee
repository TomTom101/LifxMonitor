LifxClient  = require('node-lifx').Client
lm          = require('./lightmonitor')
client      = new LifxClient()

delay = (sec, func) -> setInterval func, sec * 1000

states =
    time: null
    light: null


client.on 'light-new', (light) ->
    console.log "New #{light.id}"
    lightOnline()

client.on 'light-offline', (light) ->
    console.log "Lost #{light.id}"
    states.light = off

client.on 'light-online', (light) ->
    console.log "Back #{light.id}"
    lightOnline()

lightOnline = ->
    states.light = on
    timeCheck()
    # Do only when turned on, posibly lost connection and that happens in the middle of the night
    if states.time is "night"
        fadeOff()


fadeOff = ->
    bedroom = client.light "d073d512170d"
    if bedroom
        console.log "fadeOff"
        bedroom.off 2 * 60 * 1000

setNightmode = ->
    console.log "setNightmode"
    bedroom = client.light "d073d512170d"
    if bedroom
        bedroom.color 0, 0, 30, 2500

setDaymode = ->
    console.log "setDaymode"
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

delay 60, -> timeCheck()


client.init()

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
