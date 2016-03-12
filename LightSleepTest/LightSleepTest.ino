#include <ESP8266WiFi.h>

extern "C" {
#include "gpio.h"
}

extern "C" {
#include "user_interface.h"
}

#define LIGHT_WAKE_PIN 4

const char* ssid     = "TomTom2.4";
const char* password = "qCkdmFCQ";

IPAddress localIP(192, 168, 0, 14);
IPAddress gatewayIP(192, 168, 0, 100);
IPAddress subnetIP(255, 255, 255, 0);
IPAddress serverIP(192, 168, 0, 18);
const int httpPort = 3002;

WiFiClient client;

void setup()
{
  Serial.begin(115200);
  Serial.println("Setup");
  connectWiFi();
  delay(100);
}

void loop()
{
  sleep();
  delay(100);
  Serial.println("Woke up form sleep");
  sendRequest(0);
}
void sleep()
{

  wifi_fpm_set_sleep_type(LIGHT_SLEEP_T);
  wifi_fpm_open();
  gpio_pin_wakeup_enable(GPIO_ID_PIN(LIGHT_WAKE_PIN), GPIO_PIN_INTR_HILEVEL);
  wifi_fpm_do_sleep(0xFFFFFFF);
}

void sendRequest(byte state) {

  // Use WiFiClient class to create TCP connections
  

  if (!client.connect(serverIP, httpPort)) {
    Serial.println("Failed to connect!");
    return;
  }

  String url = "/esp/" + String(state);

  Serial.print("Requesting URL: ");
  Serial.println(url);

  // This will send the request to the server
  client.print(String("GET ") + url + " HTTP/1.1\r\n" +
               "Host: " + serverIP + "\r\n" +
               "Connection: close\r\n\r\n");
  // return here immediately, delaying and waiting for a server answer spoils the sleep
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

  Serial.print("\nWiFi connected with IP: ");
  Serial.println(WiFi.localIP());
}

void blink(uint8_t times, uint16_t duration) {
  while (times--) {
    digitalWrite(LIGHT_WAKE_PIN, HIGH);
    delay(duration);
    digitalWrite(LIGHT_WAKE_PIN, LOW);
    if (times > 0) {
      delay(duration * 2);
    }
  }
}
