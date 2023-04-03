import sys
import os
import math
import cv2

img_file = sys.argv[1]
dat_file_name = os.path.splitext(img_file)[0] + ".dat"

input_img = cv2.imread(img_file)

hsize_active = input_img.shape[1]
vsize_active = input_img.shape[0]

hsize_blank = math.floor(hsize_active * 0.1)
vsize_blank = math.floor(hsize_active * 0.05)

hsize_total = hsize_active + hsize_blank
vsize_total = vsize_active + vsize_blank

hblank = 0
vblank = 0
the_pixel_r = 0
the_pixel_g = 0
the_pixel_b = 0
fid = open(dat_file_name, "w")
for ii in range(0, vsize_total):
  if ii < vsize_active:
    vblank = 0
  else:
    vblank = 1
  for jj in range(0, hsize_total):
    if jj < hsize_active:
      hblank = 0
    else:
      hblank = 1
    
    #print(str(ii) + " " + str(jj) + " " + str(vblank) + " " + str(hblank))
    if ((not hblank) and (not vblank)):
      the_pixel_r = input_img[ii,jj,0]
      the_pixel_g = input_img[ii,jj,1]
      the_pixel_b = input_img[ii,jj,2]
    else:
      the_pixel_r = 0
      the_pixel_g = 0
      the_pixel_b = 0
    
    fid.write(str(vblank) + " " + str(hblank) + " " + 
              str(the_pixel_b) + " " + str(the_pixel_g) + " " + str(the_pixel_r) + " " + 
              "\n"
    )

fid.close()
