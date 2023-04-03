import sys
import os
import math
import numpy
import cv2

img_file = sys.argv[1]

for arg_idx in range(1,len(sys.argv)):
  result_file_name = sys.argv[arg_idx]
  basename = os.path.basename(result_file_name)
  basename_noext = os.path.splitext(basename)[0]

  orig_img = cv2.imread("test/" + basename_noext + ".png")
  result_img = numpy.zeros(orig_img.shape, dtype="uint8")

  fid = open(result_file_name, "r")
  for ii in range(0, orig_img.shape[0]):
    for jj in range(0, orig_img.shape[1]):
      line = fid.readline()
      the_pixel_b = line.split()[0]
      the_pixel_g = line.split()[1]
      the_pixel_r = line.split()[2]

      result_img[ii,jj,2] = the_pixel_r
      result_img[ii,jj,1] = the_pixel_g
      result_img[ii,jj,0] = the_pixel_b
  
  cv2.imshow(basename_noext + ".png", orig_img)
  cv2.imshow(basename, result_img)
  cv2.waitKey(0)

  cv2.destroyAllWindows()
  fid.close()
  
