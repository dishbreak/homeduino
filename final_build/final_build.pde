/******************************************************************
Ansum Dholakia 
Vishal Kotcherlakota 
University of California, San Diego
ECE 118: Computer Interfacing
******************************************************************/

#include <X10Firecracker.h>
#include <Server.h>
#include <Client.h>
#include <Ethernet.h>
#include <IRremote.h>

// network configuration.  gateway and subnet are optional.
byte mac[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
byte ip[] = { 192, 168, 1, 90 };
byte gateway[] = { 192, 168, 1, 1 };
byte subnet[] = { 255, 255, 255, 0 };

//communication variables
char byteIn;
IRsend irsend;
const int StereoPin = 4;
const int TVPin = 5;
const int RTSPin = 6;
const int DTRPin = 7;

//Xbox Timings
int i = 0;
unsigned int poundA[] = {2722,889,417,417,417,417,417,889,417,889,1306,889,417,417,417,417,417,417,417,417,417,417,417,417,417,417,417,417,417,417,417,417,889,417,417,417,417,417,417,889,889,417,417,417,417,889,889,889,417,417,417,417,417,417,417,417,889,417,417,417,417,889,417,500};
unsigned int poundLen = 64;
unsigned int turnOn[] = {2667,889,444,444,444,444,444,889,444,889,1361,889,444,444,444,444,444,444,444,444,444,444,444,444,444,444,444,444,444,444,444,444,889,444,444,444,444,444,444,444,444,444,444,444,444,444,444,889,889,889,444,444,444,444,444,444,889,889,889,889,889,889,444,417};
unsigned int onLen = 65;
unsigned int poundB[] = {2722,889,417,417,417,417,417,889,417,889,1306,889,417,417,417,417,417,417,417,417,417,417,417,417,417,417,417,417,417,417,417,417,889,417,417,417,417,417,417,417,417,417,417,417,417,417,417,889,889,889,417,417,417,417,417,417,417,417,889,417,417,417,417,889,417,417,417,67583,2722,889,417,417,417,417,417,889,417,889,1306,889,417,417,417,417,417,417,417,417,417,417,417,417,417,417,417,417,417,417,417,417,889,417,417,417,417,417,417,500,417,417,417,417,417,417,417,889,889,889,417,417,417,417,417,417,417,417,889,417,417,417,417,889,417,417,417};
unsigned int bLen = 135;
unsigned int turnOff[] = {2667,889,444,444,444,444,444,889,444,889,1361,889,444,444,444,444,444,444,444,444,444,444,444,444,444,444,444,444,444,444,444,444,889,444,444,444,444,444,444,889,889,444,444,444,444,889,889,889,444,444,444,444,444,444,889,889,889,889,444,444,889};
unsigned int offLen = 61;

//Samsung Timings
const int power[] = {224, 224, 64, 191};
const int psize[] = {224, 224, 124, 131};
const int stereoPwr[] = {194, 202, 128, 127};
const int stereoAux[] = {194, 202, 136, 119};

//Samsung Variables
const int LEADER_PULSE=4400;
const int PERIOD=26;
const int WAIT_TIME=11;
const int PULSE_BIT=600;
const int PULSE_ONE=1600;
const int PULSE_ZERO=500;

/*THANKS
  None of this code would be possible without the work of
  Mark Ivey, and his blog post at:
  http://zovirl.com/2008/11/12/building-a-universal-remote-with-an-arduino/
  While the code belongs to us, it is derived largely from his blog.
  
  Thanks to Ken Shirrif at www.arcfn.com, for his work on IR libraries, and
  his gracious support. He owns the IRremote library.
  
  Thanks to BroHogan at brohogan.blogspot.com, for his work on X10, and the
  CM17A "Firecracker" protocol which we use in our work. He owns the 
  X10Firecracker library.
  
  Feel free to use our code, but do give credit to us, as we have done for
  those who have supported us. ;) 
  
*/



//menu string
char menuStr[] = "Telnet Remote Control: Menu\r\n0) TV Power\r\n1) TV P.Size\r\n2) Stereo Power\r\n3) Stereo Aux\r\n4) Xbox On\r\n5) Xbox Off\r\n6) X10 Unit 1 On\r\n7) X10 Unit 2 On\r\n8) X10 Unit 1 Off\r\n9) X10 Unit 2 Off\r\n> ";

/*blastOn: The LED strobing effect. Shown to respond to recievers
sensitive to 38kHz modulating frequency on Samsung TVs and Stereos.
This is the "mark" part of an IR signal.
time: the amound of time in microseconds that the strobe will go on 
  for. Note that time is not entirely accurate: time must be allowed
  for digitalWrite() to work...typically this is 2us.  
pin: the digital pin that the IR LED is connected to. PIN MUST BE
  INITIALIZED WITH pinMode().
*/
void blastON(const int time, const int pin) {
  //copy the time to a scratch variable. (poor man's timer)
  int scratch = time; 
  //while there is one full period left on the timer...
  while(scratch > PERIOD)
  {
    //turn on the LED
    digitalWrite(pin, HIGH);
    //wait for half the period
    delayMicroseconds(WAIT_TIME);
    //turn off the LED
    digitalWrite(pin, LOW);
    //wait for half the period
    delayMicroseconds(WAIT_TIME);
    //take one period off the timer
    scratch = scratch - PERIOD;
  }
}

/*blastOFF: a function that acts as a macro. This is the "space" 
part of an IR signal.
time: the amount of time in microseconds.
*/
void blastOFF(int time) {
  delayMicroseconds(time);
}

/*blastBye: a function that encodes Samsung IR Codes into 
  mark/space timing pairs on a specified LED.
  We store codes in 8 bit words to keep things readable.
code: the number fed in, ranging from [0, 255]
pin: the digital pin that the IR LED is connected to. PIN MUST BE
  INITIALIZED WITH pinMode().
*/
void blastByte(const int code, const int pin) {
  int i; //counter variable
  //work backwards from MSB to LSB of the word
  for(i = 7; i > -1; i--)
  {
    //check if the ith significant bit is 1
    if(1 << i & code) 
    {
      /*1: corresponds to a mark of 600us,
      followed by a space of 1600us.*/
      //the mark
      blastON(PULSE_BIT, pin);
      //the space
      blastOFF(PULSE_ONE);
    }
    else
    {
      /*0: corresponds to a mark of 600us,
      followed by a space of 1600us.*/
      //the mark
      blastON(PULSE_BIT, pin);
      //the space
      blastOFF(PULSE_ZERO);
    }
  }
}

/*command: send a leader pulse to start an IR signal, call
blastByte as needed to encode marks and spaces, and finish with
a leader pulse and space. This code will only send the command once,
it may need to be repeated.
irCode: the actual IR code, given as 4 8-bit integers.
pin: the digital pin that the IR LED is connected to. PIN MUST BE
  INITIALIZED WITH pinMode().
*/
void command(const int irCode[], const int pin)
{
  int i;
  //start with the leader pulse.
  //the mark: adjusted to account for inexact timings
  blastON(LEADER_PULSE-200, pin);
  //the space
  blastOFF(LEADER_PULSE);
  //loop through all 4 words in the array
  for(i = 0; i < 4; i++)
  {
    //blast each word out on the IR blaster connected to pin
    blastByte(irCode[i], pin);
  }
  //end with a closing pulse
  blastON(PULSE_BIT,pin);
  //a long space (min amount of time before another command is sent)
  delay(47);
}



// accept telnet connections on port 1023.
// this eliminates the need for handshaking. 
Server server = Server(1023);

void setup() {
  //initalize ethernet
  Ethernet.begin(mac, ip, gateway, subnet);
  //start listening for clients
  server.begin();
  //initialize pins
  pinMode(StereoPin, OUTPUT);
  pinMode(TVPin, OUTPUT);
  //initialize X10
  X10.init( RTSPin, DTRPin, 0 );
}

void loop() {
  //check ethernet interface
  Client client = server.available();
  //if there's data...
  if(client > 0) {
    //read the data
    byteIn = client.read();
    //switch on the character read in
    switch (byteIn) {
      //for a CR, just break (artifact from Telnet)
      case 13: break;
      //for a LF, just break (artifact from Telnet)
      case 10: break;
      //for a 0, send a Power signal to the Samsung TV
      case '0':
        //announce it
        server.write("Sending TV Power...");
        //send it
        for(i = 0; i<3; i++) { command(power, TVPin); } 
        //wrap-up
        server.write("sent.\r\n");
        //display the menu
        server.write(menuStr);
        //break
        break;
      //for a 1, send a P.Size signal to the Samsung TV
      case '1':
        //announce it
        server.write("Sending TV P.Size...");
        //send it
        for(i = 0; i<3; i++) { command(psize, TVPin); }
        //wrap-up
        server.write("sent.\r\n");
        //display the menu
        server.write(menuStr);
        //break
        break;
      //for a 2, send a Power signal to the Stereo
      case '2':
        //announce it
        server.write("Sending Stereo Power...");
        //send it
        for(i = 0; i<3; i++) { command(stereoPwr,StereoPin); }
        //wrap-up
        server.write("sent.\r\n");
        //display the menu
        server.write(menuStr);
        //break
        break;
      //for a 3, send an Aux signal to the Stereo
      case '3':
        //announce it
        server.write("Sending Stereo Aux...");
        //send it
        for(i = 0; i<3; i++) { command(stereoAux, StereoPin); }
        //wrap-up
        server.write("sent.\r\n");
        //display the menu
        server.write(menuStr);
        //break
        break;
      //for a 4, send a Power on signal to the Xbox
      case '4':
        //announce it
        server.write("Sending Xbox Power On...");
        //send it
        ///first half of the macro
        irsend.sendRaw(poundA, poundLen, 36);
        ///gap
        delay(67);
        ///second half of the macro
        irsend.sendRaw(turnOn, onLen, 36);
        //wrap-up
        server.write("sent.\r\n");
        //display the menu
        server.write(menuStr);
        //break
        break;
      //for a 5, send a Power off signal to the Xbox
      case '5':
        //announce it
        server.write("Sending Xbox Power Off...");
        //send it
        ///first half of the macro
        irsend.sendRaw(poundB, bLen, 36);
        ///gap
        delay(67);
        ///second half of the macro
        irsend.sendRaw(turnOff, offLen, 36);
        //wrap-up
        server.write("sent\r\n");
        //display the menu
        server.write(menuStr);
        //break
        break;
      //for a 6, send an ON code to X10 unit 1
      case '6':
        //announce it
        server.write("Turning ON X10 unit 1...");
        //send the code
        X10.sendCmd(hcA, 1, cmdOn);
        //confirm it
        server.write("sent.\r\n");
        //display the menu
        server.write(menuStr);
        //break
        break;
      //for a 7, send an ON code to X10 unit 2
      case '7':
        //announce it
        server.write("Turning ON X10 unit 2...");
        //send the code
        X10.sendCmd(hcA, 2, cmdOn);
        //confirm it
        server.write("sent.\r\n");
        //display the menu
        server.write(menuStr);
        //break
        break;
      //for a 8, send an OFF code to X10 unit 1
      case '8':
        //announce it
        server.write("Turning OFF X10 unit 1...");
        //send the code
        X10.sendCmd(hcA, 1, cmdOff);
        //confirm it
        server.write("sent.\r\n");
        //display the menu
        server.write(menuStr);
        //break
        break; 
      //for a 9, send an OFF code to X10 unit 2
      case '9':
        //announce it
        server.write("Turning OFF X10 unit 2...");
        //send the code
        X10.sendCmd(hcA, 2, cmdOff);;
        //confirm it
        server.write("sent.\r\n");
        //display the menu
        server.write(menuStr);
        //break
        break; 
      //for anything else, display an error
      default:
        //error
        server.write("Hey! That's not a valid input.\r\n");
        //display the menu
        server.write(menuStr);
        //break
        break;
    }
  }
}
