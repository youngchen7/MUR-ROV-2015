//MODULE BASE
public abstract class module
{
  public module()
  {
  }

  public abstract String[] getReadFields();

  public abstract String[] getWriteFields();

  public abstract JSONObject update(JSONObject data);

}

//UI MODULE BASE
public abstract class ui_module extends module
{
  private int x_pos, y_pos, m_width, m_height;

  //Within each module, use relative coordinate systems.
  //Use push/pop matrix in the UI System loop to move to each module's coordinate system
  //Modules will respond to filtered mouse events: click, enter, exit, move, dragstart, and dragend.
  //It is the UI system's job to filter and notify the module of these events. All events will be translated to the module's relative coordinate system
  public ui_module()
  {
    x_pos = 0;
    y_pos = 0;
    m_width = 0;
    m_height = 0;
  }

  public void notify(MouseEvent event) {}    
  
  public void setPosition(int x, int y)
  {
    x_pos = x;
    y_pos = y;
  }
  
  public int[] getPosition()
  {
    int[] pos = {x_pos, y_pos};
    return pos;
  }

  public void setSize(int w, int h)
  {
    m_width = w;
    m_height = h;
  }
  
  public int[] getSize()
  {
    int[] size = {m_width, m_height};
    return size;
  }



}

//THRUSTER CALCULATION MODULE==================================================================
//Left stick horizontal planer movement. Right stick pitch and roll. Triggers yaw. 
public class thruster_module extends module
{
  public thruster_module(){
  }
  
  public String[] getWriteFields()
  {
    String[] writeFields = {"THRUSTER_DATA"};
    return writeFields;
  }
  
  public String[] getReadFields()
  {
    String[] readFields = {"CONTROLLER_XBOX_ONE"};
    return readFields;
  }
  
  private float t_map(float val)
  {
    return ((val+1.0)*400.0);
  }
  
  public JSONObject update(JSONObject data)
  {
    JSONObject writeData = new JSONObject();
    JSONObject t_data = new JSONObject();
    JSONObject c_data = data.getJSONObject("CONTROLLER_XBOX_ONE");
    float[] t = {0, 0, 0, 0, 0, 0, 0, 0};
    //FORWARD/BACK (-1.0 forward, 1.0 backward)
    float l_y = c_data.getFloat("LSTICKY");
    t[0] += l_y*-1;
    t[1] += l_y*-1;
    t[2] += l_y;
    t[3] += l_y;
    //LEFT/RIGHT (-1.0 left, 1.0 right)
    float l_x = c_data.getFloat("LSTICKX");
    t[0] += l_x;
    t[1] += l_x*-1;
    t[2] += l_x*-1;
    t[3] += l_x;
    //ROTATE (-1.0 cw, 1.0 ccw)
    float trig = c_data.getFloat("TRIGGER");
    t[0] += trig;
    t[1] += trig*-1;
    t[2] += trig;
    t[3] += trig*-1;
    //VERTICALS (1.0 up, -1.0 down) pitch
    float r_y = c_data.getFloat("RSTICKY");
    t[4] += r_y*-1;
    t[5] += r_y*-1;
    t[6] += r_y*1;
    t[7] += r_y*1;
    //VERTICALS (1.0 up, -1.0 down) roll
    float r_x = c_data.getFloat("RSTICKX");
    t[4] += r_x*-1;
    t[5] += r_x*1;
    t[6] += r_x*1;
    t[7] += r_x*-1;
    //UP/DOWN (1.0 up, -1.0 down) strictly z movement
    boolean z_up = c_data.getBoolean("RSHOULDER");
    boolean z_down = c_data.getBoolean("LSHOULDER");
    float z_thrust = 0;
    if(z_up) z_thrust+=1;
    if(z_down) z_thrust-=1;
    t[4] += z_thrust*1;
    t[5] += z_thrust*1;
    t[6] += z_thrust*1;
    t[7] += z_thrust*1;
    

    //FIND MAX, RESCALE, AND STORE
    //Horizontal Thrusters
    float t_max = 0;
    for(int i = 0; i < 4; i++){
      if(t_max < abs(t[i]))
        t_max = abs(t[i]);
    }
    for(int i = 0; i < 4; ++i){
      if(t_max>1.0)
        t[i]/=t_max;
      t_data.setInt("THRUSTER_" + i, (int)t_map(t[i]));
    }
    //Vertical Thrusters
    for(int i = 4; i < 8; i++){
      if(t_max < abs(t[i]))
        t_max = abs(t[i]);
    }
    for(int i = 4; i < 8; ++i){
      if(t_max>1.0)
        t[i]/=t_max;
      t_data.setInt("THRUSTER_" + i, (int)t_map(t[i]));
    }
    writeData.setJSONObject("THRUSTER_DATA", t_data);
    return writeData;
  }
}
  
