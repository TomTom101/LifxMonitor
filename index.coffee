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
    bedroom = client.light "d073d512170d"
    if bedroom
      bedroom.getWifiInfo (error, data) ->
        if error
          console.error error
        else
          console.log data.signal
    if states.time is "night"
        fadeOff()

log = (s) ->
    t = moment().format()
    string = "#{t} #{s}"
    console.log string

fadeOff = ->
    bedroom = client.light "d073d512170d"
    if bedroom
      # Fadeoff only when turned on, posibly lost connection and that happens in the middle of the night
      bedroom.getPower (error, power) ->
        if error
          console.error error
        else if power
          log "fadeOff"
          bedroom.off 2 * 60 * 1000

isPowered = ->
    bedroom = client.light "d073d512170d"
      # Fadeoff only when turned on, posibly lost connection and that happens in the middle of the night
    bedroom?.getPower (error, power) ->
      if error
        console.error error

      power is 1

setNightmode = ->
    log "setNightmode"
    bedroom = client.light "d073d512170d"
    if bedroom
      bedroom.color 0, 0, 30, 2500, 0, (error) ->
        if !error?
          log " success!"
          states.time = "night"
    else
      log " failed."

setDaymode = ->
  log "setDaymode"
  if isPowered()
    states.time = "day"
    return false
  bedroom = client.light "d073d512170d"
  if bedroom
      bedroom.color 0, 0, 100, 6500
      states.time = "day"

timeCheck = ->
    switch states.time
        when 'day'
            if lm.isLate()
                setNightmode()

        when 'night'
            if not lm.isLate()
                setDaymode()
        else
            states.time = if lm.isLate() then "night" else "day"

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
