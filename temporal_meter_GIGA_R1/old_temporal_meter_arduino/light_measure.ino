#define METER_PIN_1 A0
#define METER_PIN_2 A1
#define NO_MEAS 1200

// ADC prescalers going from 2^1..2^7.
// greater prescalers yield lower sampling frequency
const unsigned char PRESCALERS[7] = 
{
    (1 << ADPS0),
    (1 << ADPS1),
    (1 << ADPS1 | 1 << ADPS0),
    (1 << ADPS2),
    (1 << ADPS2) | (1 << ADPS0),
    (1 << ADPS2) | (1 << ADPS1),
    (1 << ADPS2) | (1 << ADPS1) | (1 << ADPS0)
};

void setup() 
{
    Serial.begin(57600);

    pinMode( METER_PIN_1, INPUT );  
    pinMode( METER_PIN_2, INPUT );  
    analogReference(DEFAULT);
  
    // Default prescaler to maximum timespan
    ADCSRA = (ADCSRA & ~PRESCALERS[6]) | PRESCALERS[6];  
}

uint8_t active_pin = METER_PIN_2;

// measurements
struct measurement
{
    uint32_t timestamp;
    short irrad;
};

measurement M[NO_MEAS];

void take_measurements()
{
    unsigned long start_ts = micros();  
    for (int i = 0; i < NO_MEAS; ++i) 
    {
        M[i].irrad =  analogRead(active_pin);
        M[i].timestamp = (uint32_t)(micros() - start_ts);
    }
}

void transfer_results()
{
    Serial.print(NO_MEAS);
    Serial.print(";");
    Serial.write(0);
  
    for (int i=0; i < NO_MEAS; ++i) 
    {
        Serial.print( M[i].timestamp);
        Serial.print( "," );
        Serial.print( M[i].irrad );        
        Serial.print( ";" );
        Serial.write( 0 );        
    }  
}

void waitForRising()
{  
    short triggerWaitMax = NO_MEAS;
    short dataPoint = analogRead(active_pin);
    unsigned long sum = 0;
   
    // wait up to an entire sample set to get a zero value first=
    while (dataPoint != 0 && triggerWaitMax > 0)
    {
        triggerWaitMax--;
        dataPoint = analogRead(active_pin);
        sum += dataPoint;
    }

    short threshold = triggerWaitMax > 0 ? 1 : (short)(threshold / NO_MEAS);
     
    // trigger on a non-zero value. Wait up to an entire sample set if necessary
    triggerWaitMax = NO_MEAS;
    while (dataPoint < threshold && triggerWaitMax > 0)
    {
        triggerWaitMax--;
        dataPoint = analogRead(active_pin);
    }
}

void loop() {
    if (Serial.available()) {
        char command = Serial.read();
        switch( command ) 
        {
            case 'M':
            {
                while (Serial.available() < 3)
                ; // wait for parameters

                char edgeTriggered = Serial.read();
                edgeTriggered = edgeTriggered - 'A';
                char duration = Serial.read();
                duration = min(6, max(0, duration - 'A'));
                char brightMode = Serial.read();
                active_pin = brightMode == 'A' ? METER_PIN_1 : METER_PIN_2;
                if (edgeTriggered > 0)
                {
                    waitForRising();e:\Matlab_Files\temporal_meter_GIGA_R1\temporal_meter_arduino\light_measure\light_measure.ino
                }
                ADCSRA = (ADCSRA & ~PRESCALERS[6]) | PRESCALERS[int(duration)];  
                
                take_measurements();
                //transfer_results();
            }
            break;
            
            case 'i':    // Identify - to prevent communication with wrong port
            {
              Serial.print( "flicker_meter" );
              Serial.write( 0 );        
              break;
            }
            
            case 'G':
                transfer_results(); 
            break;
        }
    }
}