//SERVO CACULATION MODULE
public class servo_module extends module
{  
  //min 544, max 2400
  private int default_angle; 
  public servo_module()
  {
    default_angle = 1472;
  }

  public String[] getReadFields(){
    String[] readFields = {"CONTROLLER_XBOX_ONE"};
    return readFields;    
  }

  public String[] getWriteFields(){
    String[] writeFields = {"SERVO_DATA"};
    return writeFields;
  }

  public JSONObject update(JSONObject data){
    JSONObject writeData = new JSONObject();
    JSONObject s_data = new JSONObject();
    JSONObject c_data = data.getJSONObject("CONTROLLER_XBOX_ONE");
    //Read controller values
    boolean a_val = c_data.getBoolean("A");
    boolean b_val = c_data.getBoolean("B");
    boolean x_val = c_data.getBoolean("X");
    if(a_val) default_angle += 10; 
    if(b_val) default_angle -= 10;
    if(default_angle > 2400) default_angle = 2400;
    if(default_angle < 544) default_angle = 544;
    if(x_val) default_angle = 1472; 
    s_data.setInt("SERVO_VAL", default_angle);
    writeData.setJSONObject("SERVO_DATA", s_data);
    return writeData;
  }

}

//LED Input Module
public class LED_module extends module
{
  boolean p_y_val = false;
  private boolean on;
  public LED_module()
  {
    on = true;
  }

  public String[] getReadFields(){
    String[] readFields = {"CONTROLLER_XBOX_ONE"};
    return readFields;  
  }

  public String[] getWriteFields(){
     String[] writeFields = {"LED_DATA"};
    return writeFields;
  }

  public JSONObject update(JSONObject data){
    JSONObject writeData = new JSONObject();
    JSONObject LED_data = new JSONObject();
    JSONObject c_data = data.getJSONObject("CONTROLLER_XBOX_ONE");
    //Read controller values
    boolean y_val = c_data.getBoolean("Y");
    if(!p_y_val && y_val) on = !on;
    p_y_val = y_val;
    LED_data.setBoolean("LED_VAL", on);
    writeData.setJSONObject("LED_DATA", LED_data);
    return writeData;
  }

}

//XBOX MODULE INPUT MODULE======================================================================
public class input_module extends module
{
  private ControlDevice controller;


