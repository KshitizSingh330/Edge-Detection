import numpy as np
from PIL import Image
H = W = 16
def save(name, arr):
  Image.fromarray(arr.astype(np.uint8), 'RGB').save(f'images/{name}.png')
# 1. white square on black: edges only on the square's outline
img = np.zeros((H, W, 3), np.uint8); img[16:48, 16:48] = 255
save('square', img)
# 2. horizontal gradient: smooth, so edges should be weak
grad = np.tile(np.linspace(0, 255, W), (H, 1))
save('gradient', np.stack([grad]*3, axis=2))
# 3. checkerboard of 8x8 blocks: edges everywhere, tests heavy activity
y, x = np.mgrid[0:H, 0:W]
chk = (((x // 8) + (y // 8)) % 2) * 255
save('checker', np.stack([chk]*3, axis=2))
# 4. pure random noise: tests blur and worst-case values
rng = np.random.default_rng(1)
save('noise', rng.integers(0, 256, (H, W, 3)))
# 5. a real photo: put any photo in images/photo_raw.jpg first
im = Image.open('images/image_1.jpg').convert('RGB').resize((W, H))
im.save('images/image_1.png')
# 6. pure black: tests lower bounds and zero-division errors
img_black = np.zeros((H, W, 3), np.uint8)
save('black', img_black)
# 7. pure white: tests upper bounds and overflow clipping
img_white = np.full((H, W, 3), 255, dtype=np.uint8)
save('white', img_white)