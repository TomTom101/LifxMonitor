LifxClient  = require('node-lifx').Client
lifx      = new LifxClient()
fliclib = require("./fliclibNodeJs")
FlicClient = fliclib.FlicClient
FlicConnectionChannel = fliclib.FlicConnectionChannel
FlicScanner = fliclib.FlicScanner

client = new FlicClient("localhost", 5551)

lifx.init()

lifx.on 'light-new', (light) ->
  console.log "New light"
  light.getState (err, info) ->
    console.log info

togglePower = (state) ->
  bedroom = lifx.light "d073d512170d"
  if bedroom
    bedroom[state] 0, (error, power) ->
      if error
          console.error error
      console.log "turned #{state}"

buttonStateChange = (clickType, wasQueued, timeDiff) ->
  switch clickType
    when "buttonDown" then togglePower "on"
  console.log "#{bdAddr}  #{clickType}"  + (wasQueued ? "wasQueued" : "notQueued") + " #{timeDiff} seconds ago"

listenToButton = (bdAddr) ->
	cc = new FlicConnectionChannel(bdAddr)
	client.addConnectionChannel(cc)
	cc.on "buttonUpOrDown", buttonStateChange
	cc.on "connectionStatusChanged", (connectionStatus, disconnectReason) ->
		console.log(bdAddr + " " + connectionStatus + (connectionStatus == "Disconnected" ? " " + disconnectReason : ""))

client.once "ready", () ->
	console.log("Connected to daemon!")
	client.getInfo (info) ->
		info.bdAddrOfVerifiedButtons.forEach (bdAddr) ->
			listenToButton(bdAddr)

client.on "bluetoothControllerStateChange", (state) ->
	console.log("Bluetooth controller state change: " + state)

client.on "newVerifiedButton", (bdAddr) ->
	console.log("A new button was added: " + bdAddr)
	listenToButton(bdAddr)

client.on "error", (error) ->
	console.log("Daemon connection error: " + error)

client.on "close", (hadError) ->
	console.log("Connection to daemon is now closed")
