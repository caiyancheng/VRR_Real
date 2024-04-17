import numpy as np

Pixel_value_range = [0.05,1]
sample_numbers = 20
pixel_all_values = np.logspace(np.log10(Pixel_value_range[0]), np.log10(Pixel_value_range[1]), num=sample_numbers)