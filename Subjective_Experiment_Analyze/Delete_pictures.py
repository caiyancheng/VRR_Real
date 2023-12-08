import os


def delete_png_files(folder_path):
    try:
        # 遍历文件夹中的所有文件和子文件夹
        for root, dirs, files in os.walk(folder_path):
            for file in files:
                # 检查文件是否以.png结尾
                if file.endswith(".png"):
                    # 构造文件的完整路径
                    file_path = os.path.join(root, file)

                    # 删除文件
                    os.remove(file_path)
                    print(f"Deleted: {file_path}")

        print("Deletion of .png files completed.")
    except Exception as e:
        print(f"An error occurred: {e}")


# 调用函数并传入文件夹路径
folder_path = r"E:\Py_codes\VRR_Real\Subjective_Experiment_Analyze\Real_Luminance_Set"
delete_png_files(folder_path)
