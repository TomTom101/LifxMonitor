var ButtonListener, delay;

delay = function(sec, func) {
  return setTimeout(func, sec);
};

ButtonListener = {
  callbacks: {},
  evaluateTimer: 0,
  clickCounter: 0,
  listening: false,
  timeout: 500,
  listen: function(clickType, wasQueued, timeDiff) {
    return this[clickType]();
  },
  resetTimeout: function(timer) {
    if (typeof timer === 'object') {
      return clearTimeout(timer);
    }
  },
  ButtonDown: function() {
    this.listening = true;
    this.resetTimeout(this.evaluateTimer);
    return this.evaluateTimer = delay(this.timeout, this.trigger.bind(this));
  },
  ButtonUp: function() {
    if (this.listening) {
      return this.clickCounter++;
    }
  },
  trigger: function() {
    var base, detectedType;
    if (!this.listening) {
      return;
    }
    if (this.clickCounter === 0) {
      detectedType = 'longPress';
    } else {
      detectedType = 'nClicks';
    }
    if (typeof (base = this.callbacks)[detectedType] === "function") {
      base[detectedType](this.clickCounter);
    }
    this.clickCounter = 0;
    return this.listening = false;
  }
};

module.exports = ButtonListener;
