import processing.serial.*;
import org.gamecontrolplus.gui.*;
import org.gamecontrolplus.*;
import net.java.games.input.*;

//USER INTERFACE SYSTEM 
ui_system my_system;
//SETUP VARIABLES
ControlIO control;
Configuration config;
ControlDevice gpad;
Serial my_port;


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
  //String portName = Serial.list()[0];
  //my_port = new Serial(this, portName, 9600);
  
  //Create the UI System==========================================
  my_system = new ui_system(gpad, my_port);
}

void draw() {
  my_system.update();
}

void mouseClicked()
{
  my_system.mouseClick(mouseX, mouseY);
}

void mouseMoved()
{
  my_system.mouseMove(mouseX, mouseY);
}

