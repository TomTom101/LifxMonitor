# clickTypes = singleClick, doubleClick, longPress
delay = (sec, func) ->
  #console.log "delayed #{func} for #{sec}"
  setTimeout func, sec

ButtonListener =
  callbacks: {}
  evaluateTimer: 0
  clickCounter: 0

  listen: (clickType, wasQueued, timeDiff) ->
    console.log "listen #{clickType} #{timeDiff}"
    @[clickType]()

  resetTimeout: (timer) ->
    if typeof timer is 'object'
      clearTimeout timer

  ButtonDown: () ->
    console.log "ButtonDown #{@clickCounter}"
    @resetTimeout @evaluateTimer
    @evaluateTimer = delay 200, @trigger.bind @


  ButtonUp: () ->
    @clickCounter++

  trigger: () ->
    if @clickCounter is 0
      detectedType = 'longPress'
    else
      detectedType = 'nClicks'

    console.log "Trigger #{detectedType}, #{@clickCounter}"
    @callbacks[detectedType]?(@clickCounter)
    @clickCounter = 0

module.exports = ButtonListener
