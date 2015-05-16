
/*
  UDPSendReceive
 
 This sketch receives UDP message strings, prints them to the serial port
 and sends an "acknowledge" string back to the sender
 
 A Processing sketch is included at the end of file that can be used to send 
 and received messages for testing with a computer.
 
 created 21 Aug 2010
 by Michael Margolis
 
 This code is in the public domain.
 
 */


#include <SPI.h>          // needed for Arduino versions later than 0018
#include <Ethernet.h>
#include <EthernetUdp.h>  // UDP library from: bjoern@cs.stanford.edu 12/30/2008
#include <Servo.h>
#include <Wire.h>
//#include <SoftwareServo.h>


// Enter a MAC address and IP address for your controller below.
// The IP address will be dependent on your local network:
 byte mac[] = {  
  0x98, 0x4F, 0xEE, 0x01, 0x84, 0x1E };
IPAddress ip(192, 168, 11, 255);              //sudo ifconfig eth0 192.168.1.15 netmask 255.255.255.0

unsigned int localPort = 8888;              // local port to listen on

// buffers for receiving and sending data
char packetBuffer[32];  //buffer to hold incoming packet,
char  ReplyBuffer[UDP_TX_PACKET_MAX_SIZE];// = "acknowledged";       // a string to send back

//thruster setups
const int numThruster = 8;

int thrusters[numThruster];
//SoftwareServo myservo[3];
int cameraServo;

//i2c stuff for digispark
const int numI2C = 2;
char i2cBuffer[numI2C];
char i2cReturn[numI2C];
int digispark1 = 9;

//analog sensor set up
const int numSensors = 5;
int sensors[numSensors] = {A0, A1, A2, A3, A4};

//set pin to digital I/O 13
int ledPin = 13;

// An EthernetUDP instance to let us send and receive packets over UDP
EthernetUDP Udp;

//motor stuff
const int cycle_period = 20000;
unsigned long cycle_update = 0;
unsigned long cycle_delta;
unsigned long camera_servo_timeout;
int t_val[8] = {1500, 1500, 1500, 1500, 1500, 1500, 1500, 1500};
int pins[9] = {GPIO_FAST_IO2, GPIO_FAST_IO3, GPIO_FAST_IO4, 
 GPIO_FAST_IO5, GPIO_FAST_IO6, GPIO_FAST_IO9, 
 GPIO_FAST_IO10, GPIO_FAST_IO11, GPIO_FAST_IO12}; 


//main timer stuff
const int main_cycle_period = 15;
unsigned long main_cycle_update = 0;
unsigned long main_cycle_delta;


 void setup() {
  // start the Ethernet and UDP:
  Ethernet.begin(mac,ip);
  Udp.begin(localPort);

  Serial.begin(9600);
  pinMode(2, OUTPUT_FAST);
  pinMode(3, OUTPUT_FAST);
  pinMode(4, OUTPUT_FAST);
  pinMode(5, OUTPUT_FAST);
  pinMode(6, OUTPUT_FAST);
  pinMode(9, OUTPUT_FAST);
  pinMode(10, OUTPUT_FAST);
  pinMode(11, OUTPUT_FAST);
  pinMode(12, OUTPUT_FAST);
  
  pinMode(ledPin, OUTPUT);

  Serial.println("finish arming");

  //i2c setup
  Wire.begin();

  //analog pin as digital pin setup
  for(int j = 0; j < numSensors; j++){
    pinMode(sensors[j], INPUT);
  }



}

void loop() {
  // if there's data available, read a packet

  main_cycle_delta = millis() - main_cycle_update;
  if( main_cycle_delta > main_cycle_period)
  {
    main_cycle_update = millis();

    int packetSize = Udp.parsePacket();
    if(packetSize)
    {
      IPAddress remote = Udp.remoteIP();
     
      Udp.read(packetBuffer,32);
        
         for(int t = 0; t < 8; ++t){
          int signal = 0;
          for(int d = 0; d < 3; ++d){
            signal*=10;
            int counter = 3*t + d;
            int digit = packetBuffer[counter] - '0';
            signal+=digit;
          }

          signal = signal + 1100;
          
          thrusters[t] = constrain(signal, 1100, 1900); 
          
          Serial.print(signal);
          Serial.print(" ");
    
        }

         //Serial.println();

        //camera servo
         //for(int t = 24; t < 28; ++t){
          int signal = 0;
          for(int d = 0; d < 4; ++d){
            signal*=10;
            int counter = 24 + d;
            int digit = packetBuffer[counter] - '0';
            signal+=digit;
          }

          //signal = signal + 1100;
          if (cameraServo != signal) {
            camera_servo_timeout = millis() + 1000;  
          }
          cameraServo = constrain(signal, 700, 2000); 
          
          Serial.print(signal);
          Serial.print(" ");
          
          int ledvalue = packetBuffer[28] - '0';
          if (ledvalue == 0) {
            digitalWrite(ledPin, LOW);
          } else {
            digitalWrite(ledPin, HIGH);
          }
          Serial.print(ledvalue);
          Serial.print(" ");
          

          //Serial.print(char(packetBuffer[j]));  
          //Serial.println();   
        //}
        
        Serial.println();
        // send a reply, to the IP address and port that sent us the packet we received
         Udp.beginPacket(Udp.remoteIP(), Udp.remotePort());
         Udp.write(ReplyBuffer);
         Udp.endPacket();
       }
  }

  //UPDATE PULSE
  cycle_delta = micros() - cycle_update;
  if (cycle_delta > cycle_period) {
    cycle_update = micros();
  } else {
    for (int t = 0; t < 8; ++t) {
      //(cycle_delta < thrusters[t]) ? fastGpioDigitalWrite(pins[t], HIGH) : 
      //                               fastGpioDigitalWrite(pins[t], LOW);
      fastGpioDigitalWrite(pins[t], (cycle_delta < thrusters[t]) ? HIGH : LOW);
    }
    //(cycle_delta < cameraServo) ? fastGpioDigitalWrite(pins[8], HIGH) :
    //                             fastGpioDigitalWrite(pins[8], LOW);
    if (camera_servo_timeout > millis()) {
      fastGpioDigitalWrite(pins[8], (cycle_delta < cameraServo) ? HIGH : LOW);
    }
  }
}


