from moviepy.editor import VideoFileClip

# 输入MP4文件名和输出GIF文件名
input_mp4 = r"E:\About_Cambridge\All Research Projects\Variable Refresh Rate/VRR_flicker.mp4"
output_gif = r"E:\About_Cambridge\All Research Projects\Variable Refresh Rate/VRR_flicker.gif"

# 打开MP4文件
clip = VideoFileClip(input_mp4)

# 将视频保存为GIF文件
clip.write_gif(output_gif, fps=240)
