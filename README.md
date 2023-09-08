# Image Brightener
![ ](pic.jpg)

**Image Brightener** is an assembly language program that brightens or darkens a folder of images. It takes as input the path to a directory and an integer `n`. 
The program processes only valid BMP files in the specified directory, which must be in the Windows or OS/2 format and have a color depth of 24 bits. It brightens the images by incrementing the pixel values by `n` (considering contiguous bytes representing pixel data) in parallel. The modified images, retaining their original names, are saved in a new directory named `edited_photos` within the same location.


## Table of Contents

- [File Structure](#file-structure)
- [Usage](#usage)
- [Functions](#functions)

## File Structure

- **sys-equal.asm:** This file contains macros for system call constants, which are used for system calls throughout the code.

- **in_out.asm:** This file contains input and output functions for reading strings and numbers from the console.

- **main.asm:** This is the main code file that performs various image processing tasks.

## Usage

To use this code, follow these steps:

1. Compile the code using your preferred assembler and linker.
2. Execute the compiled binary.
3. The code will prompt you to input file paths and other necessary information for image processing.

## Functions

### `new_name`

This macro is used for generating new file names based on the given paths and file names. It combines paths and file names to create new paths for edited images.

### `read_string`

This function reads a string from the console and stores it in the `path` variable. It also ensures the string is null-terminated.

### `create_folder`

This function creates a new folder using the specified `new_path` variable.

### `read_folder`

This function reads files from a folder specified by `path` and processes each image file found.

### `open_file`

This function opens an image file for processing. It reads the file's header and determines the image's format (Windows BMP or other). It then reads the image's pixel data and applies editing operations.

### `read_photo_pixel`

This function reads and processes individual pixels in an image.

### `find_index`

This function calculates an index for accessing pixel data in the `pixel_list` array.

### `lighter`

This function applies a lightening effect to an image.

### `exit`

This function terminates the program.
