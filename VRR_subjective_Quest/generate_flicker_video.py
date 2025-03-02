import cv2
import numpy as np
from tqdm import tqdm

# Parameter settings
resolution = (3840, 2160)  # 4K resolution
fps = 120  # Frame rate
flash_frequency = 12  # Flicker frequency (Hz)
disk_radius = 200  # Disk radius
color_A = (255, 255, 255)  # Color A (White)
color_B = (128, 128, 128)  # Color B (Gray)
duration = 2  # Video duration (seconds)

# Calculate the number of frames
total_frames = duration * fps
frames_per_cycle = fps / flash_frequency  # Number of frames per complete flicker cycle
half_cycle = int(frames_per_cycle / 2)  # Number of frames for half a cycle

# Output video settings
fourcc = cv2.VideoWriter_fourcc(*'mp4v')
out = cv2.VideoWriter('flickering_disk.mp4', fourcc, fps, resolution)

# Disk position (centered)
center = (resolution[0] // 2, resolution[1] // 2)

# Generate video frames
def generate_frame(color):
    frame = np.zeros((resolution[1], resolution[0], 3), dtype=np.uint8)  # Pure black background
    cv2.circle(frame, center, disk_radius, color, -1)  # Draw a circle
    return frame

for i in tqdm(range(total_frames)):
    if (i // half_cycle) % 2 == 0:
        frame = generate_frame(color_A)
    else:
        frame = generate_frame(color_B)
    out.write(frame)

out.release()
print("Video generation completed: flickering_disk.mp4")
