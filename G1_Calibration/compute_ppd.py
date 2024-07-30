import math

screen_width_resolution = 3840
screen_height_resolution = 2160
# screen_width = 1.2176
# screen_height = 0.6849
screen_width = 1.225
screen_height = 0.706

distance = 1

degree_W = math.atan(screen_width/(2*distance)) * 2 * 180 / math.pi
degree_H = math.atan(screen_height/(2*distance)) * 2 * 180 / math.pi

ppd_W = screen_width_resolution / degree_W
ppd_H = screen_height_resolution / degree_H

print(f'ppd_W: {ppd_W}; ppd_H: {ppd_H}')
