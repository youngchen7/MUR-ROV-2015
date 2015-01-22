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
  private int mode = OPERATE; 

  
  public ui_system(ControlDevice _control, Serial _port)
  {
    data_core = new JSONObject();
    core_modules = new ArrayList<module>();
    system_modules = new ArrayList<ui_module>();
    interface_modules = new ArrayList<ui_module>();
    grid_pixels = displayHeight*grid_percent/100;

    
    //INITIALIZE CORE MODULES=================================================
    if(_control!=null)
    core_modules.add(new input_module(_control));
    //INITIALIZE SYSTEM MODULES===============================================
    system_modules.add(new ui_viewbar());
    //INITIALIZE INTERFACE MODULES============================================
        
  }
  
  public void mouseClick(int x, int y)
  {
    if(mouseButton == LEFT)
    mode = OPERATE;
    else if(mouseButton == RIGHT)
    mode = CONFIGURE;
  }
  public void mouseMove(int x, int y)
  {
  }
  public void mouseDragStart(int x, int y)
  {
  }
  public void mouseDragEnd(int x, int y)
  {
  }  
  public void mouseDrag(int x, int y)
  {
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
     for(ui_module m : interface_modules)
     {
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

  
  /*private void printInputDebug()
  {
    println("Debugging User Input:");
    println("\t Joystick[ LX | LY | RX | RY ] \t Trigger[  Z  ] \t Buttons[LJ|RJ|LS|RS|W|M|A|B|X|Y| DPAD ]");
    print("\t         [" + nfs(LStickX, 1, 1)  + "|" + nfs(LStickY, 1, 1)  + "|" + nfs(RStickX, 1, 1)  + "|" + nfs(RStickY, 1, 1)  + "]"); 
    print("\t             [" + nfs(Trigger, 1, 2) + "]");
    print("\t\t        [ " + LStick + "| " + RStick + "| " + LShoulder + "| " + RShoulder + "|" + Window + "|" + Menu);
    println("|" + A + "|" + B + "|" + X + "|" + Y + "| " + DPad + "  ]") ;
  }*/
  

  
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
