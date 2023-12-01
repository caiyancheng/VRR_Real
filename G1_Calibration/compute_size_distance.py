import math

screen_width_resolution = 3840
screen_width = 1.2176 #m

# 计算观察者距离
def calculate_distance(ppd, screen_width, screen_width_resolution):
    sita = screen_width_resolution * math.pi / (180 * ppd)
    # ppd = ppd * math.pi / 180.
    distance = screen_width / (2 * math.tan( math.pi / 180 * sita / 2))
    return distance

distance_4x4 = calculate_distance(4, screen_width, screen_width_resolution)
distance_16x16 = calculate_distance(16, screen_width, screen_width_resolution)

print(f"观察pix-per-deg为4x4 deg时，观察者距离屏幕的距离：{distance_4x4:.2f} 米")
print(f"观察pix-per-deg为16x16 deg时，观察者距离屏幕的距离：{distance_16x16:.2f} 米")

# 理解错误了老板的意思，不要管这段代码