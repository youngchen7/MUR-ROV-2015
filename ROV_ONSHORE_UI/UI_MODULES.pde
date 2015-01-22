public abstract class module
{
  public module()
  {
  }

  public abstract String[] getReadFields();

  public abstract String[] getWriteFields();

  public abstract JSONObject update(JSONObject data);

}
public abstract class ui_module extends module
{
  private int x_pos, y_pos, m_width, m_height;

  //Within each module, use relative coordinate systems.
  //Use push/pop matrix in the UI System loop to move to each module's coordinate system
  //Modules will respond to filtered mouse events: click, enter, exit, move, dragstart, and dragend.
  //It is the UI system's job to filter and notify the module of these events. All events will be translated to the module's relative coordinate system
  public ui_module()
  {
  }

  public void mouseClick(int x, int y)
  {

  }
  public void mouseEnter(int x, int y)
  {
  }
  public void mouseExit(int x, int y)
  {
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

  public JSONObject update(JSONObject data)
  {
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
