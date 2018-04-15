import geomerative.*;

import processing.serial.*;

Serial port;
RShape image;
ImageWidget imageWidget;
RPoint[][] points;
boolean ignoringStyles = false;
byte[] bytes;
boolean fileLoaded;
boolean selecting;
boolean writing;
boolean stop;
boolean portOpened;

PFont primalFont;
color bgColor;
int barHeight; 
float scaleK;
float scaleStep;

Button loadFileButton;
Button scalePButton;
Button scaleMButton;
Button fastSpeedButton;
Button slowSpeedButton;
Button penSpeedButton;
Button drawButton;


void setup()  {
  println("Инициализация...");
  barHeight = 60;
  size(1000, 760);
  primalFont = createFont("Segoe UI",16,true);
  bgColor = 255;
  stroke(0);
  background(255);
  textFont(primalFont,12);
  loadFileButton = new Button(10, 10, 100, 40, "file select");
  scalePButton = new Button(120, 10, 50, 40, "+");
  scaleMButton = new Button(180, 10, 50, 40, "-");
  slowSpeedButton = new Button(240, 10, 50, 40, "slow");
  fastSpeedButton = new Button(300, 10, 50, 40, "fast");
  penSpeedButton = new Button(360, 10, 50, 40, "pen");
  drawButton = new Button(420, 10, 100, 40, "draw");
  imageWidget = new ImageWidget();
  fileLoaded = false;
  selecting = false;
  writing = false;
  stop = false;
  portOpened = false;
  scaleK = 1;
  scaleStep = 0.1;
  
  RG.init(this);
  RG.ignoreStyles(ignoringStyles);
  RG.setPolygonizer(RG.ADAPTATIVE);
  
  println("Инициализация завершена.");
}

void clc()  {
  clear();
  background(bgColor);
}

void draw()  {
  clc();
  loadFileButton.bDraw();
  scalePButton.bDraw();
  scaleMButton.bDraw();
  slowSpeedButton.bDraw();
  fastSpeedButton.bDraw();
  penSpeedButton.bDraw();
  drawButton.bDraw();
  fill(0);
  text("scale " + scaleK, 720, 30);
  
  if (imageWidget != null && fileLoaded)
    imageWidget.drawWidget();
  fill(0);
  line(0,barHeight,width,barHeight);
  fill(255);
}

void openFile(File selection)  {
   println("Выбор файла...");
   if (selection != null)  {
     println("Открытие файла " + selection.getName());
     image = null;
     image = RG.loadShape(selection.getAbsolutePath());
     //image.scale(scaleK); //3-4 для листа A4    6-7 для доски
     //points = image.getPointsInPaths();
     imageWidget.img = image;
     imageWidget.drawWidget();
     //paint();
     
     fileLoaded = true;
     println("Файл " + selection.getName() + " открыт");
   }  else  {
     println("Файл не выбран");
     fileLoaded = false;  
   }
   selecting = false;
}

void mousePressed()  {
  if (scalePButton.isPressed() && fileLoaded)  {
    imageWidget.img.scale(1 + scaleStep);
    scaleK += scaleStep;
  }
  
  if (scaleMButton.isPressed() && scaleK > scaleStep && fileLoaded)  {
    imageWidget.img.scale(1 - scaleStep);
    scaleK -= scaleStep;
  }
  
  if (loadFileButton.isPressed() && !selecting)  {
    selecting = true;
    //mousePressed = false;
    selectInput("select svg file", "openFile");
  }
  
  if (slowSpeedButton.isPressed())  {
    println("низкая скорость");
    setSpeed('1');
  }
  if (fastSpeedButton.isPressed())  {
    println("высокая скорость");
    setSpeed('2');
  }
  if (penSpeedButton.isPressed())  {
    println("ооооооч медленная скорость");
    setSpeed('0');
  }
  if (drawButton.isPressed() && fileLoaded)  {
    paint();  
  }
}

void keyPressed()  {
  float step = 10;
  println("keyPressed");
  if (fileLoaded)  {
    if (key == CODED)  {
      switch(keyCode)  {
        case UP:
          imageWidget.move(0, -step);
          break;
        case DOWN:
          imageWidget.move(0, step);
          break;
        case LEFT:
          imageWidget.move(-step, 0);
          break;
        case RIGHT:
          imageWidget.move(step, 0);
          break;
      }
    }
    imageWidget.drawWidget();
  }
}

