import math

def compute_degree_from_scale(visual_scale, distance = 1):
    screen_width_resolution = 3840
    screen_height_resolution = 2160
    screen_width = 1.2176
    screen_height = 0.6849
    size_degree_w = math.atan(screen_width * visual_scale[0] / (2 * distance)) * 2 / math.pi * 180
    size_degree_h = math.atan(screen_height * visual_scale[1] / (2 * distance)) * 2 / math.pi * 180
    return size_degree_w, size_degree_h

if __name__ == "__main__":
    visual_scale = [1, 1]
    size_degree_w, size_degree_h = compute_degree_from_scale(visual_scale=visual_scale)
    print('size degree W:', size_degree_w, 'size degree H:', size_degree_h)
    print('Area', size_degree_h * size_degree_w)