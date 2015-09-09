// Reading Pines
#include <AltSoftSerial.h>
int  ir_sensor0 = A0;
int  ir_sensor1 = A1;
int Reading;
AltSoftSerial altSerial;
void  setup () {
    // Initialize serial communications at 9600 bps
    Serial.begin (38400);
    altSerial.begin(38400);
}
 
void  loop () {
    int  read, cm;
    Reading = analogRead (ir_sensor0); // sensor reading 0
    cm = pow (3300.4 / Reading, 1.2134); // convert to centimeters
    altSerial.print ( "Sensor 0" );
    altSerial.print(cm); // sensor reading 0
    altSerial.println();
    delay (500); // timeout
    
}