  public input_module(ControlDevice c)
  {
    controller = c;
  }
  public String[] getWriteFields()
  {
    String[] writeFields = {"CONTROLLER_XBOX_ONE"};
    return writeFields;
 
  }
  public String[] getReadFields()
  {
    return new String[0];
  }
  public JSONObject update(JSONObject data)
  {
    JSONObject writeData = new JSONObject();
    
    JSONObject controller_data = new JSONObject();
    controller_data.setFloat("LSTICKX", controller.getSlider("LStickX").getValue() );
    controller_data.setFloat("LSTICKY", controller.getSlider("LStickY").getValue() );
    controller_data.setFloat("RSTICKX", controller.getSlider("RStickX").getValue() );
    controller_data.setFloat("RSTICKY", controller.getSlider("RStickY").getValue() );
    controller_data.setFloat("TRIGGER", controller.getSlider("Trigger").getValue() );
    controller_data.setFloat("DPAD", controller.getHat("DPad").getValue() );
    controller_data.setBoolean("LSTICK", controller.getButton("LStick").pressed());
    controller_data.setBoolean("RSTICK", controller.getButton("RStick").pressed());
    controller_data.setBoolean("LSHOULDER", controller.getButton("LShoulder").pressed());
    controller_data.setBoolean("RSHOULDER", controller.getButton("RShoulder").pressed());
    controller_data.setBoolean("WINDOW", controller.getButton("Window").pressed());
    controller_data.setBoolean("MENU", controller.getButton("Menu").pressed());
    controller_data.setBoolean("A", controller.getButton("A").pressed());
    controller_data.setBoolean("B", controller.getButton("B").pressed());
    controller_data.setBoolean("X", controller.getButton("X").pressed());
    controller_data.setBoolean("Y", controller.getButton("Y").pressed());    
    writeData.setJSONObject("CONTROLLER_XBOX_ONE", controller_data);
    return writeData;
  }
}

//SERIAL INTERFACE MODULE====================================================================
public class serial_module extends module
{
  private Serial s_port;
  private String val;
  private boolean firstContact;
  private int[] t_data = {400, 400, 400, 400, 400, 400, 400, 400};
  
  public serial_module(Serial port)
  {
    s_port = port;
  }
  
  void serialEvent() {
    //put the incoming data into a String - 
    //the '\n' is our end delimiter indicating the end of a complete packet
    val = s_port.readStringUntil('\n');
    //make sure our data isn't empty before continuing
    if (val != null) {
      //trim whitespace and formatting characters (like carriage return)
      val = trim(val);
      println(val);
    
      //look for our 'A' string to start the handshake
      //if it's there, clear the buffer, and send a request for data
      if (firstContact == false) {
        if (val.equals("A")) {
          s_port.clear();
          firstContact = true;
          s_port.write("A");
          println("contact");
        }
      }
      else if(val.charAt(0) == 'R' ){ //if we've already established contact, keep getting and parsing data
        String send = "";
        for(int i = 0; i < 8; ++i)
        {
          send += nf(t_data[i], 3);
        }
        println("Serial sending: " + send);
        s_port.write("B" + send );        
    
        // when you've parsed the data you have, ask for more:
      }
    }
  }

  public String[] getWriteFields(){
    return new String[0];
  }
  
  public String[] getReadFields()
  {
    String[] readFields = {"THRUSTER_DATA"};
    return readFields;
  } 
  
  public JSONObject update(JSONObject data)
  {
    JSONObject thrusters = data.getJSONObject("THRUSTER_DATA");
    for(int i = 0; i < 8; ++i)
    {  
      t_data[i] = thrusters.getInt("THRUSTER_" + i);
    }
    return null;
  }
  
}

//SYSTEM ETHERNET MODULE=====================================================================
public class ethernet_module extends module
{
  private UDP udp;
  private int[] t_data = {400, 400, 400, 400, 400, 400, 400, 400};
  private String ip = "192.168.11.255";
  private int port = 8888;

  public ethernet_module(UDP _udp)
  {
    udp = _udp;
  }
  
  public ethernet_module(UDP _udp, String _ip, int _port)
  {
    udp = _udp;
    ip = _ip;
    port = _port; 
  }
  
  void receive(byte[] data)
  {
   for(int i=0; i < data.length; i++) 
     print(char(data[i]));  
   println(); 
   String send = "";
   for(int i = 0; i < 8; ++i)
     send += nf(t_data[i], 3);
   println("Serial sending: " + send);
   udp.send(send, ip, port);          
}

  
  public String[] getWriteFields(){
    return new String[0];
  }
  
  public String[] getReadFields()
  {
    String[] readFields = {"THRUSTER_DATA", "SERVO_DATA", "LED_DATA"};
    return readFields;
  } 
  
