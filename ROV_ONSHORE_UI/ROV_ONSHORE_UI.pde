import processing.serial.*;
import org.gamecontrolplus.gui.*;
import org.gamecontrolplus.*;
import net.java.games.input.*;
import hypermedia.net.*;


//USER INTERFACE SYSTEM 
ui_system my_system;
//SETUP VARIABLES
ControlIO control;
Configuration config;
ControlDevice gpad;
Serial my_port;
UDP udp;

boolean sketchFullScreen() {
  return true;
}

void setup() {
  size(displayWidth, displayHeight);
  background(255);
  
  // Initialise the ControlIO=====================================
  control = ControlIO.getInstance(this);
  // Find a device that matches the configuration file
  gpad = control.getMatchedDevice("rov_xbox_one");
  if (gpad == null) {
    println("No suitable device configured");
    //System.exit(-1); // End the program NOW!
  }
  
  // Initialise the Serial Port===================================
  for(String s : Serial.list())
  {
    println("Available ports: " + s);
  }
  my_port = new Serial(this, Serial.list()[1], 4800);
  my_port.bufferUntil('\n'); 
  
  udp = new UDP(this, 6000);
  udp.listen(true);
  //Create the UI System==========================================
  my_system = new ui_system(gpad, my_port, udp);
}

void draw() {
  my_system.update();
}

void mouseClicked(MouseEvent event){
  my_system.notify(event);
}

void mouseDragged(MouseEvent event){
    my_system.notify(event);
}

void mouseMoved(MouseEvent event){
    my_system.notify(event);
}

void mousePressed(MouseEvent event){
    my_system.notify(event);
}

void mouseWheel(MouseEvent event){
      my_system.notify(event);
}

void serialEvent(Serial my_port){
  println("Serial event!");
    my_system.serialEvent();
}

void receive(byte[] data)
{
  my_system.receive(data);
}
