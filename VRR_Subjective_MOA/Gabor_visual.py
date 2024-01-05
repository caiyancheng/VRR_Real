import winsound
import json
import glfw
from OpenGL.GL import *
from OpenGL.GLUT.freeglut import *
import time
import cv2
import numpy as np
import random
import keyboard
import pandas as pd
import os
import math
from G1_Calibration.compute_size_real import compute_scale_from_degree
from G1_Calibration.compute_x_y_location import compute_x_y_from_eccentricity
from VRR_subjective_MOA_Luminance_reference_gabor import create_gabor_patch, create_gabor_patch_disk

# gabor_patch = create_gabor_patch_disk(2000, 2000, 10, 0, 0.1, 0.5, 0.3, 0.3)
gabor_patch = create_gabor_patch_disk(3840, 2060, 31.333055047740398, 0, 0.05, 0.1, 2*2160/3840, 2)
cv2.imwrite('Gabor.png', gabor_patch)