  public JSONObject update(JSONObject data)
  {
    JSONObject thrusters = data.getJSONObject("THRUSTER_DATA");
    JSONObject servos = data.getJSONObject("SERVO_DATA");
    JSONObject leds = data.getJSONObject("LED_DATA");
    int s_data = servos.getInt("SERVO_VAL");
    boolean led_data = leds.getBoolean("LED_VAL");
    for(int i = 0; i < 8; ++i)
    {  
      t_data[i] = thrusters.getInt("THRUSTER_" + i);
    }
    
   String send = "";
   for(int i = 0; i < 8; ++i)
     send += nf(t_data[i], 3);
   send += nf(s_data, 4);
   if(led_data) send += "1"; 
   else send += "0";
   
   println("Serial sending: " + send);
   udp.send(send, ip, port);     
   
    return null;
  }
}

//SYSTEM UI==================================================================================
public class ui_viewbar extends ui_module
{
  private int bar_percent = 4;
  private int title_percent = 1;
  private int profiles_percent = 10;
  private int controls_percent = 70;
  private int margin = 8;


  public ui_viewbar()
  {
    super.setPosition(0, displayHeight*(100-bar_percent)/100);
    super.setSize(displayWidth, displayHeight*bar_percent/100);
  }

  public String[] getWriteFields()
  {
    return new String[0];
  }

  public String[] getReadFields()
  {
    return new String[0];
  }
  
  public void notify(MouseEvent event){
    println("Viewbar UI recieved event " + event.toString());
  }

  public JSONObject update(JSONObject data)
  {
    noStroke();
    fill(255, 200);
    rectMode(CORNER);
    rect(0, 0, this.getSize()[0], this.getSize()[1]);
    stroke(0);
    strokeWeight(3);
    line(0, 0, this.getSize()[0], 0);
    fill(0);
    textSize(32);
    textAlign(LEFT, CENTER);
    text("//ROV UI", this.getSize()[0]*title_percent/100, this.getSize()[1]/2);

    text("//[PROFILES]", this.getSize()[0]*profiles_percent/100, this.getSize()[1]/2);
    text("//[CONTROLS]", this.getSize()[0]*controls_percent/100, this.getSize()[1]/2);

    return null;
  }
}


//CONTROLLER UI===========================================================================
public class ui_controller extends ui_module
{
  PShape graphic;
  String[] buttons = {"LSHOULDER", "RSHOULDER", "WINDOW", "MENU", "A", "B", "X", "Y", "LSTICK", "RSTICK"};

  public ui_controller(int x, int y, int w, int h){
    super.setPosition(x, y);
    super.setSize(w, h);
    graphic = loadShape("Data/XBOX_Controller-CB2.svg");
    graphic.disableStyle();
  }
  
  public ui_controller(int x, int y){
    this(x, y, 700, 300);
  }
  
  public ui_controller(){
    this(0, 0);
  }
  
  public String[] getWriteFields(){
    return new String[0];
  }
  
  public String[] getReadFields()
  {
    String[] readFields = {"CONTROLLER_XBOX_ONE"};
    return readFields;
  }
  
  public void notify(MouseEvent event)
  {
    println("Controller UI recieved event " + event.toString());
  }
  
