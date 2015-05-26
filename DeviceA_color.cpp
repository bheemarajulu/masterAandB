#include <AltSoftSerial.h>
#include <Wire.h>
#include "Adafruit_TCS34725.h"
AltSoftSerial altSerial;
Adafruit_TCS34725 tcs = Adafruit_TCS34725(TCS34725_INTEGRATIONTIME_50MS, TCS34725_GAIN_4X);

void setup() {
  // put your setup code here, to run once:
  Serial.begin(57600);
  //altSerial.begin(115200);
  if (tcs.begin()) {
    Serial.println("Found sensor");
  } else {
    Serial.println("No TCS34725 found ... check your connections");
    while (1); // halt!
  }
  }


void loop() {
  // put your main code here, to run repeatedly:
if (Serial.available()) {
  
 if (Serial.read() == 'M') // Receive
    { 
      altSerial.begin(57600); 
      altSerial.println("A");
      uint16_t clear, red, green, blue;

  tcs.setInterrupt(false);      // turn on LED

  delay(60);  // takes 50ms to read 
  
  tcs.getRawData(&red, &green, &blue, &clear);

  tcs.setInterrupt(true);  // turn off LED
  
  altSerial.print("C:\t"); altSerial.print(clear);
  altSerial.print("\tR:\t"); altSerial.print(red);
  altSerial.print("\tG:\t"); altSerial.print(green);
  altSerial.print("\tB:\t"); altSerial.print(blue);

  // Figure out some basic hex code for visualization
  uint32_t sum = clear ;
  float r, g, b;
  r = red; r /= sum;
  g = green; g /= sum;
  b = blue; b /= sum;
  r *= 100; g *= 100; b *= 100;
  altSerial.print("\t");
  Serial.print((int)r, HEX); Serial.print((int)g, HEX); Serial.print((int)b, HEX);
  Serial.println();
  altSerial.println();
      Serial.flush ();
    // wait for transmit buffer to empty
      //while ((UCSR0A & _BV (TXC0)) == 0)
         // {}
     }
} 
if (Serial.available()) {
   if ((Serial.read() == 'B') || (Serial.read() == 'C')  || (Serial.read() == 'D')  || (Serial.read() == 'E'))// Transmit 
    { 
     Serial.flush();
      pinMode(9, OUTPUT);           // set pin to INPUT state if not already an INPUT
      digitalWrite(9, HIGH);       // turn on pullup resistors
    
      /* this tended to confuse people with the digitalWrite so the language added */
      //delay(500);
      pinMode(9, INPUT_PULLUP);    // sets the pullup in one step
                                   // both forms work, INPUT_PULLUP
                                   // is probably preferred for clarity
      //delayMicroseconds(50);
      Serial.println("A! is ON and B,C,D,E Transmit-2 diabled");  
      delay(1);     
     }
}
}
