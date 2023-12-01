import math

def compute_x_y_from_eccentricity(eccentricity, distance = 1):
    screen_width_resolution = 3840
    screen_height_resolution = 2160
    screen_width = 1.2176
    screen_height = 0.6849
    Y = 0.
    X = (distance * math.tan(eccentricity * math.pi / 180))/screen_width * 2
    return X, Y

if __name__ == "__main__":
    eccentricity = 15
    X, Y = compute_x_y_from_eccentricity(eccentricity = eccentricity)
    print('X', X, 'Y', Y)
