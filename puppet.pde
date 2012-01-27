///////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// 
//  Coded by Kim Llums - www.skmcreatiu.com
//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Time of the interrupt in ms
#define interrupt_delay 50 
//Time of motor frequency
#define Ton 100  // Period on which the motor will be in ON state
#define Toff_min 100  // Minimum period where motor will be OFF, so whill change of state rapidly
#define Toff_max 1500 // Maxium period where motor will be OFF, so whill change of state slower

//Time record variable
long time;

 // select the input analog pin for the potentiometer
int potPinX = 0;
int potPinY = 1;
int potPinZ = 2;

// define pins for motors
int MotorX0 = 13;
int MotorX1 = 9;
int MotorY2 = 8;
int MotorY3 = 7;
int MotorZ4 = 6;
int MotorZ5 = 5;

//define variables to contain the recorded analog values from pots
float valueX = 0;
float valueY = 0;
float valueZ = 0;

//TIMING of motors
float Toff_motorX;
boolean motor_X_modeON = true;
int motorX_state = LOW;
long motorX_timingON;
long motorX_timingOFF;
//////////////////////////////////X
float Toff_motorY;
boolean motor_Y_modeON = true;
int motorY_state = LOW;
long motorY_timingON;
long motorY_timingOFF;
//////////////////////////////////Y
float Toff_motorZ;
boolean motor_Z_modeON = true;
int motorZ_state = LOW;
long motorZ_timingON;
long motorZ_timingOFF;
//////////////////////////////////Z

void setup() {
  // set up delay interrupt
  time=millis() + interrupt_delay; 
  motorX_timingON = millis() + 3000; // Init time
  //declare the pot pins as INPUTs
  pinMode(potPinX, INPUT);
  pinMode(potPinY, INPUT);
  pinMode(potPinZ, INPUT);
  // declare the motor pins as OUTPUTs:
  pinMode(MotorX0, OUTPUT);
  pinMode(MotorX1, OUTPUT);
  pinMode(MotorY2, OUTPUT);
  pinMode(MotorY3, OUTPUT);
  pinMode(MotorZ4, OUTPUT);
  pinMode(MotorZ5, OUTPUT);
  //start serial
  Serial.begin(9600);
}

void loop() {
  read_pot();
  check_interrupt();
}

void read_pot(){
  //AnalogRead
  valueX = analogRead(potPinX);
  valueY = analogRead(potPinY);
  valueZ = analogRead(potPinZ);
}

void output_to_motors(){
  digitalWrite(MotorX0, motorX_state);
  digitalWrite(MotorX1, motorX_state);
  digitalWrite(MotorY2, motorY_state);
  digitalWrite(MotorY3, motorY_state);
  digitalWrite(MotorZ4, motorZ_state);
  digitalWrite(MotorZ5, motorZ_state);
}

void check_interrupt() {
  // If the actual time is greater than the last prevision time: do the function
  if(time < millis()) {
    refresh_motors();
    time=millis() + interrupt_delay; // record future next time int trigger
  }
}

void refresh_motors(){
  //Calculate Toff motor states according potenciometers
  Toff_motorX = Toff_min + ((Toff_max - Toff_min) / (1024/(valueX+1)));
  Toff_motorY = Toff_min + ((Toff_max - Toff_min) / (1024/(valueY+1)));
  Toff_motorZ = Toff_min + ((Toff_max - Toff_min) / (1024/(valueZ+1)));
  
  //debug
  //Serial.print (Toff_motorX);
  //Serial.print (" - ");
  //Serial.print (motor_X_modeON,HEX);
  //Serial.print (" - ");
  
  //Calculate timings
  //X motor
  if (motor_X_modeON == true) {
   if ((motorX_timingON + Ton) > millis()) {
     motorX_state = LOW;
     motor_X_modeON = false;
     motorX_timingOFF = millis();
   } 
  }else{
    if ((motorX_timingOFF + Toff_motorX) < millis()) {
      motorX_state = HIGH;
      motor_X_modeON = true;
      motorX_timingON = millis();
    }
  }
  //Y motor
  if (motor_Y_modeON == true) {
   if ((motorY_timingON + Ton) > millis()) {
     motorY_state = LOW;
     motor_Y_modeON = false;
     motorY_timingOFF = millis();
   } 
  }else{
    if ((motorY_timingOFF + Toff_motorY) < millis()) {
      motorY_state = HIGH;
      motor_Y_modeON = true;
      motorY_timingON = millis();
    }
  }
  //Z motor
  if (motor_Z_modeON == true) {
   if ((motorZ_timingON + Ton) > millis()) {
     motorZ_state = LOW;
     motor_Z_modeON = false;
     motorZ_timingOFF = millis();
   } 
  }else{
    if ((motorZ_timingOFF + Toff_motorZ) < millis()) {
      motorZ_state = HIGH;
      motor_Z_modeON = true;
      motorZ_timingON = millis();
    }
  }
  
  // Update real states
  output_to_motors();
}
