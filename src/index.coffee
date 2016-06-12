LifxClient  = require('node-lifx').Client
lm          = require('./lightmonitor')
moment      = require('moment')
client      = new LifxClient()
express     = require 'express'
app         = express()
http        = require('http').Server(app)
fliclib     = require("./fliclibNodeJs")
btnListener = require("./ButtonListener")
FlicClient  = fliclib.FlicClient
FlicChannel = fliclib.FlicConnectionChannel
FlicScanner = fliclib.FlicScanner

button = new FlicClient("localhost", 5551)
delay = (sec, func) -> setInterval func, sec * 1000

states =
    time: null
    light: null
    ambient: 0

ambients = [
  [0, 0, 100, 6500]
  [0, 0, 30, 2500]
]

longPress = () ->
  console.log "Main got longPress reported"
nClicks = (count) ->
  console.log "Main got #{count} clicks reported"

btnListener.callbacks =
  nClicks: nClicks
  longPress: longPress


listenToButton = (bdAddr) ->
	cc = new FlicChannel(bdAddr)
	button.addConnectionChannel(cc)
	cc.on "buttonUpOrDown", btnListener.listen.bind btnListener
	cc.on "connectionStatusChanged", (connectionStatus, disconnectReason) ->
		console.log(bdAddr + " " + connectionStatus + (connectionStatus == "Disconnected" ? " " + disconnectReason : ""))

lightOnline = ->
    states.light = on
    timeCheck()

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

turnPower = (state) ->
  bedroom = client.light "d073d512170d"
  if bedroom
    bedroom[state] 0, (error, power) ->
      console.log "turned #{state}"

isPowered = (cb) ->
    bedroom = client.light "d073d512170d"
    bedroom.getPower (error, power) ->
      if error
        console.error error
      power is 1

getPower = (cb) ->
    bedroom = client.light "d073d512170d"
    if bedroom
      bedroom.getPower (error, power) ->
        if error
          console.error error
        cb power

setColor = (index) ->
  bedroom = client.light "d073d512170d"
  if bedroom
    console.log "set to ambient #{index} #{ambients[index]}"
    bedroom["color"].apply bedroom, ambients[index]
    states.ambient = index

setNextColor = () ->
  next = states.ambient + 1
  next = 0 if next is ambients.length
  setColor next


setNightmode = ->
    log "setNightmode"
    bedroom = client.light "d073d512170d"
    if bedroom
      bedroom.color 0, 0, 30, 2500, 0, (error) ->
        if !error?
          log " success!"
          states.time = "night"
        else
          log "failed with #{error}."
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
            if lm.isLate() and states.light
                setNightmode()

        when 'night'
            if not lm.isLate() and states.light
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

button.once "ready", () ->
	console.log("Connected to daemon!")
	button.getInfo (info) ->
		info.bdAddrOfVerifiedButtons.forEach (bdAddr) ->
			listenToButton(bdAddr)

button.on "bluetoothControllerStateChange", (state) ->
	console.log("Bluetooth controller state change: " + state)

button.on "newVerifiedButton", (bdAddr) ->
	console.log("A new button was added: " + bdAddr)
	listenToButton(bdAddr)

button.on "error", (error) ->
	console.log("Daemon connection error: " + error)

button.on "close", (hadError) ->
	console.log("Connection to daemon is now closed")

client.init()

log "Started"

app
  .get '/esp/:action', (req, res) ->
    switch req.params.action
      when "1"
        getPower (power)->
          state = if power > 0 then "off" else "on"
          turnPower state
      when "2"
            turnPower "on"
            fadeOff()
      when "3"
        setNextColor()
      else
        console.log "unknown action #{req.params.action}"

    res.send "Hello ESP, got #{req.params.action}"

http.listen 3002, ->
  console.log 'listening on *:3002'




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
