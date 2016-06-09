var FlicClient, FlicConnectionChannel, FlicScanner, LifxClient, buttonStateChange, client, fliclib, lifx, listenToButton, togglePower;

LifxClient = require('node-lifx').Client;

lifx = new LifxClient();

fliclib = require("./fliclibNodeJs");

FlicClient = fliclib.FlicClient;

FlicConnectionChannel = fliclib.FlicConnectionChannel;

FlicScanner = fliclib.FlicScanner;

client = new FlicClient("localhost", 5551);

lifx.init();

lifx.on('light-new', function(light) {
  console.log("New light");
  return light.getState(function(err, info) {
    return console.log(info);
  });
});

togglePower = function(state) {
  var bedroom;
  bedroom = lifx.light("d073d512170d");
  if (bedroom) {
    return bedroom[state](0, function(error, power) {
      if (error) {
        console.error(error);
      }
      return console.log("turned " + state);
    });
  }
};

buttonStateChange = function(clickType, wasQueued, timeDiff) {
  switch (clickType) {
    case "buttonDown":
      togglePower("on");
  }
  return console.log( clickType + (wasQueued != null ? wasQueued : {
    "wasQueued": "notQueued"
  }) + (" " + timeDiff + " seconds ago"));
};

listenToButton = function(bdAddr) {
  var cc;
  cc = new FlicConnectionChannel(bdAddr);
  client.addConnectionChannel(cc);
  cc.on("buttonUpOrDown", buttonStateChange);
  return cc.on("connectionStatusChanged", function(connectionStatus, disconnectReason) {
    var ref;
    return console.log(bdAddr + " " + connectionStatus + ((ref = connectionStatus === "Disconnected") != null ? ref : " " + {
      disconnectReason: ""
    }));
  });
};

client.once("ready", function() {
  console.log("Connected to daemon!");
  return client.getInfo(function(info) {
    return info.bdAddrOfVerifiedButtons.forEach(function(bdAddr) {
      return listenToButton(bdAddr);
    });
  });
});

client.on("bluetoothControllerStateChange", function(state) {
  return console.log("Bluetooth controller state change: " + state);
});

client.on("newVerifiedButton", function(bdAddr) {
  console.log("A new button was added: " + bdAddr);
  return listenToButton(bdAddr);
});

client.on("error", function(error) {
  return console.log("Daemon connection error: " + error);
});

client.on("close", function(hadError) {
  return console.log("Connection to daemon is now closed");
});
