

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
#include "./OneButton.h"
#include <avr/sleep.h>
#include <avr/interrupt.h>

#define I2C_SLAVE_ADDRESS 0x26 // A = 10 // the 7-bit address (remember to change this when adapting this example)

const int wakePin = 4;
const int buttonPin = 3;
const int ledPin = 1;
const unsigned int clickTicks = 350;
const unsigned int pressTicks = 600;

unsigned long lastReset = 0;
unsigned long lastSleep = 0;
byte buttonStatus = 0x0;

OneButton button(buttonPin, true);

#ifndef cbi
#define cbi(sfr, bit) (_SFR_BYTE(sfr) &= ~_BV(bit))
#endif
#ifndef sbi
#define sbi(sfr, bit) (_SFR_BYTE(sfr) |= _BV(bit))
#endif

void setup() {
  pinMode(wakePin, OUTPUT);
  digitalWrite(wakePin, LOW);

  pinMode(ledPin, OUTPUT);
  digitalWrite(ledPin, LOW);

  button.setClickTicks(clickTicks);
  button.setPressTicks(pressTicks);
  //button.attachPress(wakeUpESP);
  button.attachClick(singleClick);
  button.attachDoubleClick(doubleClick);
  button.attachLongPressStart(longPress);

  TinyWireS.begin(I2C_SLAVE_ADDRESS);
  TinyWireS.onRequest(requestEvent);
  TinyWireS.onReceive(receiveEvent);
}

void loop() {
  system_sleep();
  wakeUpESP();

  while (millis() - lastSleep < pressTicks + 100) {
    button.tick();
    delay(20);
  }
  
  lastSleep = millis();
}

void receiveEvent(uint8_t b) {
  blink(1, 25);
}

/**
 * This is called for each read request we receive, never put more than one byte of data (with TinyWireS.send) to the
 * send-buffer when using this callback
 */
void requestEvent() {
  TinyWireS.send(buttonStatus);
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
    if (times > 0) {
      delay(duration * 2);
    }
  }
}
void blink(uint8_t times) {
  blink(times, 75);
}

void singleClick() {
  blink(1);
  buttonStatus = 1;
}

void doubleClick() {
  blink(2, 100);
  buttonStatus = 2;
}

void longPress() {
  blink(1, 500);
  buttonStatus = 3;
}

void system_sleep() {

  GIMSK |= _BV(PCIE);                     // Enable Pin Change Interrupts
  PCMSK |= _BV(PCINT3);                   // Use PB3 as interrupt pin
  ADCSRA &= ~_BV(ADEN);                   // ADC off
  set_sleep_mode(SLEEP_MODE_PWR_DOWN);    // replaces above statement

  sleep_enable();                         // Sets the Sleep Enable bit in the MCUCR Register (SE BIT)
  sei();                                  // Enable interrupts
  sleep_cpu();                            // sleep

  cli();                                  // Disable interrupts
  PCMSK &= ~_BV(PCINT3);                  // Turn off PB3 as interrupt pin
  sleep_disable();                        // Clear SE bit
  ADCSRA |= _BV(ADEN);                    // ADC on

  sei();                                  // Enable interrupts
  delay(10);
} // sleep



// Pin change interrupt
ISR(PCINT0_vect) { }
