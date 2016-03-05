/*
 *  This sketch sends /esp/[click|double|long] GET requests to the
 *
 *  Sleep: https://github.com/esp8266/Arduino/issues/1381
 *  Fuse setting
 *  @1MHz avrdude -p attiny85 -c usbasp -P usb -U lfuse:w:0x62:m -U hfuse:w:0xdf:m -U efuse:w:0xff:m
 *  @8MHz avrdude -p attiny85 -c usbasp -P usb -U lfuse:w:0xe2:m -U hfuse:w:0xdf:m -U efuse:w:0xff:m
 *
 */

//#include <SoftwareSerial.h>
#include "OneButton.h"

const int wakePin = 4;
const int buttonPin = 3;
OneButton button(buttonPin, true);


void setup() {
  //SoftwareSerial.begin(115200);
  pinMode(wakePin, OUTPUT);
  digitalWrite(wakePin, HIGH);
  delay(100);
  digitalWrite(wakePin, LOW);
  button.setClickTicks(400);
  button.setPressTicks(700);
  button.attachPress(buttonPress);
  button.attachClick(singleClick);
  button.attachDoubleClick(doubleClick);
  button.attachLongPressStop(longPress);
}

void loop() {
  button.tick();
  delay(5);
}

void sendRequest(String state) {
  //wakeUpESP();

  Serial.print("got " + state);

}

void wakeUpESP(int mode) {
  for (int i = mode; i > 0; i--) {
    digitalWrite(wakePin, HIGH);
    delay(100);
    digitalWrite(wakePin, LOW);
    delay(250);
  }
}

// Button went down, short burst
void buttonPress() {
  digitalWrite(wakePin, HIGH);
  delay(40);
  digitalWrite(wakePin, LOW);
}
void singleClick() {
  sendRequest("click");
  wakeUpESP(1);
}

void doubleClick() {
  sendRequest("double");
  wakeUpESP(2);
}

void longPress() {
  sendRequest("long");
  wakeUpESP(3);
}

