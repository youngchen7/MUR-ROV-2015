import java.util.Map;

public class ui_system
{
  //System Constants==========================================================
  private static final int CONFIGURE = 0;
  private static final int OPERATE = 1;
  //System layout=============================================================
  private int bar_percent = 4;
  private int grid_percent = 3;
  private int grid_pixels;
  //System components=========================================================
  private JSONObject data_core;
  private ArrayList<module> core_modules;
  private ArrayList<ui_module> system_modules;
  private ArrayList<ui_module> interface_modules;
  
  private ethernet_module my_ethernet;
  private serial_module my_serial;
  private int mode = CONFIGURE; 
  
  private boolean checkBound(MouseEvent e, ui_module m)
  {
    return e.getX() > m.getPosition()[0]
        && e.getX() < m.getPosition()[0] + m.getSize()[0]
        && e.getY() > m.getPosition()[1]
        && e.getY() < m.getPosition()[1] + m.getSize()[1];
  }
  
  private MouseEvent adjustEvent(MouseEvent e, ui_module m)
  {
    return new MouseEvent(e.getNative(), e.getMillis(), e.getAction(), 
                          e.getModifiers(), e.getX() - m.getPosition()[0], 
                          e.getY() - m.getPosition()[1], e.getButton(), e.getCount());
  }
  
  public ui_system(ControlDevice _control, Serial _port, UDP _udp)
  {
    data_core = new JSONObject();
    core_modules = new ArrayList<module>();
    system_modules = new ArrayList<ui_module>();
    interface_modules = new ArrayList<ui_module>();
    grid_pixels = displayHeight*grid_percent/100;
    
    
    //INITIALIZE CORE MODULES=================================================
    if(_control!=null)
    core_modules.add(new input_module(_control));
    core_modules.add(new thruster_module());
    core_modules.add(new servo_module());
    core_modules.add(new LED_module());
    my_serial = new serial_module(_port);
    //core_modules.add(my_serial);
    my_ethernet = new ethernet_module(_udp);
    core_modules.add(my_ethernet);
    //INITIALIZE SYSTEM MODULES===============================================
    system_modules.add(new ui_viewbar());
    //INITIALIZE INTERFACE MODULES============================================
    interface_modules.add(new ui_controller(25, 25));
    interface_modules.add(new ui_thrusters(775, 25));
    interface_modules.add(new ui_servo(25, 100));
    interface_modules.add(new ui_led(500, 400));
    

  }
  
  void notify(MouseEvent event)
  {
    //Always notify system modules
    //System modules take precedent over ui modules
    for(ui_module m : system_modules)
    {
      if(checkBound(event, m)){
        m.notify(adjustEvent(event, m));
        return;
      }
    }
    //Only update UI modules if operating
    if(mode == OPERATE){
      for(ui_module m : interface_modules)
      {
         if(checkBound(event, m)){
          m.notify(adjustEvent(event, m));
          return;
         }
      }
    //Otherwise, enable module reconfiguration
    }else{
    }
  }
  
  public void serialEvent()
  {
    my_serial.serialEvent();
  }
  
  public void receive(byte[] data)
  {
    my_ethernet.receive(data);
  }
  
  public void update()
  {
    background(255);
    if(mode==CONFIGURE)
      updateGrid();

     //Update each module
     for(module m : core_modules)
     {
       updateModule(m);
     }
     for(ui_module m : system_modules)
     {
       updateInterfaceModule(m);
     }
     //If running in configuration mode, snap interface modules
     //To nearest grid points
     for(ui_module m : interface_modules)
     {
       if(mode == CONFIGURE){
         snapGrid(m);
       }
       updateInterfaceModule(m);
     }
  }
  
  private void updateModule(module m)
  {
     String[] readFields = m.getReadFields();
     String[] writeFields = m.getWriteFields();
     //create JSON with requested fields
     JSONObject requestedRead = new JSONObject();
     for(String field : readFields)
     {
       if(!data_core.hasKey(field)){
          println("Module requested nonexistent read field " + field + ", update skipped");
          return;
       }
        requestedRead.setJSONObject(field, data_core.getJSONObject(field)); 
     }
     JSONObject requestedWrite = m.update(requestedRead);
     for(String field : writeFields)
     {
       data_core.setJSONObject(field, requestedWrite.getJSONObject(field));  
     }
   }  
   
   private void updateInterfaceModule(ui_module m)
   {
     pushMatrix();
     translate(m.getPosition()[0], m.getPosition()[1]);
     updateModule(m);
     popMatrix();
    }
   
  private void snapGrid(ui_module m){
    m.setPosition(snapGrid(m.getPosition()[0]), snapGrid(m.getPosition()[1]));
    m.setSize(snapGrid(m.getSize()[0]), snapGrid(m.getSize()[1]));
  }
  
  private int snapGrid(int val){
    val+=grid_pixels/2;
    val/=grid_pixels;
    val*=grid_pixels;
    return val;
  }
  
  private void updateGrid()
  {
    background(255);
    //Generate grid lines (if unlocked)
    stroke(125);
    strokeWeight(1);
    for(int i = 0; i < displayHeight; i+=grid_pixels)
    {
      line(0, i, displayWidth, i);
    }
    for(int i = 0; i < displayWidth; i+=grid_pixels)
    {
      line(i, 0, i, displayHeight);
    }
  }
}
