import numpy as np
import cv2

path = r'./image.jpg'
image = cv2.imread(path, 1)
image_gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
image_resize = cv2.resize(image_gray, (32, 31))
for i in range(31):
    if i == 1 or i == 3 or i == 5 or i == 7 or i == 9 or i == 11 or i == 13 or i == 15 or i == 17 or i == 19 or i == 21 or i == 23 or i == 25 or i == 27 or i == 29:
        for j in range(32):
            if j == 0 or j == 31:
                image_resize[i][j] = image_resize[i-1][j]/2 + image_resize[i+1][j]/2
            else:
                if image_resize[i-1][j-1] >= image_resize[i+1][j+1]:
                    D1 = image_resize[i-1][j-1] - image_resize[i+1][j+1]
                else:
                    D1 = image_resize[i+1][j+1] - image_resize[i-1][j-1]
                    
                if image_resize[i-1][j] >= image_resize[i+1][j]:
                    D2 = image_resize[i-1][j] - image_resize[i+1][j]
                else:
                    D2 = image_resize[i+1][j] - image_resize[i-1][j]
                    
                if image_resize[i-1][j+1] >= image_resize[i+1][j-1]:
                    D3 = image_resize[i-1][j+1] - image_resize[i+1][j-1]
                else:
                    D3 = image_resize[i+1][j-1] - image_resize[i-1][j+1]
                    
                if D2 <= D1 and D2 <= D3:
                    image_resize[i][j] = image_resize[i-1][j]/2 + image_resize[i+1][j]/2
                elif D1 <= D2 and D1 <= D3:
                    image_resize[i][j] = image_resize[i-1][j-1]/2 + image_resize[i+1][j+1]/2
                else:
                    image_resize[i][j] = image_resize[i-1][j+1]/2 + image_resize[i+1][j-1]/2
image_delete = np.delete(image_resize, [1, 3, 5, 7, 9, 11, 13, 15, 17, 19, 21, 23, 25, 27, 29], axis = 0)

img = open('img.dat', 'w')
for i in range(16):
    for j in range(32):
        img.write(str(format(image_delete[i][j], 'x')) + '\n')
img.close()

golden = open('golden.dat', 'w')
for i in range(31):
    for j in range(32):
        golden.write(str(format(image_resize[i][j], 'x')) + '\n')
golden.close()

