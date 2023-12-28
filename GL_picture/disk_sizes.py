import os

from PIL import Image, ImageDraw
import glfw
from G1_Calibration.compute_size_real import compute_scale_from_degree
from G1_Calibration.compute_x_y_location import compute_x_y_from_eccentricity

def generate_image(x_center, y_center, x_scale, y_scale, screen_width, screen_height):
    image = Image.new("RGB", (screen_width, screen_height), (0, 0, 0))
    draw = ImageDraw.Draw(image)
    x_center = x_center + screen_width/2
    y_center = y_center + screen_height / 2

    # 画一个白色的抗锯齿圆
    draw.ellipse(
        (
            x_center - x_scale*screen_width,
            y_center - y_scale*screen_height,
            x_center + x_scale*screen_width,
            y_center + y_scale*screen_height,
        ),
        fill=(255, 255, 255),
        outline=(255, 255, 255),  # 使用相同的颜色作为边界，实现抗锯齿效果
    )

    return image

def generate_image_for_sizes(size_list, save_path):
    glfw.init()
    second_monitor = glfw.get_monitors()[1]
    screen_width, screen_height = glfw.get_video_mode(second_monitor).size
    for size_value in size_list:
        x_center, y_center = compute_x_y_from_eccentricity(eccentricity=0)
        x_scale, y_scale = compute_scale_from_degree(visual_degree=size_value)
        img = generate_image(x_center, y_center, x_scale, y_scale, screen_width, screen_height)
        img.save(os.path.join(save_path, f'Size_{size_value}_disk.png'))

if __name__ == "__main__":
    size_list = [0.5, 1, 16, 'full']
    save_path = 'Disk_Sizes'
    os.makedirs(save_path, exist_ok=True)
    generate_image_for_sizes(size_list=size_list, save_path=save_path)