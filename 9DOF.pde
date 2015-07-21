//
//  Created by Nicholas Robinson on 04/19/14.
//  Copyright (c) 2014 Nicholas Robinson. All rights reserved.
//

#include <SPI.h>
#include <Wire.h>
#include <SFE_LSM9DS0.h>
#include <LSM9DS0_AHRS.h>
#include <AltSoftSerial.h>

LSM9DS0_AHRS* ahrs;
AltSoftSerial altSerial;

int led = 13;
int count = 0;
int count_delta = 0;

void setup()
{
  Serial.begin(38400);
  altSerial.begin(38400);
  //altSerial.println("Hello World");
  pinMode(led, OUTPUT);
  ahrs = new LSM9DS0_AHRS(MADGWICK);
}

void loop()
{ 
  ahrs->update();
  
  count_delta = millis() - count;
  if (count_delta < 250)
    digitalWrite(led, HIGH);
  else
    digitalWrite(led, LOW);
    
  if (count_delta > 500) 
  { 
    altSerial.print(F("Orientation: "));
    altSerial.print(ahrs->roll,2);
    altSerial.print(F(" "));
    altSerial.print(ahrs->pitch,2);
    altSerial.print(F(" "));
    altSerial.print(ahrs->yaw,2);
    altSerial.println(F(""));
    //altSerial.print(", dt = "); altSerial.println(ahrs->dt, 4);
    count = millis();
  }
}
