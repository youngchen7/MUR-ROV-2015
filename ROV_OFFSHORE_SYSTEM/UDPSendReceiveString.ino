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

// Enter a MAC address and IP address for your controller below.
// The IP address will be dependent on your local network:
byte mac[] = {  
  0x98, 0x4F, 0xEE, 0x01, 0x84, 0x1E };
IPAddress ip(192, 168, 1, 15);              //sudo ifconfig eth0 192.168.1.25 netmask 255.255.255.0

unsigned int localPort = 8888;              // local port to listen on

// buffers for receiving and sending data
char packetBuffer[UDP_TX_PACKET_MAX_SIZE];  //buffer to hold incoming packet,
char  ReplyBuffer[UDP_TX_PACKET_MAX_SIZE];// = "acknowledged";       // a string to send back

//thruster setups
const int numThruster = 8;

byte thrusterPin12 = 12;
byte thrusterPin11 = 11;
byte thrusterPin10 = 10;
byte thrusterPin9 = 9;
byte thrusterPin8 = 8;
byte thrusterPin7 = 7;
byte thrusterPin6 = 6;
byte thrusterPin5 = 5;

Servo thrusters[numThruster];

//i2c stuff for digispark
const int numI2C = 2;
char i2cBuffer[numI2C];
char i2cReturn[numI2C];
int digispark1 = 9;

//analog sensor set up
const int numSensors = 5;
int sensors[numSensors] = {A0, A1, A2, A3, A4};



// An EthernetUDP instance to let us send and receive packets over UDP
EthernetUDP Udp;

void setup() {
  // start the Ethernet and UDP:
  Ethernet.begin(mac,ip);
  Udp.begin(localPort);

  Serial.begin(9600);
  
  //for thruster motor set up
  for(int i = 0; i < numThruster; i++){
    thrusters[i].attach(i + 5);
    thrusters[i].writeMicroseconds(1500);
    delay(1000);
  }
  
  //i2c setup
  Wire.begin();
  
  //analog pin as digital pin setup
  for(int j = 0; j < numSensors; j++){
    pinMode(sensors[j], INPUT);
  }

  
}

void loop() {
  // if there's data available, read a packet
  int packetSize = Udp.parsePacket();
  if(packetSize)
  {
    //Serial.print("Received packet of size ");
    //Serial.println(packetSize);
    //Serial.print("From ");
    IPAddress remote = Udp.remoteIP();
    //for (int i =0; i < 4; i++)
    //{
    //  Serial.print(remote[i], DEC);
    //  if (i < 3)
    //  {
    //    Serial.print(".");
    //  }
    //}
    //Serial.print(", port ");
    //Serial.println(Udp.remotePort());

    // read the packet into packetBufffer
    Udp.read(packetBuffer,UDP_TX_PACKET_MAX_SIZE);
    //Serial.println("Contents:");
    //Serial.println(packetBuffer);
    //**
    // 10 byte for motor speed, 1 byte for manipulator/lighting, 1 byte for servo
    //
    //thruster stuff
    //thruster motor data range from 0 to 800
     for(int j=0; j < 8; j++){ 
       //int signal = int(packetBuffer[j]);
       //signal = signal + 1100;
       int signal;
       for(int k=0; k < 10; k++){
         int bitstoWrite = bitRead(packetBuffer[k] - '0',j);
         bitWrite(signal, j, bitstoWrite);
       }
       
       signal = signal + 1100; 
       thrusters[j].writeMicroseconds(signal);
       
       //Serial.print(char(packetBuffer[j]));  
       //Serial.println();   
     }
     
     //I2C stuff to digispark
     //sendin two bytes of information
     for(int m=0; m < numI2C; m++){
       i2cBuffer[m] = packetBuffer[m + 10];
     }
     
     Wire.beginTransmission(digispark1); //transmit 
     Wire.write(i2cBuffer); 
     Wire.endTransmission();
     
     Wire.requestFrom(digispark1, 1); //read 1 byte from digispark
     byte receiver  = Wire.read();
     
     
     int sensor1 = bitRead(receiver, 0);
     int sensor2 = bitRead(receiver, 1);
     
     for(int n=0; n < numSensors; n++){
       int value = digitalRead(sensors[n]);
       bitWrite(ReplyBuffer[0], n, value);
     }
     bitWrite(ReplyBuffer[0], 5, sensor1);
     bitWrite(ReplyBuffer[0], 6, sensor2); 

    // send a reply, to the IP address and port that sent us the packet we received
    Udp.beginPacket(Udp.remoteIP(), Udp.remotePort());
    Udp.write(ReplyBuffer);
    Udp.endPacket();
  }
  delay(10);
}


/*
  Processing sketch to run with this example
 =====================================================
 
 // Processing UDP example to send and receive string data from Arduino 
 // press any key to send the "Hello Arduino" message
 
 
 import hypermedia.net.*;
 
 UDP udp;  // define the UDP object
 
 
 void setup() {
 udp = new UDP( this, 6000 );  // create a new datagram connection on port 6000
 //udp.log( true ); 		// <-- printout the connection activity
 udp.listen( true );           // and wait for incoming message  
 }
 
 void draw()
 {
 }
 
 void keyPressed() {
 String ip       = "192.168.1.177";	// the remote IP address
 int port        = 8888;		// the destination port
 
 udp.send("Hello World", ip, port );   // the message to send
 
 }
 
 void receive( byte[] data ) { 			// <-- default handler
 //void receive( byte[] data, String ip, int port ) {	// <-- extended handler
 
 for(int i=0; i < data.length; i++) 
 print(char(data[i]));  
 println();   
 }
 */