  public JSONObject update(JSONObject data)
  {
    
    JSONObject control_data = data.getJSONObject("CONTROLLER_XBOX_ONE");
    int size_x = this.getSize()[0];
    int center_x = size_x/2;
    int size_y = this.getSize()[1];
    int center_y = size_y/2;
    int size_min = (size_x < size_y) ? size_x : size_y;
    int center_min = size_min/2;
    color blue = color(51, 153, 255);
    color gray = color(102, 102, 102);
   
    stroke(0);
    strokeWeight(3);
    fill(255,200);    
    rectMode(CENTER);
    rect(size_x/2, size_y/2, this.getSize()[0], this.getSize()[1]);
    stroke(gray, 100);
    shapeMode(CENTER);
    shape(graphic, center_x, center_y, size_min, size_min*2/3);
    strokeWeight(1);
    fill(blue, 150);
    //UPDATE LEFT JOYSTICK
    graphic.getChild("LSTICKF").resetMatrix();
    graphic.getChild("LSTICKF").translate(control_data.getFloat("LSTICKX")*size_min/30, control_data.getFloat("LSTICKY")*size_min/25);
    shape(graphic.getChild("LSTICKF"), center_x, center_y, size_min, size_min*2/3);
    //UPDATE RIGHT JOYSTICK
    graphic.getChild("RSTICKF").resetMatrix();
    graphic.getChild("RSTICKF").translate(control_data.getFloat("RSTICKX")*size_min/30, control_data.getFloat("RSTICKY")*size_min/25);
    shape(graphic.getChild("RSTICKF"), center_x, center_y, size_min, size_min*2/3);
    //UPDATE BUTTONS
    for(String b : buttons){
      if(control_data.getBoolean(b))
        shape(graphic.getChild(b), center_x, center_y, size_min, size_min*2/3);
    }
    //UPDATE TRIGGER
    fill(255, 200);
    strokeWeight(3);
    stroke(gray, 100);
    rect(center_x*0.97, center_y/3, size_min/2, size_min/30);
    noStroke();
    fill(blue, 150);
    rect(center_x*0.97 - control_data.getFloat("TRIGGER")*size_min*0.22, center_y/3, size_min/15, size_min/30);
    //UPDATE DPAD
    boolean[] dpad = {false, false, false, false};
    int t_val = (int)control_data.getFloat("DPAD");
    if(t_val<=0){
    }else if(t_val%2==0){
      dpad[t_val%8/2] = true;
    }else{
      dpad[(t_val-1)/2] = true;
      dpad[(t_val+1)%8/2] = true;
    }
    if(dpad[1])
      rect(center_x - size_min*0.13, center_y - size_min*0.014, size_min/30, size_min/30, size_min/100); //0
    if(dpad[2])
      rect(center_x - size_min*0.09, center_y + size_min*0.025, size_min/30, size_min/30, size_min/100); //1
    if(dpad[3])
      rect(center_x - size_min*0.13, center_y + size_min*0.064, size_min/30, size_min/30, size_min/100); //2
    if(dpad[0])
      rect(center_x - size_min*0.17, center_y + size_min*0.025, size_min/30, size_min/30, size_min/100); //3
    return null;
  }
    
}

//THRUSTER UI===================================================================================================
public class ui_thrusters extends ui_module
{
  public ui_thrusters(int x, int y, int w, int h){
    super.setPosition(x, y);
    super.setSize(w, h);
  }
  
  public ui_thrusters(int x, int y){
    this(x, y, 400, 400);
  }
  
  public ui_thrusters(){
    this(0, 0);
  }
  
  public String[] getWriteFields(){
    return new String[0];
  }
  
  public String[] getReadFields()
  {
    String[] readFields = {"THRUSTER_DATA"};
    return readFields;
  } 
  
