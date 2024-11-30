import numpy as np
from PIL import Image, ImageSequence
from display_encoding import display_encode
display_encode_tool = display_encode(400)

# Parameters
width, height = 400, 100  # Dimensions of the image
duration = 62  # Frame duration in milliseconds
frames = 32  # Number of frames in the GIF

luminance_list = np.logspace(np.log10(10), np.log10(400), width)
# Create the frames for the GIF
images = []
for frame in range(frames):
    img_array = np.zeros((height, width), dtype=np.uint8)
    for x in range(width):
        # Compute luminance values for this column
        luminance = luminance_list[x]
        if frame % 2 == 0:  # Alternating luminance
            luminance -= 3
        color = display_encode_tool.L2C_sRGB(luminance)
        img_array[:, x] = int(color * 255)
    # Convert to PIL Image
    img = Image.fromarray(img_array, mode="L")
    images.append(img)

# Save as GIF
output_path = "flashing_rectangle_3.gif"
images[0].save(
    output_path,
    save_all=True,
    append_images=images[1:],
    optimize=True,
    duration=duration,
    loop=0
)

print(f"GIF saved to {output_path}")
