#include <AltSoftSerial.h>
#include <Wire.h>

AltSoftSerial altSerial;

void setup() {
  // put your setup code here, to run once:
  Serial.begin(57600);
  //altSerial.begin(115200);
  }

void loop() {
  // put your main code here, to run repeatedly:
if (Serial.available()) { 
   
  if (Serial.read() == 'K') // Receive
    { 
      altSerial.begin(57600);
      altSerial.println("B");
      altSerial.println("I am B");
      }
}     
if (Serial.available()) { 
  if (Serial.read() == 'A') // Transmit 
    { 
      pinMode(9, OUTPUT);           // set pin to INPUT state if not already an INPUT
      digitalWrite(9, HIGH);       // turn on pullup resistors
    
      /* this tended to confuse people with the digitalWrite so the language added */
      //delay(500);
      pinMode(9, INPUT_PULLUP);    // sets the pullup in one step
                                   // both forms work, INPUT_PULLUP
                                   // is probably preferred for clarity
      //delayMicroseconds(50);
      Serial.println("A! is ON and B Transmit-2 diabled");      
     }
}

}
