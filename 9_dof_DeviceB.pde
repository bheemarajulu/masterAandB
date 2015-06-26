#include <SPI.h>
#include <Wire.h>
#include "floatToString.h"  //set to whatever is the location of floatToStrig
#include <Adafruit_Sensor.h>
#include <Adafruit_LSM9DS0.h>
#include <Adafruit_Simple_AHRS.h>
#include <AltSoftSerial.h>
#include <Wire.h>
#include "Adafruit_TCS34725.h"
AltSoftSerial altSerial;
Adafruit_TCS34725 tcs = Adafruit_TCS34725(TCS34725_INTEGRATIONTIME_50MS, TCS34725_GAIN_4X);




#include "ax25.h"
#define D_CALLSIGN      "GS"
#define D_CALLSIGN_ID   12
#define S_CALLSIGN      "UNHLRC"
#define S_CALLSIGN_ID   02
// Create LSM9DS0 board instance.
Adafruit_LSM9DS0     lsm(1000);  // Use I2C, ID #1000

// Create simple AHRS algorithm using the LSM9DS0 instance's accelerometer and magnetometer.
Adafruit_Simple_AHRS ahrs(&lsm.getAccel(), &lsm.getMag());

// Function to configure the sensors on the LSM9DS0 board.
// You don't need to change anything here, but have the option to select different
// range and gain values.

double floatVal=1.2;
  char charVal[10];               //temporarily holds data from vals 
  String stringVal = "";     //data on buff is copied to this string


void configureLSM9DS0(void)
{
  // 1.) Set the accelerometer range
  lsm.setupAccel(lsm.LSM9DS0_ACCELRANGE_2G);
  //lsm.setupAccel(lsm.LSM9DS0_ACCELRANGE_4G);
  //lsm.setupAccel(lsm.LSM9DS0_ACCELRANGE_6G);
  //lsm.setupAccel(lsm.LSM9DS0_ACCELRANGE_8G);
  //lsm.setupAccel(lsm.LSM9DS0_ACCELRANGE_16G);
  
  // 2.) Set the magnetometer sensitivity
  lsm.setupMag(lsm.LSM9DS0_MAGGAIN_2GAUSS);
  //lsm.setupMag(lsm.LSM9DS0_MAGGAIN_4GAUSS);
  //lsm.setupMag(lsm.LSM9DS0_MAGGAIN_8GAUSS);
  //lsm.setupMag(lsm.LSM9DS0_MAGGAIN_12GAUSS);

  // 3.) Setup the gyroscope
  lsm.setupGyro(lsm.LSM9DS0_GYROSCALE_245DPS);
  //lsm.setupGyro(lsm.LSM9DS0_GYROSCALE_500DPS);
  //lsm.setupGyro(lsm.LSM9DS0_GYROSCALE_2000DPS);
}

void setup(void) 
{
  Serial.begin(57600);
  Serial.println(F("Adafruit LSM9DS0 9 DOF Board AHRS Example")); Serial.println("");
  
  if (tcs.begin()) {
    Serial.println("Found sensor");
  } else {
    Serial.println("No TCS34725 found ... check your connections");
    while (1); // halt!
  }
  
  // Initialise the LSM9DS0 board.
  if(!lsm.begin())
  {
    // There was a problem detecting the LSM9DS0 ... check your connections
    Serial.print(F("Ooops, no LSM9DS0 detected ... Check your wiring or I2C ADDR!"));
    while(1);
  }
  
  // Setup the sensor gain and integration time.
  configureLSM9DS0();
  
}

void loop(void) 
{
  sensor_data();
}


