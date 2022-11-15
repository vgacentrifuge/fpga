#ifndef PNG_HELPER_H
#define PNG_HELPER_H

#include <cstdint>
#include <string>
#include <vector>

#define BASE_COLOR_R 1.0f
#define BASE_COLOR_G 1.0f
#define BASE_COLOR_B 1.0f

#define RGB_TO_PIX(r, g, b) \
    (((r & 0xF8) << 8) | ((g & 0xFC) << 3) | ((b & 0xF8) >> 3))
#define PIX_TO_R(pixel) ((pixel >> 8) & 0xF8)
#define PIX_TO_G(pixel) ((pixel >> 3) & 0xFC)
#define PIX_TO_B(pixel) ((pixel << 3) & 0xF8)

struct PixelRGB {
    uint8_t r;
    uint8_t g;
    uint8_t b;
};

struct PixelRGBA {
    uint8_t r;
    uint8_t g;
    uint8_t b;
    uint8_t a;
};

class Image {
   private:
    const unsigned int width;
    const unsigned int height;
    std::vector<uint8_t> data;

   public:
    Image(unsigned int width, unsigned int height);
    Image(unsigned int width, unsigned int height, std::vector<uint8_t> data);
    int getWidth();
    int getHeight();
    std::vector<uint8_t> getData();
    void get_rgb(unsigned int x, unsigned int y, PixelRGB &pixel);
    void get_rgba(unsigned int x, unsigned int y, PixelRGBA &pixel);
    void set_rgb(unsigned int x, unsigned int y, PixelRGB pixel);
    void set_rgba(unsigned int x, unsigned int y, PixelRGBA pixel);
};

void write_image(Image &image, const std::string &filename);

Image *load_image(const std::string &filename);

Image *load_rgb_image(const std::string &filename);

Image *convert_rgba_to_rgb(Image &image_data);

#endif
