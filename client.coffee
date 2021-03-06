LifxClient  = require('node-lifx').Client
client      = new LifxClient()
client.init()

client.on 'light-new', (light) ->
  console.log "New light"
  light.getState (err, info) ->
    console.log info


console.log client.lights()
bedroom = client.light "d073d512170d"
if bedroom
  console.log "Have bedroom light"
  # Fadeoff only when turned on, posibly lost connection and that happens in the middle of the night
  bedroom.getPower (error, power) ->
    console.log "Power is #{power}"
else
  console.log "Could not get bedroom"
