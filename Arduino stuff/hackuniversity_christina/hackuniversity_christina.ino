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

  public:
   
  uint8_t stepPin;
  uint8_t dirPin;
  uint8_t positiveDir;

  long steps = 0;
  long lastStepTime = 0;

  long del = 1000;//минимальный период между обращениями к драйверу мотора 
  
  void attach(uint8_t stepP, uint8_t dirP, uint8_t positiveD, long iSteps )// инициализация мотора
    {
    dirPin=dirP;
    stepPin=stepP; 
    pinMode(stepPin, OUTPUT);
    pinMode(dirPin, OUTPUT); 
    digitalWrite(stepPin, LOW);
    digitalWrite(dirPin, LOW);
    }

  //один шаг в + направлении
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
    
  //один шаг в - направлении  
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
    
  //устанавливает длину троса в положение stp 
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

  float stepSize = 0.01; //изменение длины троса за 1 шаг мотора
  long rR0 = 6600;//длины тросов в мм/10
  long rL0 = 6600;
  long w   = 10300;//расстояние между моторами 
  long x0  = 2500;// начальные координаты каретки
  long y0  = 2500;
  long x   = x0;   //кооринаты в мм/10 
  long y   = y0;
  
  void calcLengthR(long x1, long y1){
    
    }
    
  void calcLengthL(long x1, long y1){
    
    }
      
  void linearMove (long x1, long y1){
    
    }

StepperMotor motorR;
StepperMotor motorL;

void setup() {
  Serial.begin(115200); 
  motorR.attach(STEPL,DIRL,LEFT, 10000);
  motorL.attach(STEPR,DIRR,RIGHT,10000);
}



void loop() {
/*
  if(analogRead(STICKX)>900)
  motorR.goTo(motorR.steps+10);
  else if(analogRead(STICKX)<200)
  motorR.goTo(motorR.steps-10);
  if(analogRead(STICKY)>900)
  motorL.goTo(motorL.steps+10);
  else if(analogRead(STICKY)<200)
  motorL.goTo(motorL.steps-10);
*/

  
}
