import processing.serial.*;
import java.awt.datatransfer.*;
import java.awt.Toolkit;
import processing.opengl.*;
import saito.objloader.*;
import g4p_controls.*;

float roll  = 0.0F;
float pitch = 0.0F;
float yaw   = 0.0F;
float temp  = 0.0F;
float alt   = 0.0F;
String cube;
OBJModel model;

// Serial port state.
Serial       port;
String       buffer = "";
final String serialConfigFile = "serialconfig.txt";
boolean      printSerial = false;

// UI controls.
GPanel    configPanel;
GDropList serialList;
GLabel    serialLabel;
GCheckbox printSerialCheckbox;
PFont f;
void setup()
{
  size(1200, 800, OPENGL);
  frameRate(30);
  model = new OBJModel(this);
  model.load("CUBE_BOX.obj");
  model.scale(5);  
  //translate(5, 700);
  //rotate(PI/3.0);
  //rect(-26, -26, 52, 52);
 model.translateToCenter();
  f = createFont("Arial",30,true); 
  // Serial port setup.
  // Grab list of serial ports and choose one that was persisted earlier or default to the first port.
  int selectedPort = 1;
  String[] availablePorts = Serial.list();
  if (availablePorts == null) {
    println("ERROR: No serial ports available!");
    exit();
  }
  String[] serialConfig = loadStrings(serialConfigFile);
  if (serialConfig != null && serialConfig.length > 0) {
    String savedPort = serialConfig[0];
    // Check if saved port is in available ports.
    for (int i = 0; i < availablePorts.length; ++i) {
      if (availablePorts[i].equals(savedPort)) {
        selectedPort = i;
      } 
    }
  }
  // Build serial config UI.
  configPanel = new GPanel(this, 10, 10, width-20, 90, "Configuration (click to hide/show)");
  serialLabel = new GLabel(this,  0, 20, 80, 25, "Serial port:");
  configPanel.addControl(serialLabel);
  serialList = new GDropList(this, 90, 20, 200, 200, 6);
  serialList.setItems(availablePorts, selectedPort);
  configPanel.addControl(serialList);
  printSerialCheckbox = new GCheckbox(this, 5, 50, 200, 20, "Print serial data");
  printSerialCheckbox.setSelected(printSerial);
  configPanel.addControl(printSerialCheckbox);
  // Set serial port.
  setSerialPort(serialList.getSelectedText());
}
 
void draw()
{
  background(0,10,20);
  //background(255);

  textFont(f);       
  fill(10,102,153);
  text("Roll: ", 180, 100); //debug things… text(Hauteur, 10, 60);
  text(roll, 250, 100); //debug things… text(Hauteur, 10, 60);
  text("Pitch: ", 390, 100); //debug things… text(Hauteur, 10, 60);
  text(pitch, 460 , 100); //debug things… text(Hauteur, 10, 60);
  text("Yaw: ", 650, 100); //debug things… text(Hauteur, 10, 60);
  text(yaw, 730, 100); //debug things… text(Hauteur, 10, 60);
  text("cube: ", 650, 200); //debug things… text(Hauteur, 10, 60);
  //text(cube, 180, 200); //debug things… text(Hauteur, 10, 60);
  // Set a new co-ordinate space
  pushMatrix();
  //text(roll, 10, 30); //debug things...
  //text(pitch, 10, 60); 
  // Simple 3 point lighting for dramatic effect.
  // Slightly red light in upper right, slightly blue light in upper left, and white light from behind.
  pointLight(255, 200, 200,  400, 400,  500);
  pointLight(200, 200, 255, -400, 400,  500);
  pointLight(255, 255, 255,    0,   0, -500);
  
  // Displace objects from 0,0
  translate(500, 400, 0);
  
  // Rotate shapes around the X/Y/Z axis (values in radians, 0..Pi*2)
 // if (roll>0.520 && roll <1.650)
 // roll = (0);
 // if (pitch>6.500 && pitch <7.000)
 // pitch = (0);
  //if (yaw> -96.300 && yaw <-99.000)
 // yaw = (0);
  rotateX(radians(roll+90));
  rotateZ(radians(pitch-90));
  rotateY(radians(yaw+90));

  pushMatrix();
  noStroke();
  model.draw();
  popMatrix();
  popMatrix();
  port.write('W');
  //print("draw");
}

void Ciel() {
    //draw the sky
    background(255);
    noStroke();
    rectMode(CORNERS);

    for  (int i = 1; i < 600; i = i+10) {
        fill( 49    +i*0.165, 118   +i*0.118, 181  + i*0.075   );
        rect(0, i, 800, i+10);
    }
    popMatrix();
}

void serialEvent(Serial p) 
{
  String incoming = p.readString(); 
  
  if (printSerial) {
    println(incoming);
    
  }
  
  
  if ((incoming.length() > 8))
  {
    
    String[] list = split(incoming, " ");
    if ( (list.length > 0) && (list[0].equals("Orientation:")) ) 
    {
      roll  = float(list[1]);
      pitch = float(list[2]);
      yaw   = float(list[3]);
      println(trim(list[4]));
      /*if(list[4].equals("Green "))
      {
      cube  = trim(list[4]);
      println("I am Good");
      }
      buffer = incoming;
    }
    */
  }
    if ( (list.length > 0) && (list[0].equals("Alt:")) ) 
    {
      alt  = float(list[1]);
      buffer = incoming;
    }
    
    if ( (list.length > 0) && (list[0].equals("Temp:"))) 
    {
      println("I am Green");      
      buffer = incoming;
    }
  }
}
 
// Set serial port to desired value.
void setSerialPort(String portName) {
  // Close the port if it's currently open.
  if (port != null) {
    port.stop();
  }
  try {
    // Open port.
    port = new Serial(this, portName, 57600);
    port.bufferUntil('\n');
    // Persist port in configuration.
    saveStrings(serialConfigFile, new String[] { portName });
  }
  catch (RuntimeException ex) {
    // Swallow error if port can't be opened, keep port closed.
    port = null; 
  }
}

// UI event handlers

void handlePanelEvents(GPanel panel, GEvent event) {
  // Panel events, do nothing.
}

void handleDropListEvents(GDropList list, GEvent event) { 
  // Drop list events, check if new serial port is selected.
  if (list == serialList) {
    setSerialPort(serialList.getSelectedText()); 
  }
}

void handleToggleControlEvents(GToggleControl checkbox, GEvent event) { 
  // Checkbox toggle events, check if print events is toggled.
  if (checkbox == printSerialCheckbox) {
    printSerial = printSerialCheckbox.isSelected(); 
  }
}
