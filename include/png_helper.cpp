#include "png_helper.h"

#include <iostream>

#include "lodepng.h"

// g++ lodepng.cpp example_decode.cpp -ansi -pedantic -Wall -Wextra -O3

void write_image(Image &image, const std::string &filename) {
    unsigned error =
        lodepng::encode(filename, image.data, image.width, image.height);

    if (error) {
        std::cout << "encoder error " << error << ": "
                  << lodepng_error_text(error) << std::endl;
    }
}

void load_image(Image &image_data, const std::string &filename) {
    std::vector<uint8_t> image;  // the raw pixels
    unsigned width, height;

    unsigned error = lodepng::decode(image, width, height, filename);

    // if there's an error, display it
    if (error) {
        std::cout << "decoder error " << error << ": "
                  << lodepng_error_text(error) << std::endl;
        exit(EXIT_FAILURE);
    }

    // the pixels are now in the vector "image", 4 bytes per pixel, ordered
    // RGBARGBA
    image_data.width = width;
    image_data.height = height;
    image_data.data = image;
}

void blend_pixel(uint8_t r, uint8_t g, uint8_t b, uint8_t a, uint8_t &r_out,
                 uint8_t &g_out, uint8_t &b_out) {
    float alpha = a / 255.0f;
    r_out =
        (uint8_t)(((r / 255.0f) * alpha + BASE_COLOR_R * (1.0f - alpha)) * 255);
    g_out =
        (uint8_t)(((g / 255.0f) * alpha + BASE_COLOR_G * (1.0f - alpha)) * 255);
    b_out =
        (uint8_t)(((b / 255.0f) * alpha + BASE_COLOR_B * (1.0f - alpha)) * 255);
}

void convert_rgba_to_rgb(Image &image_data) {
    std::vector<uint8_t> rgb_image;
    rgb_image.resize(image_data.width * image_data.height * 3);

    for (int i = 0; i < image_data.width * image_data.height; i++) {
        blend_pixel(image_data.data[i * 4 + 0], image_data.data[i * 4 + 1],
                    image_data.data[i * 4 + 2], image_data.data[i * 4 + 3],
                    rgb_image[i * 3 + 0], rgb_image[i * 3 + 1],
                    rgb_image[i * 3 + 2]);
    }

    image_data.data = rgb_image;
}