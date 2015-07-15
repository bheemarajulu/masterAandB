#include <Wire.h>
#include <AltSoftSerial.h>
AltSoftSerial altSerial;
#include "Adafruit_TCS34725.h"
#include <SparkFun_APDS9960.h>
/* Example code for the Adafruit TCS34725 breakout library */

/* Connect SCL    to analog 5
   Connect SDA    to analog 4
   Connect VDD    to 3.3V DC
   Connect GROUND to common ground */
       
/* Initialise with default values (int time = 2.4ms, gain = 1x) */
// Adafruit_TCS34725 tcs = Adafruit_TCS34725();

/* Initialise with specific int time and gain values */
Adafruit_TCS34725 tcs = Adafruit_TCS34725(TCS34725_INTEGRATIONTIME_700MS, TCS34725_GAIN_1X);
uint16_t red_light = 0;
uint16_t green_light = 0;
uint16_t blue_light = 0;
// Pins
#define APDS9960_INT    3 // Needs to be an interrupt pin
#define debounce 20 // ms debounce period 
#define holdTime 250 // ms hold time to know the button release time dealy
// Constants
        
// Global Variables
SparkFun_APDS9960 apds = SparkFun_APDS9960();
int isr_flag = 0;
// this constant won't change:
const int  buttonPin_red = 12;    // the pin that the pushbutton is attached to
const int  buttonPin_green_rst = 13;    // the pin that the pushbutton is attached to
const int  buttonPin_green_usb = 11;    // the pin that the pushbutton is attached to
const int  buttonPin_yellow = 8;    // the pin that the pushbutton is attached to
int buttonPushCounter = 0;   // counter for the number of button presses

void setup(void) {
  Serial.begin(57600);
  altSerial.begin(57600);  
  //altSerial.begin(57600);
  //altSerial.begin(57600);
  if (tcs.begin()) {
    Serial.println("Found sensor");
  } else {
    Serial.println("No TCS34725 found ... check your connections");
    while (1);
  } 
  pinMode(12, INPUT_PULLUP);
  pinMode(11, INPUT_PULLUP);
  pinMode(8, INPUT_PULLUP);
  // Set interrupt pin as input
  pinMode(APDS9960_INT, INPUT);
  // Initialize Serial port
  //Serial.begin(9600);
  //saltSerial.begin(57600);
  Serial.println();
  Serial.println(F("--------------------------------"));
  Serial.println(F("SparkFun APDS-9960 - GestureTest"));
  Serial.println(F("--------------------------------"));
  // Initialize interrupt service routine
  attachInterrupt(1, interruptRoutine, FALLING);
   // Initialize APDS-9960 (configure I2C and initial values)
  if ( apds.init() ) {
    Serial.println(F("APDS-9960 initialization complete"));
  } else {
    Serial.println(F("Something went wrong during APDS-9960 init!"));
  }
   
  // Start running the APDS-9960 gesture sensor engine
  if ( apds.enableGestureSensor(true) ) {
    Serial.println(F("Gesture sensor is now running"));
  } else {
    Serial.println(F("Something went wrong during gesture sensor init!"));
  }
  
  // Now we're ready to get readings!
}            
                              
void loop(void) {  
  if( isr_flag == 1 ) {
    if (Serial.available()) {  
 if (Serial.read() == 'N') // Receive
    {      
    detachInterrupt(0);
    handleGesture();    
    isr_flag = 0;
    attachInterrupt(0, interruptRoutine, FALLING);    
    //delay(20);
  }
    }
  }
  //handleGesture();
  sensor_data();
  buttons();
     
}
void sensor_data()
{
  if (Serial.available()) {
  
 if (Serial.read() == 'M') // Receive
    {  
      altSerial.begin(57600); 
      altSerial.println("A");
      //send_command();
      uint16_t clear, red, green, blue;
      Serial.flush ();
      tcs.setInterrupt(false);      // turn on LED
      //delay(60);  // takes 50ms to read 
      tcs.getRawData(&red, &green, &blue, &clear);
      tcs.setInterrupt(true);  // turn off LED
  // Figure out some basic hex code for visualization
  uint32_t sum = clear;
  float r, g, b; 
  float Int;
  //float H1,S1,I1;
  r = red;  
  g = green; 
  b = blue; 
  handleGesture();
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
       altSerial.print("Green");
       } 
     }
  
 if (bluenorm <= 0.1) {
    if (rednorm == 1 && greennorm <= 0.10 ) { 
      // between red
       altSerial.print("Red");
      }
     }
 if (bluenorm >= 0.99) {
      // between blue and violet
      altSerial.print("blue");
    } 
 if (cyannorm>=1 && magnetanorm==0.00 && bluenorm > 0.6) // Cyan
  {
    altSerial.print("Cyan"); 
  }
  if (magnetanorm >=1.00 && cyannorm==0) // Magneta
  {
    altSerial.print("Magneta");
  }
 if (yellownorm >1.5) // Yellow
  {
    altSerial.print("Yellow");
  }
 if (blacknorm >1.4 ) // Black
  {
    altSerial.print("Black");
  } 
 if (Int >10000 && yellownorm <1.20) // Intesity White 7311.33
  {
    altSerial.print("White");
  } 
  Serial.println("color");
  altSerial.println();
  Serial.flush ();
    // wait for transmit buffer to empty
      //while ((UCSR0A & _BV (TXC0)) == 0)
         // {}
     }
  }
  if (Serial.available()) {
   if (Serial.read() == 'A')// Transmit 
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

void handleGesture() {
  if ( apds.isGestureAvailable() ) {
    switch ( apds.readGesture() ) {
      case DIR_UP:
        altSerial.println("UP");
        break;
      case DIR_DOWN:
        altSerial.println("DOWN");
        break;
      case DIR_LEFT:
        altSerial.println("LEFT");
        break;
      case DIR_RIGHT:
        altSerial.println("RIGHT");
        break;
      case DIR_NEAR:
        altSerial.println("NEAR");
        break;
      case DIR_FAR:
        altSerial.println("FAR");
        break;
      default:
        altSerial.println("NONE");
    }
  }
}
 
              
void interruptRoutine() {
  isr_flag = 1;
}

void buttons()
{ 
  if (Serial.available()) {
  
 if (Serial.read() == 'L') // Receive
    {  
  if (digitalRead(buttonPin_red)==0) // 
  {
   
   delay(debounce);   
   buttonPushCounter++;
   altSerial.println("on");
   altSerial.print("button 1 Red pushes:  ");
   altSerial.println(buttonPushCounter);
   altSerial.println(); 
   delay( holdTime);   
  }  
 /*else
    if (digitalRead(buttonPin_green_rst)==0)
    {
       
   
   delay(debounce);   
   buttonPushCounter++;
   altSerial.println("on");
   altSerial.print("button 2 green_rst pushes:  ");
   altSerial.println(buttonPushCounter);
   altSerial.println(); 
   delay( holdTime);   
     } 
*/     
else
    if (digitalRead(buttonPin_green_usb)==0)
    {
     
   delay(debounce); 
   buttonPushCounter++;
   altSerial.println("on");
   altSerial.print("button 3 green_usb pushes:  ");
   altSerial.println(buttonPushCounter);
   altSerial.println(); 
   delay( holdTime);  
  
    }                   
 else
      if (digitalRead(buttonPin_yellow)==0)
      {
  
   delay(debounce); 
   buttonPushCounter++;
   altSerial.println("on");
   altSerial.print("button 4 yellow pushes:  ");
   altSerial.println(buttonPushCounter);
   altSerial.println();
   delay( holdTime);   
 
      }
   //else delay(holdTime); 
}
  }
}
