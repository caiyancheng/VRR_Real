import ctypes
import serial
import numpy as np


class BadIdentification(Exception):
    pass


class TooLongError(Exception):
    pass


class MessageStruct(ctypes.Structure):
    _pack_ = 1
    _fields_ = [
        ("length", ctypes.c_uint64),
    ]


class MeasureRequestStruct(ctypes.Structure):
    _pack_ = 1
    _fields_ = [
        ("edge_triggered", ctypes.c_uint8),
        ("bright_mode", ctypes.c_uint8),
        ("sampling_frequency", ctypes.c_uint16),
        ("num_measurements", ctypes.c_uint32)
    ]


class ResultsHeaderStruct(ctypes.Structure):
    _pack_ = 1
    _fields_ = [
        ("request", MeasureRequestStruct),
        ("start_ts", ctypes.c_uint32)
    ]


class MeasureResponseStruct(ctypes.Structure):
    _pack_ = 1
    _fields_ = [
        ("status", ctypes.c_uint8)
    ]


class TemporalLightSensor:
    def __init__(self, serial_port: serial.Serial) -> None:
        self.serial_port = serial_port

        self.serial_port.write(b'i') # 向硬件设备发送字符 'i'
        if self.__read_message() != b"flicker_meter": # 读取消息并判断硬件设备是否正确识别为 "flicker_meter"
            raise BadIdentification()

    def __read_message(self) -> MessageStruct:
        message = MessageStruct.from_buffer_copy(self.serial_port.read(ctypes.sizeof(MessageStruct))) # 从串口读取消息长度
        print("read_message: message length =", message.length)
        result =  self.serial_port.read(message.length) # 读取消息内容
        print("read_message: done")
        return result

    def take_measurement(self, edge_triggered: bool = False, bright_mode: bool = False, sampling_frequency: int = 10000,
                         num_measurements: int = 10000) -> None:
        self.serial_port.write(b'M')
        self.serial_port.flush()

        request = MeasureRequestStruct(
            edge_triggered=edge_triggered,
            bright_mode=bright_mode,
            sampling_frequency=sampling_frequency,
            num_measurements=num_measurements,
        )

        self.serial_port.write(request)

        resp = MeasureResponseStruct.from_buffer_copy(self.__read_message())

        if resp.status == 1:
            raise TooLongError()

    def get_results(self):
        self.serial_port.write(b'G')
        self.serial_port.flush()

        results = self.__read_message()
        results_header = ResultsHeaderStruct.from_buffer_copy(results[:ctypes.sizeof(ResultsHeaderStruct)])

        measurements = np.frombuffer(results[ctypes.sizeof(ResultsHeaderStruct):], dtype=np.uint16)

        return measurements, results_header.start_ts



