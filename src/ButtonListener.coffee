# clickTypes = singleClick, doubleClick, longPress
delay = (sec, func) ->
  #console.log "delayed #{func} for #{sec}"
  setTimeout func, sec

ButtonListener =
  callbacks: {}
  longPressTimer: 0
  nClicksTimer: 0
  clickCounter: 0
  acceptTrigger: on

  listen: (clickType, wasQueued, timeDiff) ->
    console.log "listen #{clickType} #{timeDiff}"
    @[clickType]()

  resetTimeout: (timer) ->
    if typeof timer is 'object'
      clearTimeout timer

  ButtonDown: () ->
    console.log "ButtonDown #{@clickCounter}"
    if @clickCounter is 0
      @longPressTimer = delay 300, @trigger.bind @, 'longPress'

    @clickCounter++

  ButtonUp: () ->
    @resetTimeout @longPressTimer
    @resetTimeout @nClicksTimer
    if @clickCounter > 0
      fn = @trigger.bind @, 'nClicks', @clickCounter
      @nClicksTimer = delay 500, fn

  trigger: (detectedType, count) ->
    console.log "Trigger #{detectedType}, #{count}"
    @clickCounter = 0
    @callbacks[detectedType]?(count)

module.exports = ButtonListener
