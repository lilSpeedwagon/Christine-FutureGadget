#include <Servo.h>

#define STICKX A0
#define STICKY A1
#define STEPL A2
#define DIRL A3
#define STEPR A4
#define DIRR A5

#define RIGHT 1
#define LEFT  0 

class StepperMotor{

  uint8_t stepPin;
  uint8_t dirPin;
  uint8_t positiveDir;

  long steps = 0;
  long lastStepTime = 0;

  long del = 20;
  
  void attach(uint8_t stepP, uint8_t dirP, uint8_t positiveD, long iSteps )// инициализация мотора
    { 
    pinMode(stepPin, OUTPUT);
    pinMode(stepDir, OUTPUT); 
    digitalWrite(stepPin, LOW);
    digitalWrite(stepDir, LOW);
    }

  void stepPlus()
    {
    if(positiveDir)
    digitalWrite(dirPin, HIGH); 
    else  
    digitalWrite(dirPin, LOW); 
    
    digitalWrite(stepPin, HIGH);
    digitalWrite(stepPin, LOW);
    steps++;
    }
  void stepMin()
    {
    if(positiveDir)
    digitalWrite(dirPin, LOW); 
    else  
    digitalWrite(dirPin, HIGH); 
    
    digitalWrite(stepPin, HIGH);
    digitalWrite(stepPin, LOW);
    steps--;
    }
  
  void goTo(long stp)
    {
      while(micros()-lastStepTime<=del);
      while(steps!=stp){
      if(steps<stp)
      stepPlus();
      else 
      stepMin();
      }
      lastStepTime = micros();
    }
  };

  void linearMove(){
    
    }

StepperMotor motorR;
StepperMotor motorL;

void setup() {
Serial.begin(115200); 
motorR.attach(STEPL,DIRL,LEFT, 10000);
motorL.attach(STEPR,DIRR,RIGHT,10000);
}

void loop() {

}
