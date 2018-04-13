import geomerative.*;

import processing.serial.*;

Serial port;
RShape image;
ImageWidget imageWidget;
RPoint[][] points;
boolean ignoringStyles = false;
byte[] bytes;

PFont primalFont;
color bgColor;
float barHeight; 

Button loadFileButton;
Button writeButton;


void setup()  {
  println("Инициализация...");
  size(500, 500);
  primalFont = createFont("Segoe UI",16,true);
  barHeight = 60;
  bgColor = 255;
  stroke(0);
  background(255);
  textFont(primalFont,12);
  loadFileButton = new Button(10, 10, 100, 40, "file select");
  writeButton = new Button(120, 10, 100, 40, "write data");
  
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
  writeButton.bDraw();
  if (imageWidget != null)
    imageWidget.drawWidget();
  fill(0);
  line(0,barHeight,width,barHeight);
  if (loadFileButton.isPressed())
    openFile("D:\\docs\\programms\\Future Gadgets LAb\\Christine\\Christine-FutureGadget\\test.svg");
}

void openFile(String fileName)  {
   println("Открытие файла " + fileName);
   image = RG.loadShape(fileName);
   points = image.getPointsInPaths();
   imageWidget = new ImageWidget(image);
   imageWidget.drawWidget();
}

void keyPressed()  {
  float step = 10;
  println("keyPressed");
  if (imageWidget.img != null)  {
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
    else  {
      switch(key)  {
        case '+':
          imageWidget.scale(1.1);
          break;
        case '-':
          imageWidget.scale(0.9);
          break;
      }
    }
    imageWidget.drawWidget();
  }
}

void comThread()  {
  convertPoints();
  port = new Serial(this, "COM3", 115200);
  delay(4000);
  
  for(int i = 0; i<points.length; i++){
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
  for (RPoint[] path : points) {
    for (RPoint point : path)  {
      point.scale(imageWidget.w/100, imageWidget.h/100);      //если изначальные размеры виджета 100*100
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
    fill(clr);
    rect(x, y, w, h); 
    fill(0);
    text(bText, x + w/2 - 10*bText.length()*10, y + h/2);
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
   }
   public ImageWidget(RShape img, float x, float y)  {
     
   }
   public void drawWidget()  {
     fill(100);
     img.transform(x,y+barHeight,w,h+barHeight);
     img.draw();
   }
   public void scale(float scaler)  {
     w = w*scaler;
     h = h*scaler;
     img.scale(scaler);
     if (x + w > width)
       x = width - w;
     if (y + h > height)
       y = height - h;
     if (w > width)
       w = width;
     if (h > height)
       h = height;
   }
   public void move(float tx, float ty)  {
     x += tx;
     y += ty;
     if (x < 0)
       x = 0;
     if (x + w > width)
       x = width - w;
     if (y < 0)
       y = 0;
     if (y + h > height)
       y = height - h;
     img.translate(x,y);
   }
   RShape img;
   float x = 0;
   float y = 0;
   float w = 100;
   float h = 100;
}
