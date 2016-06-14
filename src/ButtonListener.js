var ButtonListener, delay;

delay = function(sec, func) {
  return setTimeout(func, sec);
};

ButtonListener = {
  callbacks: {},
  evaluateTimer: 0,
  clickCounter: 0,
  listen: function(clickType, wasQueued, timeDiff) {
    console.log("listen " + clickType + " " + timeDiff);
    return this[clickType]();
  },
  resetTimeout: function(timer) {
    if (typeof timer === 'object') {
      return clearTimeout(timer);
    }
  },
  ButtonDown: function() {
    console.log("ButtonDown " + this.clickCounter);
    this.resetTimeout(this.evaluateTimer);
    return this.evaluateTimer = delay(200, this.trigger.bind(this));
  },
  ButtonUp: function() {
    return this.clickCounter++;
  },
  trigger: function() {
    var base, detectedType;
    if (this.clickCounter === 0) {
      detectedType = 'longPress';
    } else {
      detectedType = 'nClicks';
    }
    console.log("Trigger " + detectedType + ", " + this.clickCounter);
    if (typeof (base = this.callbacks)[detectedType] === "function") {
      base[detectedType](this.clickCounter);
    }
    return this.clickCounter = 0;
  }
};

module.exports = ButtonListener;
