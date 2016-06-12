var ButtonListener, delay;

delay = function(sec, func) {
  return setTimeout(func, sec);
};

ButtonListener = {
  callbacks: {},
  longPressTimer: 0,
  nClicksTimer: 0,
  clickCounter: 0,
  acceptTrigger: true,
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
    if (this.clickCounter === 0) {
      this.longPressTimer = delay(300, this.trigger.bind(this, 'longPress'));
    }
    return this.clickCounter++;
  },
  ButtonUp: function() {
    var fn;
    this.resetTimeout(this.longPressTimer);
    this.resetTimeout(this.nClicksTimer);
    if (this.clickCounter > 0) {
      fn = this.trigger.bind(this, 'nClicks', this.clickCounter);
      return this.nClicksTimer = delay(500, fn);
    }
  },
  trigger: function(detectedType, count) {
    var base;
    console.log("Trigger " + detectedType + ", " + count);
    this.clickCounter = 0;
    return typeof (base = this.callbacks)[detectedType] === "function" ? base[detectedType](count) : void 0;
  }
};

module.exports = ButtonListener;
