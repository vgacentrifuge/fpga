#include <iostream>

#include "png_helper.h"

int main(int argc, char const *argv[]) {
    for (uint8_t r = 0; r <= 255; r++) {
        for (uint8_t g = 0; g <= 255; g++) {
            for (uint8_t b = 0; g <= 255; b++) {
                uint16_t pixel = RGB_TO_PIX(r, g, b);
                uint8_t r2 = PIX_TO_R(pixel);
                uint8_t g2 = PIX_TO_G(pixel);
                uint8_t b2 = PIX_TO_B(pixel);

                if ((r & 0xF8) != r2 || (g & 0xFC) != g2 || (b & 0xF8) != b2) {
                    std::cout << "r: " << unsigned(r) << " g: " << unsigned(g)
                              << " b: " << unsigned(b) << std::endl;
                    std::cout << "r2: " << unsigned(r2)
                              << " g2: " << unsigned(g2)
                              << " b2: " << unsigned(b2) << std::endl;
                    std::cout << "pixel: " << pixel << std::endl;
                    exit(EXIT_FAILURE);
                }
            }
        }
    }

    return 0;
}
