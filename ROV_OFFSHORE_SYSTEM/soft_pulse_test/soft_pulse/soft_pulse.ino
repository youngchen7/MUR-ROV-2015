const int cycle_period = 20000;
unsigned long cycle_update = 0;
unsigned long cycle_delta;
int counter = 0;
int t_val[8] = {1100, 1200, 1300, 1400, 1500, 1600, 1700, 1800};

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  for(int p = 2; p < 10; ++p)
  {
    pinMode(p, OUTPUT);
  }
}

void loop() {
  // put your main code here, to run repeatedly:
  while (Serial.available() > 0) {
    Serial.println("Reading serial");
    if(Serial.read() == 'R'){
      Serial.print("Printing Thruster Values: ");
      for(int t = 0; t < 8; ++t)
      {
        Serial.print(t_val[t]);
        Serial.print(" ");
      }
      Serial.println();
    }else{
      int t = Serial.parseInt();
      int val = Serial.parseInt();
      Serial.print("Setting thruster ");   
      Serial.print(t);
      Serial.print(" to ");
      Serial.println(val);
      if (Serial.read() == '\n'){
        t_val[t] = constrain(val, 1100, 1900);      
      }
    }
      
  }
  //UPDATE PULSE
  cycle_delta = micros() - cycle_update;
  if(cycle_delta > cycle_period)
  {
    cycle_update += cycle_delta;
  }else{
    for(int t = 0; t < 8; ++t)
    {
      (cycle_delta < t_val[t]) ? digitalWrite(t+2, HIGH) 
                               : digitalWrite(t+2, LOW);      
    }
  }
}
