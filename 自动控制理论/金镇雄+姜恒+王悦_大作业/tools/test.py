from paddlex.cls import transforms
import paddlex
import cv2
import os

# train_transforms = transforms.Compose([
#     transforms.RandomCrop(crop_size=224),
#     transforms.Normalize()
# ])
#
# model = paddlex.load_model('w/epoch_20')
# path = './data/test/'
# for name in os.listdir(path):
#     img = cv2.imread(path+name)
#     result = model.predict(img, topk=1, transforms=train_transforms)
#     print(f"{name}:", result)


# direction = ['left', 'right', 'up', 'down', 'pause']
# template = [cv2.imread(f'./data/test/saved_{i}.png', cv2.IMREAD_GRAYSCALE) for i in range(5)]
# path = './data/left/'
# for name in os.listdir(path):
#     img = cv2.imread(path+name, cv2.IMREAD_GRAYSCALE)
#     max_type = 4
#     max_all = 0
#     for i in range(5):
#         res = cv2.matchTemplate(img, template[i], cv2.TM_CCOEFF_NORMED)
#         min_val, max_val, min_loc, max_loc = cv2.minMaxLoc(res)
#         if max_val > max_all:
#             max_all = max_val
#             max_type = i
#     print(f'{name}:{direction[max_type]}')

