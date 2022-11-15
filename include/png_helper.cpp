#include "png_helper.h"

#include <iostream>

#include "lodepng.h"

Image::Image(unsigned int width, unsigned int height)
    : width(width), height(height) {
    data.resize(width * height * 4);
}

Image::Image(unsigned int width, unsigned int height, std::vector<uint8_t> data)
    : width(width), height(height), data(data) {}

int Image::getWidth() { return width; }
int Image::getHeight() { return height; }
std::vector<uint8_t> Image::getData() { return data; }

void Image::get_rgb(unsigned int x, unsigned int y, PixelRGB &pixel) {
    unsigned int index = (y * width + x) * 3;
    pixel.r = data[index + 0];
    pixel.g = data[index + 1];
    pixel.b = data[index + 2];
}

void Image::get_rgba(unsigned int x, unsigned int y, PixelRGBA &pixel) {
    unsigned int index = (y * width + x) * 4;
    pixel.r = data[index + 0];
    pixel.g = data[index + 1];
    pixel.b = data[index + 2];
    pixel.a = data[index + 3];
}

void Image::set_rgb(unsigned int x, unsigned int y, PixelRGB pixel) {
    unsigned int index = (y * width + x) * 3;
    data[index + 0] = pixel.r;
    data[index + 1] = pixel.g;
    data[index + 2] = pixel.b;
}

void Image::set_rgba(unsigned int x, unsigned int y, PixelRGBA pixel) {
    unsigned int index = (y * width + x) * 4;
    data[index + 0] = pixel.r;
    data[index + 1] = pixel.g;
    data[index + 2] = pixel.b;
    data[index + 3] = pixel.a;
}

void write_image(Image &image, const std::string &filename) {
    unsigned error = lodepng::encode("output/" + filename, image.getData(),
                                     image.getWidth(), image.getHeight());

    if (error) {
        std::cout << "encoder error " << error << ": "
                  << lodepng_error_text(error) << std::endl;
    }
}

Image *load_image(const std::string &filename) {
    std::vector<uint8_t> image;  // the raw pixels
    unsigned width, height;

    unsigned error = lodepng::decode(image, width, height, filename);

    // if there's an error, display it
    if (error) {
        std::cout << "decoder error " << error << ": "
                  << lodepng_error_text(error) << std::endl;
        exit(EXIT_FAILURE);
    }

    return new Image(width, height, image);
}

Image *load_rgb_image(const std::string &filename) {
    Image *loaded = load_image(filename);
    Image *converted = convert_rgba_to_rgb(*loaded);
    delete loaded;
    return converted;
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

Image *convert_rgba_to_rgb(Image &image_data) {
    Image *image = new Image(image_data.getWidth(), image_data.getHeight());

    for (int y = 0; y < image_data.getHeight(); y++) {
        for (int x = 0; x < image_data.getWidth(); x++) {
            PixelRGBA pixel;
            image_data.get_rgba(x, y, pixel);
            PixelRGB pixel_rgb;
            blend_pixel(pixel.r, pixel.g, pixel.b, pixel.a, pixel_rgb.r,
                        pixel_rgb.g, pixel_rgb.b);

            image->set_rgb(x, y, pixel_rgb);
        }
    }

    return image;
}