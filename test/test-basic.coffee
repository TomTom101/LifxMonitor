global.rootRequire = (name) ->
    return require(__dirname + '/' + name)

chai = require('chai')
spies = require('chai-spies')
chai.use spies
assert = chai.assert
expect = chai.expect

delay = (ms, func) -> setTimeout func, ms

btnListener = require("../src/ButtonListener")
#
# server = new Server
# subject = null

describe "Init", ->
  beforeEach ->
    btnListener.callbacks = {}

  it "should detect a single click", (done, fail) ->
    btnListener.callbacks =
      longPress: ->
        console.log 'cb longPress'
        assert.fail()
      nClicks: (count)->
        console.log "cb nClicks #{count}"
        expect count
          .to.equal 1
        done()
    btnListener.listen 'ButtonDown'
    delay 20, btnListener.listen.bind btnListener, 'ButtonUp'

  it "should detect a double click", (done) ->
    btnListener.callbacks =
      longPress: ->
        console.log 'cb longPress'
        assert.fail()
      nClicks: (count)->
        console.log "cb nClicks #{count}"
        expect count
          .to.equal 2
        done()

    btnListener.listen 'ButtonDown'
    delay 10, btnListener.listen.bind btnListener, 'ButtonUp'
    delay 20, btnListener.listen.bind btnListener, 'ButtonDown'
    delay 30, btnListener.listen.bind btnListener, 'ButtonUp'

  it "should detect a long press", (done) ->
    btnListener.callbacks =
      longPress: ->
        console.log 'cb longPress'
        done()
      nClicks: (count)->
        console.log "cb nClicks #{count}"
        assert.fail()

    btnListener.listen 'ButtonDown'
    delay 800, btnListener.listen.bind btnListener, 'ButtonUp'
