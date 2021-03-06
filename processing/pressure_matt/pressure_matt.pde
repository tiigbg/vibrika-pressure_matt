import processing.serial.*;
import controlP5.*;

boolean debug =false;
boolean fakeData = false;

final int nrOfPointsWidth = 17;
final int nrOfPointsHeight = 17;
final int valueArraySize = nrOfPointsWidth * nrOfPointsHeight;
int margin = 50;

int blockWidth;
int blockHeight;

int textSize = 25;

int sensorValues[][] = new int[nrOfPointsHeight][nrOfPointsWidth];

Serial myPort;  // Create object from Serial class

//Wekinator communication (over OSC)
import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress dest;
WekinatorProxy wp;

int classifier = 0;

ControlP5 cp5;

void setup()
{
  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this,12000);
  dest = new NetAddress("127.0.0.1",6448);
  wp = new WekinatorProxy(oscP5);

  fullScreen();
  if(!fakeData)
    noLoop();

  background(0);
  textSize(textSize);

  if(!fakeData)
  {
    int n = 0;
    String[] availablePorts = Serial.list();
    while(availablePorts.length == 0)
    {
      println("No devices found to connect to via serial. Please reconnect.");
      delay(1000);
      availablePorts = Serial.list();
    }
    println("Available ports:");
    printArray(availablePorts);
    String portName = availablePorts[availablePorts.length-1];
    myPort = new Serial(this, portName, 115200);
    myPort.bufferUntil('\n');
  }


  blockWidth = min((displayWidth-2*margin)/nrOfPointsWidth, (displayHeight-2*margin)/nrOfPointsHeight);
  blockHeight = blockWidth;

  println("blockWidth="+blockWidth);
  println("blockHeight="+blockHeight);



  println("Setup done.");
  println("-----------");
}

void createControls() {
  cp5 = new ControlP5(this);

  // cp5.addToggle("isRecording")
  //    .setPosition(10,20)
  //    .setSize(75,20)
  //    .setValue(true)
  //    .setCaptionLabel("record/run")
  //    .setMode(ControlP5.SWITCH)
  //    ;

  //  cp5.addButton("buttonClearTrain")
  //    .setValue(0)
  //    .setCaptionLabel("Clear training examples")
  //    .setPosition(10,90)
  //    .setSize(120,19)
  //    ;

    cp5.addButton("buttonRecord")
     .setValue(0)
     .setCaptionLabel("Record")
     .setPosition(10,60)
     .setSize(120,19)
     ;

  //  cp5.addButton("buttonClearTest")
  //    .setValue(0)
  //    .setCaptionLabel("Clear test examples")
  //    .setPosition(10,150)
  //    .setSize(120,19)
  //    ;

  //  cp5.addButton("drawDecision")
  //    .setBroadcast(false)
  //    .setValue(0)
  //    .setCaptionLabel("Draw decision boundaries")
  //    .setPosition(10,120)
  //    .setSize(120,19)
  //    .setBroadcast(true)
  //    ;

}

void draw()
{
  textSize(textSize);//Reset if was changed at some point
  pushMatrix();
  translate(margin, margin);
  background(255);
  for(int y = 0; y< nrOfPointsHeight;y++)
  {
    text(""+(y+1), -margin,textSize+y*blockHeight);
    for(int x = 0; x< nrOfPointsWidth;x++)
    {
      if(y == 0){
        text(""+(x+1), x*blockWidth,-margin/2);
      }

      int value = 0;
      if(!fakeData)
      {
        //row THEN column!
        value = sensorValues[y][x];
      }
      else
      {
        value = int(random(1024));
      }
      color valueColor = getColor(value);

      //draw box
      fill(valueColor);
      rect(x*blockWidth,y*blockHeight,blockWidth,blockHeight);
      // write value as text in contrasting color inside box
      fill((brightness(valueColor)+128)%255);
      text(""+value, x*blockWidth,textSize+y*blockHeight);
    }
  }
  if(fakeData)
    delay(100);

  popMatrix();
  textSize(textSize*4);
  text(""+classifier, nrOfPointsWidth*blockWidth+margin,(height+textSize)/2);
}

void oscEvent(OscMessage theOscMessage) {
  // synchronized(locking) {
  float c = wp.getFloatValue(theOscMessage);
  classifier = (int) c;
  // println("RECEIVED BUT NOT WAITING: " + c);
}

void serialEvent(Serial p){
  try{
    String inputString = p.readString();
    if(debug)
      println("inputString="+inputString);
    String inputNrs[] = split(inputString, ';');
    for(int y = 0; y< nrOfPointsHeight;y++)
    {
      for(int x = 0; x< nrOfPointsWidth;x++)
      {
        int index = y*nrOfPointsWidth + x;
        if(index >= inputNrs.length)
        {
          println("Input did not contain enough values!");
          return;
        }
        sensorValues[y][x] = Integer.parseInt(trim(inputNrs[index]));
      }
    }

    //Also print if we got some extra string content
    // if(inputNrs.length > nrOfPointsWidth * nrOfPointsHeight){
    //   println("extra info: " + inputNrs[nrOfPointsWidth * nrOfPointsHeight]);
    // }
    redraw();
    sendOsc();
  }
  catch(RuntimeException e){
    e.printStackTrace();
  }
}

void sendOsc() {
  OscMessage msg = new OscMessage("/wek/inputs");
  for(int y = 0; y< nrOfPointsHeight;y++)
    {
      for(int x = 0; x< nrOfPointsWidth;x++)
      {
        msg.add((float)sensorValues[y][x]);
      }
  }
  oscP5.send(msg, dest);
}

// here we can define what color scale we want to use
// to represent the data
color getColor(int value)
{
  value = min(max(value, 500),1023);
  int x = int(map(value, 500, 1023, 0, 255));

  //grayscale
  //return color(x);

  //red-green scale
  return color(x,0, 255-x);
}
