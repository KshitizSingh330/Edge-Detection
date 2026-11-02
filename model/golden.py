import numpy as np
from PIL import Image
import matplotlib.pyplot as plt
import sys
import os

# --- 1. Constants & Kernels ---
K_GAUSS = [[1, 2, 1], [2, 4, 2], [1, 2, 1]]
K_SX    = [[-1, 0, 1], [-2, 0, 2], [-1, 0, 1]]
K_SY    = [[-1, -2, -1], [0, 0, 0], [1, 2, 1]]

# --- 2. Core Functions ---
def rgb2gray(rgb):                      
    r, g, b = [rgb[:, :, i].astype(np.int32) for i in range(3)]
    return ((77*r + 150*g + 29*b) >> 8).astype(np.uint8)

def conv3x3(img, k):
    H, W = img.shape
    # Pad the image by 1 pixel on all sides by replicating the edge pixels
    p = np.pad(img, pad_width=1, mode='edge').astype(np.int32)
    out = np.zeros((H, W), dtype=np.int32)
    
    for y in range(H):
        for x in range(W):
            s = 0
            for dy in range(3):
                for dx in range(3):
                    s += k[dy][dx] * p[y+dy, x+dx]
            out[y, x] = s
    return out

def pipeline(rgb, thr):
    gray = rgb2gray(rgb)
    blur = (conv3x3(gray, K_GAUSS) >> 4).astype(np.uint8)
    gx   = conv3x3(blur, K_SX)
    gy   = conv3x3(blur, K_SY)
    mag  = np.minimum(np.abs(gx) + np.abs(gy), 255).astype(np.uint8)
    edge = np.where(mag > thr, 255, 0).astype(np.uint8)
    return gray, blur, mag, edge

# --- 3. Hex Writing Functions ---
def write_hex(path, arr, digits=2):
    with open(path, 'w') as f:
        for v in arr.flatten():
            f.write(format(int(v), f'0{digits}X') + '\n')

def write_rgb_hex(path, rgb):
    with open(path, 'w') as f:
        for r, g, b in rgb.reshape(-1, 3):
            f.write(f'{r:02X}{g:02X}{b:02X}\n')

# --- 4. Main Execution ---
if __name__ == "__main__":
    # Safely handle arguments with a fallback
    if len(sys.argv) >= 3:
        name = sys.argv[1]
        thr = int(sys.argv[2])
    else:
        name = 'square'  # Default image if no arguments provided
        thr = 60         # Default threshold

    # Load image and run pipeline
    image_path = f'../images/{name}.png'
    if not os.path.exists(image_path):
        print(f"Error: Could not find '{image_path}'")
        sys.exit(1)
        
    rgb = np.array(Image.open(image_path).convert('RGB'))
    gray, blur, mag, edge = pipeline(rgb, thr)

    # Create folder and save hex files
    os.makedirs('vectors', exist_ok=True)
    write_rgb_hex(f'vectors/{name}_rgb.hex', rgb)
    for tag, arr in [('gray', gray), ('blur', blur), ('mag', mag), ('edge', edge)]:
        write_hex(f'vectors/{name}_{tag}.hex', arr)
    print(f"Success! Vectors saved in 'vectors' folder for image: {name}")

    # Display the visual plot
    fig, ax = plt.subplots(1, 5, figsize=(15, 3))
    for a, im, t in zip(ax, [rgb, gray, blur, mag, edge],
                        ['rgb', 'gray', 'blur', 'mag', 'edge']):
        a.imshow(im, cmap=None if im.ndim == 3 else 'gray', vmin=0, vmax=255)
        a.set_title(t)
        a.axis('off')
    plt.show()