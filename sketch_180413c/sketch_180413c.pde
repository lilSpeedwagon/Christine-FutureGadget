import geomerative.*;

import processing.serial.*;

Serial port;
RPoint[][] point;
boolean ignoringStyles = false;

PFont primalFont;

Button loadFileButton;

void setup()  {
  size(500, 500);
  primalFont = createFont("Segoe UI",16,true);
  textFont(primalFont,12);
  loadFileButton = new Button(100,100,100,40,"file select",100);
  //port = new Serial(this, "COM3", 115200);
  RG.init(this);
  RG.ignoreStyles(ignoringStyles);
}

void draw()  {
  loadFileButton.bDraw();
}

void comThread()  {
  
}

void serialWait(){
  port.clear();
  port.write('s');
  char val = 0;
  while(val!='r'){
    if(port.available()>0){
      val = port.readChar();
      println(" ");
      print("recieved: ");
      println(val);
      println(" ");
    }
  for(int i = 0; i<=100000; i++);
  }
}

class Button  {
  public Button(int x, int y, int w, int h, String bText) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.bText = bText;
    clr = 0;
  }
  public Button(int x, int y, int w, int h, String bText, color clr) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.bText = bText;
    this.clr = clr;
  }
  public void bDraw()  {
    fill(clr);
    rect(x, y, w, h); 
    fill(255);
    text(bText, x + w/2, y + h/2);
  }
  int x;
  int y;
  int w;
  int h;
  String bText;
  color clr;
}