  public JSONObject update(JSONObject data)
  {
    JSONObject thruster_data = data.getJSONObject("THRUSTER_DATA"); 
    int size_x = this.getSize()[0];
    int center_x = size_x/2;
    int size_y = this.getSize()[1];
    int center_y = size_y/2;
    int size_min = (size_x < size_y) ? size_x : size_y;
    int center_min = size_min/2;
    color blue = color(51, 153, 255);
    color gray = color(102, 102, 102);
    
    rotate(radians(180));
    translate(-2*center_x, -2*center_y);
    //translate(-center_x/2, -center_y/2);

    
    stroke(0);
    strokeWeight(3);
    fill(255,200);
    rectMode(CENTER);
    rect(size_x/2, size_y/2, this.getSize()[0], this.getSize()[1]);
    float[][] coordinates = {{size_min/4, size_min/4}, {size_min*3/4, size_min/4}, { size_min*3/4, size_min*3/4}, {size_min/4, size_min*3/4},
                           {size_min*0.4, size_min*0.45}, {size_min*0.6, size_min*0.45}, {size_min*0.6, size_min*0.55}, {size_min*0.4, size_min*0.55}};
    int[] angles = {210, 150, 30, -30};
    for(int i = 0; i < 4; ++i)
    {
      pushMatrix();
        translate(coordinates[i][0], coordinates[i][1]);
        rotate(radians(angles[i]));
        rect(0, 0, size_min/12, size_min/8);
        pushStyle();
          noStroke();
          fill(blue, 150);
          rect(0, (thruster_data.getInt("THRUSTER_" + i)-400)*(size_min/9)/400, size_min/12, size_min/18);
        popStyle();
      popMatrix();  
    }
    
    for(int i = 4; i < 8; ++i)
    {
      pushMatrix();
        translate(coordinates[i][0], coordinates[i][1]);
        ellipse(0, 0, size_min/12, size_min/12);
        pushStyle();
          noStroke();
          fill(blue, 150);
          ellipse(0, 0, size_min/12 + (thruster_data.getInt("THRUSTER_" + i)-400)*(size_min/15)/400,
                        size_min/12 + (thruster_data.getInt("THRUSTER_" + i)-400)*(size_min/15)/400);
        popStyle();
      popMatrix();
    }
    
    return null;
  }
}

//SERVO UI===================================================================================================
public class ui_servo extends ui_module
{
  public ui_servo(int x, int y, int w, int h){
    super.setPosition(x, y);
    super.setSize(w, h);
  }
  
  public ui_servo(int x, int y){
    this(x, y, 200, 200);
  }
  
  public ui_servo(){
    this(0, 0);
  }
  
  public String[] getWriteFields(){
    return new String[0];
  }
  
  public String[] getReadFields()
  {
    String[] readFields = {"SERVO_DATA"};
    return readFields;
  } 
  
   public JSONObject update(JSONObject data)
  {
    int size_x = this.getSize()[0];
    int center_x = size_x/2;
    int size_y = this.getSize()[1];
    int center_y = size_y/2;
    stroke(0);
    strokeWeight(3);
    fill(255,200);
    rectMode(CENTER);
    rect(size_x/2, size_y/2, this.getSize()[0], this.getSize()[1]);
    JSONObject servo_data = data.getJSONObject("SERVO_DATA"); 
    int servo_val = servo_data.getInt("SERVO_VAL");
    float degrees = (servo_val-544)/10.3;
    fill(50);
    textMode(CENTER);
    text(degrees, center_x-60, center_y-5);
    
    return null;
  }
}

//LED UI===================================================================================================
public class ui_led extends ui_module
{
  public ui_led(int x, int y, int w, int h){
    super.setPosition(x, y);
    super.setSize(w, h);
  }
  
  public ui_led(int x, int y){
    this(x, y, 200, 200);
  }
  
  public ui_led(){
    this(0, 0);
  }
  
  public String[] getWriteFields(){
    return new String[0];
  }
  
  public String[] getReadFields()
  {
    String[] readFields = {"LED_DATA"};
    return readFields;
  } 
  
   public JSONObject update(JSONObject data)
  {
    int size_x = this.getSize()[0];
    int center_x = size_x/2;
    int size_y = this.getSize()[1];
    int center_y = size_y/2;
    stroke(0);
    strokeWeight(3);
    fill(255,200);
    rectMode(CENTER);
    rect(size_x/2, size_y/2, this.getSize()[0], this.getSize()[1]);
    JSONObject LED_data = data.getJSONObject("LED_DATA"); 
    boolean LED_value = LED_data.getBoolean("LED_VAL");
    String message;
    if(LED_value) message = "LED ON";
    else message = "LED OFF";
    fill(50);
    textMode(CENTER);
    text(message, center_x-60, center_y-5);
    
    return null;
  }
}

