import subprocess
import re

measuring_speed = " "  # Set your measuring speed
command = f"E:/Matlab_codes/matlab_toolboxes/display_calibration/Konica/Konica_Measure_Light/Debug/Konica_Measure_Light.exe {measuring_speed}"

result = subprocess.run(command, text=True, capture_output=True, shell=True)
cmdout = result.stdout.strip()
cmdout = ''.join(cmdout.split())
split_str = cmdout.split(',')
Y = float(split_str[9])
x = float(split_str[10])
y = float(split_str[11])
print('Y', Y)
print('x', x)
print('y', y)