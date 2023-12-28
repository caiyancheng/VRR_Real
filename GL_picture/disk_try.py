from PIL import Image, ImageDraw
import glfw


def generate_image(circle_radius, screen_width, screen_height):
    image = Image.new("RGB", (screen_width, screen_height), (0, 0, 0))
    draw = ImageDraw.Draw(image)

    # 计算圆心坐标
    circle_center = (screen_width // 2, screen_height // 2)

    # 画一个白色的抗锯齿圆
    draw.ellipse(
        (
            circle_center[0] - circle_radius,
            circle_center[1] - circle_radius,
            circle_center[0] + circle_radius,
            circle_center[1] + circle_radius,
        ),
        fill=(255, 255, 255),
        outline=(255, 255, 255),  # 使用相同的颜色作为边界，实现抗锯齿效果
    )

    return image

if __name__ == "__main__":
    glfw.init()
    second_monitor = glfw.get_monitors()[1]
    screen_width, screen_height = glfw.get_video_mode(second_monitor).size
    circle_radius = 100
    img = generate_image(circle_radius, screen_width, screen_height)

    # 保存图像
    img.save("output_image.png")
    # img.show()
