import math

def compute_spatial_frequency(distance = 1, cpd=10): #cycles per degree
    screen_width_resolution = 3840
    screen_width = 1.2176
    size_degree_w = math.atan(screen_width / (2 * distance)) * 2 / math.pi * 180
    cycles = cpd * size_degree_w
    # T = screen_width_resolution / cycles #12个像素
    frequency = cycles / 2
    return frequency

if __name__ == '__main__':
    frequency = compute_spatial_frequency(cpd=1) #多少个像素就要换一次
    print('frequency:', frequency)