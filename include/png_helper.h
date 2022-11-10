#ifndef PNG_HELPER_H
#define PNG_HELPER_H

#include <string>
#include <vector>
#include <cstdint>

#define BASE_COLOR_R 1.0f
#define BASE_COLOR_G 1.0f
#define BASE_COLOR_B 1.0f

#define RGB_TO_PIX(r, g, b) \
    (((r & 0xF8) << 8) | ((g & 0xFC) << 3) | ((b & 0xF8) >> 3))
#define PIX_TO_R(pixel) ((pixel >> 8) & 0xF8)
#define PIX_TO_G(pixel) ((pixel >> 3) & 0xFC)
#define PIX_TO_B(pixel) ((pixel << 3) & 0xF8)

struct Image {
    unsigned int width;
    unsigned int height;
    std::vector<uint8_t> data;
};

// g++ lodepng.cpp example_decode.cpp -ansi -pedantic -Wall -Wextra -O3

void write_image(Image &image, const std::string &filename);

void load_image(Image &image_data, const std::string &filename);

void convert_rgba_to_rgb(Image &image_data);

#endif
