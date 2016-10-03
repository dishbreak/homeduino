
const int LEADER_PULSE=4400;
const int PERIOD=26;
const int WAIT_TIME=11;
const int PULSE_BIT=600;
const int PULSE_ONE=1600;
const int PULSE_ZERO=500;


const int power[] = {224, 224, 32, 223};
const int power[] = {224, 224, 64, 191};
const int psize[] = {224, 224, 124, 131};
const int stereoPwr[] = {194, 202, 128, 127};
const int stereoAux[] = {194, 202, 136, 119};

void blastON(const int time, const int pin) {
  int scratch = time;
  while(scratch > PERIOD)
  {
    digitalWrite(pin, HIGH);
    delayMicroseconds(WAIT_TIME);
    digitalWrite(pin, LOW);
    delayMicroseconds(WAIT_TIME);
    scratch = scratch - PERIOD;
  }
}

void blastOFF(int time) {
  delayMicroseconds(time);
}

void blastByte(const int code, const int pin) {
  int i;
  for(i = 7; i > -1; i--)
  {
    
    if(1 << i & code) //check if the ith significant bit is 1
    {
      blastON(PULSE_BIT, pin);
      //Serial.print("1");
      blastOFF(PULSE_ONE);
    }
    else
    {
      blastON(PULSE_BIT, pin);
      //Serial.print("0");
      blastOFF(PULSE_ZERO);
    }
  }
  //Serial.print("\n");
}

void command(const int irCode[], const int pin)
{
  int i;
  blastON(LEADER_PULSE-200, pin);
  blastOFF(LEADER_PULSE);
  for(i = 0; i < 4; i++)
  {
    blastByte(irCode[i], pin);
  }
  blastON(PULSE_BIT,pin);
  //blastOFF(LEADER_PULSE);
  delay(47);
}
