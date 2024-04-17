import math

def compute_scale_from_degree(visual_degree, distance = 1):
    if visual_degree == 'full':
        return 1, 1
    screen_width_resolution = 3840
    screen_height_resolution = 2160
    # screen_width = 1.2176
    # screen_height = 0.6849
    screen_width = 1.225
    screen_height = 0.706
    W = math.tan(visual_degree/2 * math.pi / 180) * 2 * distance
    W_pixels = W / screen_width * screen_width_resolution
    W_scale = W_pixels / screen_width_resolution
    H_scale = W_pixels / screen_height_resolution

    return W_scale, H_scale

if __name__ == "__main__":
    visual_degree = 37.8
    W_scale, H_scale = compute_scale_from_degree(visual_degree=visual_degree)
    print('W_scale', W_scale, 'H_scale', H_scale)
