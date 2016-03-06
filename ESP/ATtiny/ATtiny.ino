

/*
 *  This sketch sends /esp/[click|double|long] GET requests to the
 *
 *  Sleep: https://github.com/esp8266/Arduino/issues/1381
 *  Fuse setting
 *  @1MHz avrdude -p attiny85 -c usbasp -P usb -U lfuse:w:0x62:m -U hfuse:w:0xdf:m -U efuse:w:0xff:m
 *  @8MHz avrdude -p attiny85 -c usbasp -P usb -U lfuse:w:0xe2:m -U hfuse:w:0xdf:m -U efuse:w:0xff:m
 *
 */

#include <TinyWireS.h>
#include "OneButton.h"
#include <avr/sleep.h>

#define I2C_SLAVE_ADDRESS 0x26 // A = 10 // the 7-bit address (remember to change this when adapting this example)

const int wakePin = 4;
const int buttonPin = 3;
const int ledPin = 1;
OneButton button(buttonPin, true);
unsigned long lastReset = 0;
volatile byte buttonStatus = 0x0;

#ifndef cbi
#define cbi(sfr, bit) (_SFR_BYTE(sfr) &= ~_BV(bit))
#endif
#ifndef sbi
#define sbi(sfr, bit) (_SFR_BYTE(sfr) |= _BV(bit))
#endif

void setup() {
  //SoftwareSerial.begin(115200);
  pinMode(wakePin, OUTPUT);
  digitalWrite(wakePin, LOW);
  pinMode(ledPin, OUTPUT);
  digitalWrite(ledPin, LOW);
  blink(1, 1000);

  button.setClickTicks(400);
  button.setPressTicks(700);
  button.attachPress(wakeUpESP);
  button.attachClick(singleClick);
  button.attachDoubleClick(doubleClick);
  button.attachLongPressStop(longPress);

  TinyWireS.begin(I2C_SLAVE_ADDRESS);
  TinyWireS.onRequest(requestEvent);
  TinyWireS.onReceive(receiveEvent);
}

void loop() {
  //system_sleep();
  button.tick();
  delay(5);
}

void receiveEvent(uint8_t b) {
  blink(3);
}

/**
 * This is called for each read request we receive, never put more than one byte of data (with TinyWireS.send) to the
 * send-buffer when using this callback
 */
void requestEvent() {
  TinyWireS.send(buttonStatus);
  //blink(2);
}

void wakeUpESP() {
  if (millis() - lastReset > 5000) {
    digitalWrite(wakePin, HIGH);
    delay(10);
    digitalWrite(wakePin, LOW);
    lastReset = millis();
  }
}

void sendRequest(String state) {

  Serial.print("got " + state);

}

void blink(uint8_t times, uint16_t duration) {
  while (times--) {
    digitalWrite(ledPin, HIGH);
    delay(duration);
    digitalWrite(ledPin, LOW);
    delay(duration * 2);
  }
}
void blink(uint8_t times) {
  blink(times, 50);
}

void singleClick() {
  blink(1);
  buttonStatus = 1;
}

void doubleClick() {
  blink(2);
  buttonStatus = 2;
}

void longPress() {
  blink(3);
  buttonStatus = 3;
}

void system_sleep() {

  cbi(ADCSRA, ADEN);                   // switch Analog to Digitalconverter OFF

  set_sleep_mode(SLEEP_MODE_IDLE); // sleep mode is set here
  sleep_enable();

  sleep_mode();                        // System actually sleeps here

  sleep_disable();                     // System continues execution here when watchdog timed out

  //sbi(ADCSRA,ADEN);                    // switch Analog to Digitalconverter ON

}
