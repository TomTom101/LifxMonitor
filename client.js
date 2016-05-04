var LifxClient, bedroom, client;

LifxClient = require('node-lifx').Client;

client = new LifxClient();

client.init();

client.on('light-new', function(light) {
  console.log("New light");
  return light.getState(function(err, info) {
    return console.log(info);
  });
});

console.log(client.lights());

bedroom = client.light("d073d512170d");

if (bedroom) {
  console.log("Have bedroom light");
  bedroom.getPower(function(error, power) {
    return console.log("Power is " + power);
  });
} else {
  console.log("Could not get bedroom");
}
