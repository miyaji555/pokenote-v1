from PIL import Image, ImageDraw
import os
import sys
import pandas as pd

# モジュールがあるディレクトリを追加
sys.path.append('../..')

from util import clear_directory, create_recursive_dir

def draw_bounding_boxes(image_path, label_path, output_path, classes):
    # 画像を読み込む
    image = Image.open(image_path)
    draw = ImageDraw.Draw(image)
    img_width, img_height = image.size

    # ラベルファイルを読み込む
    with open(label_path, 'r') as f:
        labels = f.readlines()

    # ラベルごとにバウンディングボックスを描画
    for label in labels:
        class_id, x_center, y_center, width, height = map(float, label.split())
        x_center *= img_width
        y_center *= img_height
        width *= img_width
        height *= img_height
        xmin = x_center - width / 2
        ymin = y_center - height / 2
        xmax = x_center + width / 2
        ymax = y_center + height / 2
        draw.rectangle(((xmin, ymin), (xmax, ymax)), outline="red", width=3)
        draw.text((xmin, ymin), classes[int(class_id)], fill="red")

    # 画像を保存または表示
    image.save(output_path)

# クラス名のリストを取得
spreadsheet_path = '../../学習ラベル.csv'
df = pd.read_csv(spreadsheet_path)
classes = list(set(df.poke_name.values))

# 出力ディレクトリのパス
output_annotation_path = "../output"
checked_image_path = "../output/checked"
clear_directory(checked_image_path)
create_recursive_dir(checked_image_path)

# 各画像に対してバウンディングボックスを描画
image_dir = os.path.join(output_annotation_path, 'image')
label_dir = os.path.join(output_annotation_path, 'labels')
for image_filename in os.listdir(image_dir):
    if image_filename.endswith('.png'):
        image_path = os.path.join(image_dir, image_filename)
        label_path = os.path.join(label_dir, image_filename.replace('.png', '.txt'))
        output_path = os.path.join(checked_image_path, image_filename)
        draw_bounding_boxes(image_path, label_path, output_path, classes)
