import pandas as pd
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras.applications import MobileNetV2
from tensorflow.keras.layers import Dense, Input,GlobalAveragePooling2D
from tensorflow.keras.models import Model

project_path = "."

# 生成元画像のパス
input_folder_path = project_path + "/../output"

# ラベルを読み込む
spreadsheet_path = project_path + '/学習ラベル.csv'
df = pd.read_csv(spreadsheet_path)

# 画像データジェネレータの設定
train_datagen = ImageDataGenerator(
    rescale=1./255,  # 画像の正規化のみ行う
    validation_split=0.2  # 20%を検証用に分割
)

# トレーニングデータジェネレータ
train_generator = train_datagen.flow_from_dataframe(
    dataframe=df,
    directory=input_folder_path,  # 画像ファイルのディレクトリを指定
    x_col='filename',  # 画像ファイル名が格納されている列名
    y_col='poke_name',  # ラベルが格納されている列名
    target_size=(224, 224),
    batch_size=32,
    class_mode='categorical',
    subset='training'
)

# 検証データジェネレータ
validation_generator = train_datagen.flow_from_dataframe(
    dataframe=df,
    directory=input_folder_path,  # 画像ファイルのディレクトリを指定
    x_col='filename',  # 画像ファイル名が格納されている列名
    y_col='poke_name',  # ラベルが格納されている列名
    target_size=(224, 224),
    batch_size=32,
    class_mode='categorical',
    subset='validation'
)
# ベースとなるモデルをロード
base_model = MobileNetV2(weights='imagenet', include_top=False, input_tensor=Input(shape=(224, 224, 3)))

# ベースモデルの出力に全結合層を追加する前にグローバル平均プーリング層を追加
x = base_model.output
x = GlobalAveragePooling2D()(x)  # 2D特徴マップを1Dベクトルに変換
x = Dense(1024, activation='relu')(x)
predictions = Dense(len(train_generator.class_indices), activation='softmax')(x)

# モデルを定義
model = Model(inputs=base_model.input, outputs=predictions)

# モデルのコンパイル
model.compile(optimizer='adam', loss='categorical_crossentropy', metrics=['accuracy'])

# モデルのトレーニング
model.fit(
    train_generator,
    epochs=10,
    validation_data=validation_generator
)

# モデルの保存
model.save('object_detection_model.h5')
