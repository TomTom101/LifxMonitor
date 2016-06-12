var ButtonListener, delay;

delay = function(sec, func) {
  return setTimeout(func, sec);
};

ButtonListener = {
  callbacks: {},
  longPressTimer: 0,
  nClicksTimer: 0,
  clickCounter: 0,
  init: function() {
    return console.log("Alive");
  },
  listen: function(clickType, wasQueued, timeDiff) {
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
      this.longPressTimer = delay(500, this.trigger.bind(this, 'longPress'));
    }
    return this.clickCounter++;
  },
  ButtonUp: function() {
    var fn;
    console.log("ButtonUp " + (typeof this.longPressTimer));
    this.resetTimeout(this.longPressTimer);
    fn = this.trigger.bind(this, 'nClicks', this.clickCounter);
    this.resetTimeout(this.nClicksTimer);
    return this.nClicksTimer = delay(100, fn);
  },
  trigger: function(detectedType, count) {
    var base;
    console.log("Trigger " + detectedType + ", " + count);
    this.clickCounter = 0;
    return typeof (base = this.callbacks)[detectedType] === "function" ? base[detectedType](count) : void 0;
  }
};

module.exports = ButtonListener;
