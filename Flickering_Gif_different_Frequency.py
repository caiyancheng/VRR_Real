import numpy as np
import matplotlib.pyplot as plt
from PIL import Image, ImageSequence, ImageDraw, ImageFont
from matplotlib.animation import FuncAnimation
import imageio
import imageio.v3 as iio
import os
from tqdm import tqdm
from display_encoding import display_encode
display_encode_tool = display_encode(400)

# 参数设置
resolution = 20  # 正方形分辨率
max_luminance = np.array([10])  # 顶尖亮度
max_color = int(display_encode_tool.L2C_sRGB(max_luminance) * 255)
duration_per_freq = 2  # 每个频率的持续时间 (秒)
start_freq = 8  # 起始频率 (Hz)
end_freq = 200  # 结束频率 (Hz)
fps = 1000  # 动画帧率
num_freqs = 20  # 频率数目

# 生成 logscale 的频率列表
frequencies = np.logspace(np.log10(start_freq), np.log10(end_freq), num_freqs)

# 创建亮黑方块图像
square_bright = np.full((resolution, resolution), max_color, dtype=np.uint8)
square_black = np.full((resolution, resolution), 0, dtype=np.uint8)
img_bright = Image.fromarray(square_bright, mode="L")
img_black = Image.fromarray(square_black, mode="L")

# 初始化图像列表
images = []
# 逐个频率生成闪烁周期
for freq in tqdm(frequencies, desc="Generating flashing cycles"):
    cycle_frames = int(fps / freq)  # 一个完整周期的帧数
    total_frames = int(duration_per_freq * fps)  # 当前频率的总帧数
    for frame in range(total_frames):
        if (frame // cycle_frames) % 2 == 0:
            images.append(img_bright)
        else:
            images.append(img_black)

# 保存动画为 GIF
output_path_gif = "flashing_square_discrete.gif"
frame_duration = int(1000 / fps)
images[0].save(
    output_path_gif,
    save_all=True,
    append_images=images[1:],
    optimize=True,
    duration=int(frame_duration),
    loop=0
)
print(f"GIF 保存完成: {output_path_gif}")

# 保存动画为 MP4
output_path_mp4 = "flashing_square_discrete.mp4"
with imageio.get_writer(output_path_mp4, fps=fps, codec='libx264', quality=9) as writer:
    for img in tqdm(images, desc="Writing MP4"):
        writer.append_data(np.array(img))
print(f"MP4 保存完成: {output_path_mp4}")
