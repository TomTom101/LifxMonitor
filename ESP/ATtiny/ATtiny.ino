

/*
 *  This sketch sends /esp/[click|double|long] GET requests to the
 *
 *  Sleep: https://github.com/esp8266/Arduino/issues/1381
 *  Fuse setting
 *  @1MHz avrdude -p attiny85 -c usbasp -P usb -U lfuse:w:0x62:m -U hfuse:w:0xdf:m -U efuse:w:0xff:m
 *  @8MHz avrdude -p attiny85 -c usbasp -P usb -U lfuse:w:0xe2:m -U hfuse:w:0xdf:m -U efuse:w:0xff:m
 *
 *  Bug: Erster Klick nach Longpress wird immer ignoriert wenn attachLongPressStart() genutzt wird. Stop() geht
 */

#include <TinyWireS.h>
#include "./OneButton.h"
#include <avr/sleep.h>
#include <avr/interrupt.h>

#ifndef cbi
#define cbi(sfr, bit) (_SFR_BYTE(sfr) &= ~_BV(bit))
#endif
#ifndef sbi
#define sbi(sfr, bit) (_SFR_BYTE(sfr) |= _BV(bit))
#endif

#define I2C_SLAVE_ADDRESS 0x26 // A = 10 // the 7-bit address (remember to change this when adapting this example)
#define WAKE_PIN 4
#define BUTTON_PIN 3
#define LED_PIN 1

bool allowWakeup = true;

const unsigned int clickTicks = 350;
const unsigned int pressTicks = 600;
volatile unsigned long lastReset = 0;
unsigned long lastSleep = 0;
byte buttonStatus = 0x0;

OneButton button(BUTTON_PIN, true);

void setup() {

  pinMode(WAKE_PIN, OUTPUT);
  digitalWrite(WAKE_PIN, LOW);
  pinMode(LED_PIN, OUTPUT);
  digitalWrite(LED_PIN, LOW);

  button.setClickTicks(clickTicks);
  button.setPressTicks(pressTicks);
  button.attachPress(wakeUpESP);
  button.attachClick(singleClick);
  button.attachDoubleClick(doubleClick);
  button.attachLongPressStop(longPress);

  TinyWireS.begin(I2C_SLAVE_ADDRESS);
  TinyWireS.onRequest(requestEvent);
  TinyWireS.onReceive(receiveEvent);
  tws_delay(50);
}

void loop() {
  //blink(3, 100);
  system_sleep();
  //wakeUpESP();

  while (millis() - lastSleep < pressTicks + 100) {
    button.tick();
    tws_delay(20);
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
  allowWakeup = true;
}

void wakeUpESP() {
  
  if (allowWakeup) {

    digitalWrite(WAKE_PIN, HIGH);
    tws_delay(20);
    digitalWrite(WAKE_PIN, LOW);
    allowWakeup = false;
  }
}

void sendRequest(String state) {

  Serial.print("got " + state);

}

void blink(uint8_t times, uint16_t duration) {
  while (times--) {
    digitalWrite(LED_PIN, HIGH);
    tws_delay(duration);
    digitalWrite(LED_PIN, LOW);
    if (times > 0) {
      tws_delay(duration * 2);
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
  tws_delay(10);
} // sleep



// Pin change interrupt
ISR(PCINT0_vect) { }