void setSpeed(char c)  {
  if (!portOpened)  {
    port = new Serial(this, "COM3", 115200);
    delay(2000);
  }
  port.write(c);
  portOpened = true;
}

void paint()  {
  convertPoints();
  //image.scale(scaleK);
  //points = image.getPointsInPaths();
  
  if (!portOpened)
    port = new Serial(this, "COM3", 115200);
  delay(2000);
  
  for(int i = 0; i<points.length; i++){
    while (stop);
    serialWait();
          
    port.write('m');
    println("cmd m written");
    print("packing x: ");
    println(points[i][0].x);
    bytes = new byte[]{(byte)((int)points[i][0].x >>> 24),
                       (byte)((int)points[i][0].x >>> 16),
                       (byte)((int)points[i][0].x >>> 8),
                       (byte)((int)points[i][0].x)};
    port.write(bytes);
    printBytes();
         
    print("packing y: ");
    println(points[i][0].y);
    bytes = new byte[]{(byte)((int)points[i][0].y >>> 24),
                       (byte)((int)points[i][0].y >>> 16),
                       (byte)((int)points[i][0].y >>> 8),
                       (byte)((int)points[i][0].y)};
    port.write(bytes);
    printBytes();
    println(" ");
    for(int j = 0; j<points[i].length; j++){   
      while (stop);
      serialWait();
  
      port.write('p');
      println("cmd p written");
        
      print("packing x: ");
      println(points[i][j].x);
       
      bytes = new byte[]{(byte)((int)points[i][j].x >>> 24),
                         (byte)((int)points[i][j].x >>> 16),
                         (byte)((int)points[i][j].x >>> 8),
                         (byte)((int)points[i][j].x)};
       port.write(bytes);
       printBytes();
        
       print("packing y: ");
       println(points[i][j].y);
        
       bytes = new byte[]{(byte)((int)points[i][j].y >>> 24),
                          (byte)((int)points[i][j].y >>> 16),
                          (byte)((int)points[i][j].y >>> 8),
                          (byte)((int)points[i][j].y)};
       port.write(bytes);
       printBytes();
       println(" ");
    }
  }
  port.write('r');
  
  writing = false;
  println("Запись в порт завершена");
}

void printBytes(){
  print("bytes written: "); 
  print(bytes[0]);
  print(' ');
  print(bytes[1]);
  print(' ');
  print(bytes[2]);
  print(' ');
  println(bytes[3]);
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

void convertPoints()  {
  //image.scale(imageWidget.w/100, imageWidget.h/100);      //если изначальные размеры виджета 100*100
  image.scale(scaleK);
  points = image.getPointsInPaths();
  for (RPoint[] path : points) {
    for (RPoint point : path)  {     
      point.translate(imageWidget.x, imageWidget.y);  
    }
  }
}

class Button  {
  public Button(float x, float y, float w, float h, String bText) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.bText = bText;
    clr = 200;
  }
  public Button(float x, float y, float w, float h, String bText, color clr) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.bText = bText;
    this.clr = clr;
  }
  public void bDraw()  {
    stroke(color(0));
    fill(clr);
    rect(x, y, w, h); 
    fill(color(255));
    text(bText, x + w/2 - bText.length()*2, y + h/2);
  }
  public boolean isPressed()  {
    if (mouseX < (x+w) && mouseX > x && mouseY > y && mouseY < (y+h) && mousePressed)
      return true;
    else
      return false;
  }
  float x;
  float y;
  float w;
  float h;
  String bText;
  color clr;
}

class ImageWidget  {
   public ImageWidget()  {};
   public ImageWidget(RShape img)  {
     this.img = img;
     img.scale(0.001);
     //img.scale(scaleK);
     //h = 100 * img.height / img.width;
   }
   public ImageWidget(RShape img, float x, float y)  {
     
   }
   public void isPressed()  {
       
   }
   public void drawWidget()  {
     
     img.transform(x,y + barHeight,100*scaleK, 100*scaleK);
     img.setFill(color(254));
     img.setStroke(color(0));
     img.draw();
   }

   public void move(float tx, float ty)  {
     x += tx;
     y += ty;
     if (x < 0)
       x = 0;
     if (x + 100*scaleK > width)
       x = width - 100*scaleK;
     if (y < 0)
       y = 0;
     if (y + 100*scaleK > height - barHeight)
       y = (height - barHeight) - 100*scaleK;
     img.translate(x,y);
   }
   RShape img;
   float x = 0;
   float y = 0;
}
