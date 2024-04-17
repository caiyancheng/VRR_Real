import os
from PIL import Image, ImageDraw
import glfw
from G1_Calibration.compute_size_real import compute_scale_from_degree
from G1_Calibration.compute_x_y_location import compute_x_y_from_eccentricity

def generate_image_disk(x_center, y_center, x_scale, y_scale, screen_width, screen_height, color_value):
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
        fill=(color_value, color_value, color_value),
        outline=(color_value, color_value, color_value),  # 使用相同的颜色作为边界，实现抗锯齿效果
    )

    return image

def generate_image_square(x_center, y_center, x_scale, y_scale, screen_width, screen_height, color_value):
    image = Image.new("RGB", (screen_width, screen_height), (0, 0, 0))
    draw = ImageDraw.Draw(image)
    x_center = x_center + screen_width/2
    y_center = y_center + screen_height / 2

    # 画一个白色的抗锯齿圆
    draw.rectangle(
        (
            x_center - x_scale*screen_width,
            y_center - y_scale*screen_height,
            x_center + x_scale*screen_width,
            y_center + y_scale*screen_height,
        ),
        fill=(color_value, color_value, color_value),
        outline=(color_value, color_value, color_value),  # 使用相同的颜色作为边界，实现抗锯齿效果
    )

    return image

def generate_image_for_sizes(size_list, color_list, save_path):
    glfw.init()
    second_monitor = glfw.get_monitors()[1]
    screen_width, screen_height = glfw.get_video_mode(second_monitor).size
    for size_value in size_list:
        for color_value in color_list:
            x_center, y_center = compute_x_y_from_eccentricity(eccentricity=0)
            x_scale, y_scale = compute_scale_from_degree(visual_degree=size_value)
            x_scale = x_scale / 2
            y_scale = y_scale / 2
            if size_value == "full":
                img = generate_image_square(x_center, y_center, x_scale, y_scale, screen_width, screen_height, color_value)
            else:
                img = generate_image_disk(x_center, y_center, x_scale, y_scale, screen_width, screen_height, color_value)
            img.save(os.path.join(save_path, f'Size_{size_value}_Color_{color_value}_stimulus.png'))

if __name__ == "__main__":
    size_list = [0.5, 1, 16, 'full']
    color_list = [25, 26, 35, 50, 178, 255] #满分是255
    save_path = 'Disk_Sizes_Colors'
    os.makedirs(save_path, exist_ok=True)
    generate_image_for_sizes(size_list=size_list, color_list=color_list, save_path=save_path)