void sensor_data()
{
// put your main code here, to run repeatedly:
if (Serial.available()>0) {
  //send_command();
  //Serial.println("Found S2");
 if (Serial.read() == 'W') // Receive
    { 
      altSerial.begin(57600); 
      //altSerial.println("B");
      //send_command();
      uint16_t clear, red, green, blue;
     Serial.flush ();
      dof();
  if (Serial.read() == 'R') // Receive
    {
  tcs.setInterrupt(false);      // turn on LED
  delay(40);  // takes 50ms to read   
  tcs.getRawData(&red, &green, &blue, &clear);
  tcs.setInterrupt(true);  // turn off LED
    }
  // Figure out some basic hex code for visualization
  uint32_t sum = clear;
  float r, g, b; 
  float Int;
  //float H1,S1,I1;
  r = red;  
  g = green; 
  b = blue; 
 
    //char character = Serial.read(); // Receive a single character from the software serial port
    //Data.concat(character); // Add the received character to the receive buffer
    // Serial.println("UP_bheema");
  Int = (r+g+b)/3; // Intensity calculated
  //Serial.print("\tInt:\t");Serial.print(Int);
  r = red; 
  r /= sum-Int; // Normalized Red
  g = green; 
  g /= sum-Int; // Normalized Green
  b = blue; 
  b /= sum-Int; // Normalized Blue

  float rbar,gbar,bbar,K,K1,C,M,Y; //RGB to CMYK conversion formula
  rbar = r;
  gbar = g;
  bbar = b;
  //max(r-b, g-b) K = 1-max(R', G', B')
  K1 = max(rbar, gbar); // The black key (K) color is calculated from the red (R'), green (G') and blue (B') colors:
  K = (1- max(K1, bbar)); // The black key (K) color is calculated from the red (R'), green (G') and blue (B') colors:
  C = (1-rbar-K)/(1-K); // The cyan color (C) is calculated from the red (R') and black (K) colors:
  M = (1-gbar-K)/(1-K); // The magenta color (M) is calculated from the green (G') and black (K) colors:
  Y = (1-bbar-K)/(1-K); // The yellow color (Y) is calculated from the blue (B') and black (K) colors:
  float remove1, normalize_2, s1,s2,s3,s4;
  if ((C < M) && (C < Y) && (C < K)) {
    remove1 = C;
    normalize_2 = max(M-C, Y-C);
    //normalize_2 = max(s1,K-C);
  } 
  else if ((M < C) && (M < Y) && (M < K)) {
    remove1 = M;
    normalize_2 = max(C-M, Y-M);
    //normalize_2 = max(s2,K-M);
  } 
  else if ((Y < C) && (Y < M) && (Y < K)) {
    remove1 = Y;
    normalize_2 = max(C-Y, M-Y);
    //normalize_2 = max(s3,K-Y);
  } 
 else if ((K < C) && (K < M) && (K < Y)) {
    remove1 = K;
    normalize_2 = max(C-K, M-K);
    //normalize_2 = max(s4,Y-C);
  } 
  // get rid of minority report
  float cyannorm = C - remove1;// - (g-b);
  float magnetanorm = M - remove1;// - (r-b);
  float yellownorm = Y - remove1;// - (r-g);
  float blacknorm = K - remove1;// - (Y+C+M);
  // now normalize for the highest number
  cyannorm /= normalize_2;
  magnetanorm /= normalize_2;
  yellownorm /= normalize_2;
  blacknorm /= normalize_2;
  
  float remove, normalize;
  if ((b < g) && (b < r)) {
    remove = b;
    normalize = max(r-b, g-b);
  } 
  else if ((g < b) && (g < r)) {
    remove = g;
    normalize = max(r-g, b-g);
  } 
  else {
    remove = r;
    normalize = max(b-r, g-r);
  }
  // get rid of minority report
  float rednorm = r - remove;
  float greennorm = g - remove;
  float bluenorm = b - remove;
  // now normalize for the highest number
  rednorm /= normalize;
  greennorm /= normalize;
  bluenorm /= normalize;

  
  int R = (r * 255);
  int G = (g * 255);
  int B = (b * 255);
    if (R > 255) R = 255;
    if (G > 255) G = 255;
    if (B > 255) B = 255;
 
  if (rednorm <= 0.1 && bluenorm <=0.10) {
       if (greennorm >= 0.99)  {
      // between green 
     // altSerial.print(F(" "));
       altSerial.print("Green");
       } 
     }
  
 if (bluenorm <= 0.1) {
    if (rednorm == 1 && greennorm <= 0.10 ) { 
      // between red
      //altSerial.print(F(" "));
       altSerial.print("Red");
      }
     }
 if (bluenorm >= 0.99) {
      // between blue and violet
      //altSerial.print(F(" "));
      altSerial.print("blue");
    } 
 if (cyannorm>=1 && magnetanorm==0.00 && bluenorm > 0.6) // Cyan
  {
    //altSerial.print(F(" "));
    altSerial.print("Cyan"); 
  }
  if (magnetanorm >=1.00 && cyannorm==0) // Magneta
  {
    //altSerial.print(F(" "));
    altSerial.print("Magneta");
  }
 if (yellownorm >1.5) // Yellow
  {
    //altSerial.print(F(" "));
    altSerial.print("Yellow");
  }
 if (blacknorm >1.4 ) // Black
  {
    //altSerial.print(F(" "));
    altSerial.print("Black");
  } 
 if (Int >10000 && yellownorm <1.20) // Intesity White 7311.33
  {
    //altSerial.print(F(" "));
    altSerial.print("White");
  } 
    
  Serial.println("color");
  //altSerial.print(F(" "));
  altSerial.println();
  Serial.flush ();
    // wait for transmit buffer to empty
      //while ((UCSR0A & _BV (TXC0)) == 0)
         // {}
     }
} 

if (Serial.available()) { 
   if (Serial.read() == 'B')// Transmit 
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
      Serial.println("B! is ON and B,C,D,E Transmit-2 diabled");  
      delay(1);     
     }
}

}

void dof()
{
  char temp;
  float buffer[25]; 
  float floatVal=123.234;
  char charVal[10];               //temporarily holds data from vals 
  const struct s_address addresses[] = { 
    {D_CALLSIGN, D_CALLSIGN_ID},  // Destination callsign
    {S_CALLSIGN, S_CALLSIGN_ID},  // Source callsign (-11 = balloon, -9 = car)
  };
  sensors_vec_t   orientation;
  
  // Use the simple AHRS function to get the current orientation.
  if (ahrs.getOrientation(&orientation))
  {
   /* /* 'orientation' should have valid .roll and .pitch fields */
    altSerial.print(F("Orientation: "));
    altSerial.print(orientation.roll);
    dtostrf(orientation.roll, 4, 4, charVal);  //4 is mininum width, 4 is precision; float value 
    //Serial.print(temp);
    //temp = (floatToString(buffer, orientation.roll, 5)); 
    altSerial.print(F(" "));
    altSerial.print(orientation.pitch);
    altSerial.print(F(" "));
    altSerial.print(orientation.heading);
    altSerial.print(F(" "));
  }
  
  delay(100);
}
