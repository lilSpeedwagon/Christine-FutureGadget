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
    positiveDir = positiveD;
    steps = iSteps; 
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
  long rR0 = 6600;//длины тросов в мм
  long rL0 = 6600;
  long w   = 10300;//расстояние между моторами 
  
  long x0  =  -(pow(rR0,2)-pow(rL0,2)-pow(w,2))/2/w; //начальные координаты каретки
  long y0  =  sqrt(pow(rR0,2)-pow(x0,2));
  
  long x   =  x0;   //кооринаты в мм/10 
  long y   =  y0;
  
  long calcLengthL(long x1, long y1){
      return sqrt(pow(x1,2) + pow(y1,2))/10/stepSize;
    }
  long calcLengthR(long x1, long y1){
      return sqrt(pow(w-x1,2) + pow(y1,2))/10/stepSize;
    }
    
StepperMotor motorR;
StepperMotor motorL;

void printCoordinates()
    {
    Serial.println(" ");
    Serial.println("///////////////");
    Serial.print("x: ");
    Serial.print(x);
    Serial.println(" mm");
    
    Serial.print("y: ");
    Serial.print(y);
    Serial.println(" mm");
    
    Serial.print("r length: ");
    Serial.print(motorR.steps);
    Serial.println(" steps");

    Serial.print("l length: ");
    Serial.print(motorL.steps);
    Serial.println(" steps");
    
    Serial.println("///////////////");
    Serial.println(" ");
    }
    
void linearMove (long x1, long y1){
  if(x1!=x||y1!=y){
  float dx = x1-x;
  float dy = y1-y;
  float xt = x;
  float yt = y; 
  float ex = dx/sqrt(pow(dx,2)+pow(dy,2));
  float ey = dy/sqrt(pow(dx,2)+pow(dy,2));
  while(abs(dx)>2||abs(dy)>2){
  xt+=ex;
  yt+=ey;
  dx-=ex;
  dy-=ey;
  motorL.goTo(calcLengthL(xt,yt));
  motorR.goTo(calcLengthR(xt,yt));
  }
  x=x1;
  y=y1;
  }
  }
  
void setup() {
  
  Serial.begin(115200); 
  motorL.attach(STEPL,DIRL,LEFT, rL0/10/stepSize);
  motorR.attach(STEPR,DIRR,RIGHT,rR0/10/stepSize);
  pinMode(7, INPUT);
  
}

void loop() {

  while(analogRead(STICKY)>900||analogRead(STICKY)<100||analogRead(STICKX)<100||analogRead(STICKX)>900){   
  
  long  X = x; 
  long  Y = y;
  
  if(analogRead(STICKY)>900)
  X-=3;
  else if(analogRead(STICKY)<100)
  X+=3;
  
  if(analogRead(STICKX)<100)
  Y-=3;
  else if(analogRead(STICKX)>900)
  Y+=3;

  linearMove(X,Y);
  }


//if(digitalRead(7))
//motorR.goTo(motorR.steps+3);


if(Serial.available())
switch(Serial.read()){
  case 'g':
  printCoordinates(); 
  break;
  }
}
