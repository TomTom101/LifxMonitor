LifxClient = require('node-lifx').Client
lm = require('./lightmonitor')
client = new LifxClient()


client.on 'light-new', (light) ->
    console.log "New #{light.id}"
    stateCheck "off-on"

client.on 'light-offline', (light) ->
    console.log "Lost #{light.id}"

client.on 'light-online', (light) ->
    console.log "Back #{light.id}"
    stateCheck "off-on"


delay = (sec, func) -> setInterval func, sec * 1000


stateCheck = (state) ->
    bedroom = client.light "d073d512170d"
    if lm.isLate()
        if bedroom
            bedroom.color 0, 0, 15, 2500, 1000, ->
                bedroom.off 10 * 60 * 1000
    else
        if bedroom
            bedroom.getPower (err, powered) ->
                if powered
                    bedroom.color 0, 0, 85, 6500


delay 60, -> stateCheck()


client.init()
