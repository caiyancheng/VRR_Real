import numpy as np
from PIL import Image
from tqdm import tqdm
import os

# 自定义函数显示编码工具（根据你的实现）
from display_encoding import display_encode
display_encode_tool = display_encode(400)

# 参数设置
resolution = 200  # 正方形分辨率
average_luminance = np.array([100])  # 顶尖亮度
fps = 120  # 动画帧率
duration = 2  # 总时长 (秒)
contrast = 0.05  # 固定对比度
frequencies = [1, 2, 4, 8, 16, 32]  # 刷新率 (Hz)
num_frames = int(duration * fps)  # 总帧数
output_dir = "refresh_rate_gifs"  # 输出目录

# 创建输出目录
os.makedirs(output_dir, exist_ok=True)

# 为每种刷新率生成 GIF
for frequency in frequencies:
    # 初始化图像列表
    images = []
    for frame_idx in tqdm(range(num_frames), desc=f"Generating GIF for {frequency}Hz"):
        luminance_bright = average_luminance * (1 + contrast)
        luminance_dark = average_luminance * (1 - contrast)
        color_bright = int(display_encode_tool.L2C_sRGB(luminance_bright) * 255)
        color_dark = int(display_encode_tool.L2C_sRGB(luminance_dark) * 255)

        if (frame_idx // (fps // (frequency * 2))) % 2 == 0:  # 亮帧
            square = np.full((resolution, resolution), color_bright, dtype=np.uint8)
        else:  # 暗帧
            square = np.full((resolution, resolution), color_dark, dtype=np.uint8)

        images.append(Image.fromarray(square, mode="L"))

    # 保存动画为 GIF
    output_path_gif = os.path.join(output_dir, f"flashing_{frequency}Hz.gif")
    frame_duration = int(1000 / fps)  # 每帧持续时间 (ms)

    images[0].save(
        output_path_gif,
        save_all=True,
        append_images=images[1:],
        optimize=True,
        duration=frame_duration,
        loop=0
    )

    print(f"GIF 保存完成: {output_path_gif}")

print("所有 GIF 已生成并保存到目录:", output_dir)
