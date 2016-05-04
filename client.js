var LifxClient, bedroom, client;

LifxClient = require('node-lifx').Client;

client = new LifxClient();

bedroom = client.light("d073d512170d");

if (bedroom) {
  console.log("Have bedroom light");
  bedroom.getPower(function(error, power) {
    return console.log("Power is " + power);
  });
} else {
  console.log("Could not get bedroom");
}
