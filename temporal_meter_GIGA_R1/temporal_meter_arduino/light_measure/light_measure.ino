#define METER_PIN_1 A0
#define METER_PIN_2 A1
#define MAX_NO_MEAS 200000
#define MAX_TRIGGER_WAIT 10000
#define E_OK 0
#define E_TOO_LONG 1

#pragma packed(1)
struct message_t { //定义了一个结构体，包含了一个代表长度的数组以及data的指针位置
  uint64_t length;
  uint8_t data[0];
};

#pragma packed(1)
struct measure_request_t { //定义了measure request的结构体，由python函数传入指令
  uint8_t edge_triggered;
  uint8_t bright_mode;
  uint16_t sampling_frequency;
  uint32_t num_measurements;
};

#pragma packed(1)
struct measure_response_t { //定义了measure response的结构体，仅仅回答状态
  uint8_t status;
};

#pragma packed(1)
struct results_header_t {
  measure_request_t request;
  uint32_t start_ts;
};

uint32_t start_ts = 0; //定义一个32位无符号整数，表示测量的开始时间。

measure_request_t active_measurement_request; //定义一个measure_request_t类型的变量，表示当前的测量请求。
uint16_t L_measurements[MAX_NO_MEAS]; //定义一个长度为MAX_NO_MEAS的uint16_t类型数组，用于存储测量结果。

void setup() {
  Serial.begin(500000);
  Serial.setTimeout(1000);

  pinMode(METER_PIN_1, INPUT); //将 METER_PIN_1（在代码中被定义为 A0）配置为输入模式。这意味着该引脚将被用于接收来自外部传感器或其他设备的电信号。
  pinMode(METER_PIN_2, INPUT); //将 METER_PIN_2（在代码中被定义为 A1）配置为输入模式，与上述相同。

  analogReadResolution(16); //设置模拟输入的分辨率为 16 位。这决定了模拟输入被转换为数字值时的位数。在 Arduino 上，通常使用 10 位分辨率（0 到 1023），但这里将分辨率设置为 16 位，表示模拟读取的数值范围为 0 到 65535。

  // L_measurements = (uint16_t*)malloc(sizeof(uint16_t) * MAX_NO_MEAS);

  // if (L_measurements == NULL) {
  //   Serial.println("Failed to allocate memory");
  //   while(1);
  // }
}


void take_measurements() {
  start_ts = micros();
  unsigned long last_ts = start_ts;
  unsigned long ts;

  unsigned long sampling_period = 1000000 / active_measurement_request.sampling_frequency;
  int active_pin = active_measurement_request.bright_mode ? METER_PIN_2 : METER_PIN_1;

  for (int i = 0; i < active_measurement_request.num_measurements; ++i) {
    while ((ts = micros()) - last_ts < sampling_period);
    L_measurements[i] = analogRead(active_pin);
    last_ts = ts;
  }
}

// void waitForRising()
// {  
//     short triggerWaitMax = MAX_TRIGGER_WAIT;
//     short dataPoint = analogRead(active_pin);
//     unsigned long sum = 0;

//     // wait up to an entire sample set to get a zero value first=
//     while (dataPoint != 0 && triggerWaitMax > 0)
//     {
//         triggerWaitMax--;
//         dataPoint = analogRead(active_pin);
//         sum += dataPoint;
//     }

//     short threshold = triggerWaitMax > 0 ? 1 : (short)(threshold / NO_MEAS);

//     // trigger on a non-zero value. Wait up to an entire sample set if necessary
//     triggerWaitMax = NO_MEAS;
//     while (dataPoint < threshold && triggerWaitMax > 0)
//     {
//         triggerWaitMax--;
//         dataPoint = analogRead(active_pin);
//     }
// }

void loop() {
  message_t message;
  if (Serial.available()) {
    char command = Serial.read();
    switch (command) {
    case 'M': {
      Serial.readBytes((uint8_t * ) & active_measurement_request, sizeof(active_measurement_request));
      measure_response_t response;
      message = {
        .length = sizeof(response)
      };

      if (active_measurement_request.num_measurements > MAX_NO_MEAS) {
        Serial.write((uint8_t * ) & message, sizeof(message));
        response.status = E_TOO_LONG;
        Serial.write((uint8_t * ) & response, sizeof(response));
        break;
      }

      // if (active_measurement_request.edge_triggered > 0)
      // {
      //     waitForRising();
      // }

      take_measurements();

      Serial.write((uint8_t * ) & message, sizeof(message));

      response.status = E_OK;
      Serial.write((uint8_t * ) & response, sizeof(response));

    }
    break;

    case 'i': // Identify - to prevent communication with wrong port
    {
      message = {
        .length = 13
      };
      Serial.write((uint8_t * ) & message, sizeof(message));
      Serial.print("flicker_meter");
      break;
    }

    case 'G':
      results_header_t results_header = {
        .request = active_measurement_request,
        .start_ts = start_ts,
      };

      message = {
        .length = sizeof(results_header) + sizeof(L_measurements[0]) * active_measurement_request.num_measurements
      };
      Serial.write((uint8_t*) &message, sizeof(message));
      Serial.write((uint8_t*) &results_header, sizeof(results_header));
      Serial.write((uint8_t*) L_measurements, sizeof(L_measurements[0]) * active_measurement_request.num_measurements);
  
      // uint32_t i = 0;
      // const uint32_t mtu = 32768;
      // while (i < active_measurement_request.num_measurements) {
      //   Serial.write((uint8_t * ) (L_measurements + i), sizeof(L_measurements[0]) * min(active_measurement_request.num_measurements - i, mtu));
      //   i += mtu;
      // }
      
      break;
    }
  }
}