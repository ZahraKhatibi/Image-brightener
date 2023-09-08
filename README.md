# Image Brightener

**Image Brightener** is an assembly language program that brightens or darkens a folder of images. It takes as input the path to a directory and an integer `n`. The program processes only valid BMP files in the specified directory, which must be in the Windows or OS/2 format and have a color depth of 24 bits. It brightens the images by incrementing the pixel values by `n` (considering contiguous bytes representing pixel data) in parallel. The modified images, retaining their original names, are saved in a new directory named `edited_photos` within the same location.
