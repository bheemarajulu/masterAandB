/*************************** Multiple Ardunio Communication****************/
void setup() {
  // put your setup code here, to run once:
Serial.begin(57600);
}

void loop() {
  // loop from the lowest pin to the highest:
  for (int i = 2; i < 8; i++) {
    // turn the pin on:
    Serial.print("G"); // C
    Serial.print("A");
    Serial.print("B");
    Serial.print("D");
    Serial.print("E");
    delay(40);
  }
delay(40);
  // loop from the highest pin to the lowest:
  for (int i = 2; i < 8; i++) 
  {
    // turn the pin on:
    Serial.print("L"); // D
    Serial.print("A");
    Serial.print("B");
    Serial.print("C");
    Serial.print("E");
    delay(40);
  }
delay(40);
  // loop from the highest pin to the lowest:
  for (int i = 2; i < 8; i++) 
  {
    // turn the pin on:
    Serial.print("R"); // E
    Serial.print("A");
    Serial.print("B");
    Serial.print("C");
    Serial.print("D");
    delay(40);
  }
delay(40);
  // loop from the highest pin to the lowest:
  for (int i = 2; i < 8; i++) 
  {
    // turn the pin on:
    Serial.print("M"); // A
    Serial.print("B");
    Serial.print("C");
    Serial.print("D");
    Serial.print("E");
    delay(40);
  }
}
