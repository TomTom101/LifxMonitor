/*
 *  This sketch sends /esp/[click|double|long] GET requests to the
 *
 *  Sleep: https://github.com/esp8266/Arduino/issues/1381
 *
 */

#include <ESP8266WiFi.h>
//#include <WiFiUdp.h>
#include <Wire.h>

#define I2C_SLAVE_ADDRESS 0x26

extern "C" {
#include "user_interface.h"
}

const char* ssid     = "TomTom2.4";
const char* password = "qCkdmFCQ";

IPAddress localIP(192, 168, 0, 14);
IPAddress gatewayIP(192, 168, 0, 100);
IPAddress subnetIP(255, 255, 255, 0);
IPAddress serverIP(192, 168, 0, 10);
const int httpPort = 3000;
byte error;

void setup() {
  Wire.begin();
  Serial.begin(115200);
  delay(10);
  Serial.println("Woke up");
  initializeI2C();
  connectWiFi();

  sendRequest(requestButtonState());

  ESP.deepSleep(0);//WAKE_RF_DEFAULT https://github.com/sandeepmistry/esp8266-Arduino/blob/master/esp8266com/esp8266/cores/esp8266/Esp.h
}

byte requestButtonState() {
  Wire.requestFrom(I2C_SLAVE_ADDRESS, 1);
  while (Wire.available()) {
    return Wire.read();
  }
}

void initializeI2C() {
  Wire.beginTransmission(I2C_SLAVE_ADDRESS);
  error = Wire.endTransmission();
  if (error == 0)  {
    Serial.print("I2C device found");
  } else {
    Serial.print("Error ");
    Serial.println(error);
  }
}
void loop() {
  // Tell Attiny we're ready to receive a command
}


void sendRequest(byte state) {

  // Use WiFiClient class to create TCP connections
  WiFiClient client;

  if (!client.connect(serverIP, httpPort)) {
    Serial.println("connection failed");
    return;
  }

  // We now create a URI for the request
  String url = "/esp/" + String(state);

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



