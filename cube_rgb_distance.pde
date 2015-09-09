// Reading Pines
#include <Adafruit_TCS34725.h>
#include <Wire.h>
#include <AltSoftSerial.h>
int  ir_sensor0 = A0;
int  ir_sensor1 = A1;
int Reading;
AltSoftSerial altSerial;
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

void  setup () {
    // Initialize serial communications at 9600 bps
    Serial.begin (38400);
    altSerial.begin(38400);
    if (tcs.begin()) {
    Serial.println("Found sensor");
  } else {
    Serial.println("No TCS34725 found ... check your connections");
    while (1);
  } 
}
 
void  loop () {
    int  read, cm;
    rgb_sensor_data();
    Reading = analogRead (ir_sensor0); // sensor reading 0
    cm = pow (3300.4 / Reading, 1.2134); // convert to centimeters
    altSerial.print ( "Sensor 0" );
    altSerial.print(cm); // sensor reading 0
    altSerial.println();
    delay (500); // timeout
    
}

void rgb_sensor_data()
{
  if (Serial.available()) {
  
 if (Serial.read() == 'M') // Receive
    {  
      altSerial.begin(38400); 
      //altSerial.println("A");
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
}
