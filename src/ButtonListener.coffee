# clickTypes = singleClick, doubleClick, longPress
delay = (sec, func) ->
  #console.log "delayed #{func} for #{sec}"
  setTimeout func, sec

ButtonListener =
  callbacks: {}
  longPressTimer: 0
  nClicksTimer: 0
  clickCounter: 0

  init: ->
    console.log "Alive"

  listen: (clickType, wasQueued, timeDiff) ->
    #console.log "listen #{clickType} #{timeDiff}"
    @[clickType]()

  resetTimeout: (timer) ->
    if typeof timer is 'object'
      clearTimeout timer

  ButtonDown: () ->
    console.log "ButtonDown #{@clickCounter}"
    if @clickCounter is 0
      @longPressTimer = delay 500, @trigger.bind @, 'longPress'

    @clickCounter++

  ButtonUp: () ->
    console.log "ButtonUp #{typeof @longPressTimer}"
    @resetTimeout @longPressTimer
    fn =  @trigger.bind @, 'nClicks', @clickCounter
    @resetTimeout @nClicksTimer    
    @nClicksTimer = delay 100, fn
    #@doubleClickTimer = delay 200, @trigger 'longPress'
    #@trigger 'singleClick'

    #detectedType = 'singleClick'

  trigger: (detectedType, count) ->
      console.log "Trigger #{detectedType}, #{count}"
      @clickCounter = 0
      @callbacks[detectedType]?(count)

module.exports = ButtonListener
