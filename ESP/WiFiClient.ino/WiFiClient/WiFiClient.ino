/*
 *  This sketch sends /esp/[click|double|long] GET requests to the
 *
 *  Sleep: https://github.com/esp8266/Arduino/issues/1381
 *
 */

#include <ESP8266WiFi.h>
#include <WiFiUdp.h>
#include "OneButton.h"
extern "C" {
#include "user_interface.h"
}


const char* ssid     = "TomTom2.4";
const char* password = "qCkdmFCQ";
const int sleepTimeS = 0;

OneButton button(0, true);

IPAddress localIP(192, 168, 0, 14);
IPAddress gatewayIP(192, 168, 0, 100);
IPAddress subnetIP(255, 255, 255, 0);
IPAddress serverIP(192, 168, 0, 10);
const int httpPort = 3000;

void setup() {
  
  Serial.begin(115200);
  delay(10);
  Serial.println("woke up");

  button.setClickTicks(400);
  button.setPressTicks(700);
  button.attachClick(singleClick);
  button.attachDoubleClick(doubleClick);
  button.attachLongPressStop(longPress);

  //sendUDPRequest();
  ESP.deepSleep(sleepTimeS * 1000000);//WAKE_RF_DEFAULT https://github.com/sandeepmistry/esp8266-Arduino/blob/master/esp8266com/esp8266/cores/esp8266/Esp.h
}

void loop() {
  button.tick();
  delay(10);
}

void sendRequest(String state) {

  connectWiFi();
  Serial.print("connecting to ");
  Serial.println(serverIP);

  // Use WiFiClient class to create TCP connections
  WiFiClient client;
  
  if (!client.connect(serverIP, httpPort)) {
    Serial.println("connection failed");
    return;
  }

  // We now create a URI for the request
  String url = "/esp/" + state;

  Serial.print("Requesting URL: ");
  Serial.println(url);

  // This will send the request to the server
  client.print(String("GET ") + url + " HTTP/1.1\r\n" +
               "Host: " + serverIP + "\r\n" +
               "Connection: close\r\n\r\n");
  delay(10);

  while (client.available()) {
    String line = client.readStringUntil('\r');
    Serial.print(line);
  }

  
  Serial.println("closing connection");
  WiFi.disconnect();
}

void connectWiFi() {
  Serial.print("Connecting to ");
  Serial.println(ssid);

  WiFi.begin(ssid, password);
  WiFi.config(localIP, gatewayIP, subnetIP); // indeed AFTER begin! between 700ms to 1s faster connect
 
  while (WiFi.status() != WL_CONNECTED) {
    delay(250);
    Serial.print(".");
  }

  Serial.print("WiFi connected with IP: ");
  Serial.println(WiFi.localIP());
}



void singleClick() {
  sendRequest("click");
}

void doubleClick() {
  sendRequest("double");
}

void longPress() {
  sendRequest("long");
}

