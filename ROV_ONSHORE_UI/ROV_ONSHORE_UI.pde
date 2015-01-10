import org.gamecontrolplus.gui.*;
import org.gamecontrolplus.*;
import net.java.games.input.*;

ControlIO control;
Configuration config;
ControlDevice gpad;
//User Input Fields
float LStickX, LStickY, RStickY, RStickX, Trigger, DPad;
boolean LShoulder, RShoulder, Window, Menu, A, B, X, Y;


boolean sketchFullScreen() {
  return true;
}

void pollUserInput()
{
  LStickX = gpad.getSlider("LStickX").getValue();
  LStickY = gpad.getSlider("LStickY").getValue();
  RStickX = gpad.getSlider("RStickX").getValue();
  RStickY = gpad.getSlider("RStickY").getValue();
  Trigger = gpad.getSlider("Trigger").getValue();
  DPad = gpad.getHat("DPad").getValue();
  LShoulder = gpad.getButton("LShoulder").pressed();
  RShoulder = gpad.getButton("RShoulder").pressed();
  Window = gpad.getButton("Window").pressed();
  Menu = gpad.getButton("Menu").pressed();
  A = gpad.getButton("A").pressed();
  B = gpad.getButton("B").pressed();
  X = gpad.getButton("X").pressed();
  Y = gpad.getButton("Y").pressed();
  
}

void printInputDebug()
{
  println("Debugging User Input:");
  println("\t Joystick[ LX | LY | RX | RY ] \t Trigger[  Z  ] \t Buttons[ LS  | RS  | W   |  M  |  A  |  B  |  X  |  Y  | DPAD ]");
  print("\t         [" + nfs(LStickX, 1, 1)  + "|" + nfs(LStickY, 1, 1)  + "|" + nfs(RStickX, 1, 1)  + "|" + nfs(RStickY, 1, 1)  + "]"); 
  print("\t                  [" + nfs(Trigger, 1, 2) + "]");
  println("\t        [" + LShoulder + "|" + RShoulder + "|" + Window + "|" + Menu + "|" + A + "|" + B + "|" + X + "|" + Y + "|" + DPad + "]") ; 
}
void drawInputDebug(int x, int y)
{
    
}  

public void setup() {
  size(displayWidth, displayHeight);
  background(255);
  // Initialise the ControlIO
  control = ControlIO.getInstance(this);
  // Find a device that matches the configuration file
  gpad = control.getMatchedDevice("rov_xbox_one");
  if (gpad == null) {
    println("No suitable device configured");
    System.exit(-1); // End the program NOW!
  }
}

public void draw(){
  pollUserInput();
  printInputDebug();
}



