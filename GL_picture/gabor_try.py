import glfw
from OpenGL.GL import *
import numpy as np
import math

# 初始化窗口
glfw.init()
window = glfw.create_window(800, 800, "OpenGL Window", None, None)
glfw.make_context_current(window)

# 创建一个空白的纹理对象
texture_id = glGenTextures(1)
glBindTexture(GL_TEXTURE_2D, texture_id)

# 定义Gabor竖条纹的参数
texture_size = 512
frequency = 10.0  # 频率
sigma = 5.0  # 标准差
theta = 0.0  # 方向
x_center = y_center = 0
x_scale = y_scale = 0.4
num_segments = 100

# 计算Gabor竖条纹的像素值并上传到纹理
texture_data = np.empty((texture_size, texture_size), dtype=np.uint8)
for x in range(texture_size):
    for y in range(texture_size):
        x_prime = x - texture_size / 2
        y_prime = y - texture_size / 2
        x_rotated = x_prime * np.cos(theta) - y_prime * np.sin(theta)
        y_rotated = x_prime * np.sin(theta) + y_prime * np.cos(theta)
        value = np.exp(-0.5 * (x_rotated ** 2 / sigma ** 2 + y_rotated ** 2 / sigma ** 2)) * np.cos(
            2 * np.pi * frequency * x_rotated)
        value = int((value + 1.0) * 127.5)  # 缩放到0-255范围
        texture_data[y, x] = value

glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, texture_size, texture_size, 0, GL_RGBA, GL_UNSIGNED_BYTE, texture_data)
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR)
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)

# 渲染循环
while not glfw.window_should_close(window):
    glClear(GL_COLOR_BUFFER_BIT)

    # 使用纹理绘制圆盘
    glColor3f(1.0, 1.0, 1.0)  # 设置颜色为白色
    glEnable(GL_TEXTURE_2D)
    glBindTexture(GL_TEXTURE_2D, texture_id)

    glBegin(GL_TRIANGLE_FAN)
    glVertex2f(x_center, y_center)
    for i in range(num_segments + 1):
        theta = i * (2.0 * math.pi / num_segments)
        x = x_center + x_scale * math.cos(theta)
        y = y_center + y_scale * math.sin(theta)
        glTexCoord2f((x - x_center) / x_scale + 0.5, (y - y_center) / y_scale + 0.5)  # 映射纹理坐标到圆盘上
        glVertex2f(x, y)
    glEnd()

    glDisable(GL_TEXTURE_2D)

    glfw.swap_buffers(window)
    glfw.poll_events()

glfw.terminate()
