var assert, btnListener, chai, delay, expect, spies;

global.rootRequire = function(name) {
  return require(__dirname + '/' + name);
};

chai = require('chai');

spies = require('chai-spies');

chai.use(spies);

assert = chai.assert;

expect = chai.expect;

delay = function(ms, func) {
  return setTimeout(func, ms);
};

btnListener = require("../src/ButtonListener");

describe("Init", function() {
  beforeEach(function() {
    return btnListener.callbacks = {};
  });
  it("should detect a single click", function(done, fail) {
    btnListener.callbacks = {
      longPress: function() {
        console.log('cb longPress');
        return assert.fail();
      },
      nClicks: function(count) {
        console.log("cb nClicks " + count);
        expect(count).to.equal(1);
        return done();
      }
    };
    btnListener.listen('ButtonDown');
    return delay(20, btnListener.listen.bind(btnListener, 'ButtonUp'));
  });
  it("should detect a double click", function(done) {
    btnListener.callbacks = {
      longPress: function() {
        console.log('cb longPress');
        return assert.fail();
      },
      nClicks: function(count) {
        console.log("cb nClicks " + count);
        expect(count).to.equal(2);
        return done();
      }
    };
    btnListener.listen('ButtonDown');
    delay(50, btnListener.listen.bind(btnListener, 'ButtonUp'));
    delay(100, btnListener.listen.bind(btnListener, 'ButtonDown'));
    return delay(150, btnListener.listen.bind(btnListener, 'ButtonUp'));
  });
  it("should detect a triple click", function(done) {
    btnListener.callbacks = {
      longPress: function() {
        console.log('cb longPress');
        return assert.fail();
      },
      nClicks: function(count) {
        console.log("cb nClicks " + count);
        expect(count).to.equal(3);
        return done();
      }
    };
    btnListener.listen('ButtonDown');
    delay(10, btnListener.listen.bind(btnListener, 'ButtonUp'));
    delay(20, btnListener.listen.bind(btnListener, 'ButtonDown'));
    delay(30, btnListener.listen.bind(btnListener, 'ButtonUp'));
    delay(40, btnListener.listen.bind(btnListener, 'ButtonDown'));
    return delay(50, btnListener.listen.bind(btnListener, 'ButtonUp'));
  });
  return it("should detect a long press", function(done) {
    btnListener.callbacks = {
      longPress: function() {
        console.log('cb longPress');
        return done();
      },
      nClicks: function(count) {
        console.log("cb nClicks " + count);
        return assert.fail();
      }
    };
    btnListener.listen('ButtonDown');
    return delay(800, btnListener.listen.bind(btnListener, 'ButtonUp'));
  });
});
