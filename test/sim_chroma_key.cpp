#include <verilated.h>
#include <iostream>

#include "Vpipeline_chroma_key.h"
#include "../include/png_helper.h"

Vpipeline_chroma_key *top;

void run_pixel(Image& output, Image& bg, Image& fg, int x, int y) {
    int index = (y * bg.width + x) * 3;
    uint8_t bg_r = bg.data[index + 0];
    uint8_t bg_g = bg.data[index + 1];
    uint8_t bg_b = bg.data[index + 2];

    uint8_t fg_r = fg.data[index + 0];
    uint8_t fg_g = fg.data[index + 1];
    uint8_t fg_b = fg.data[index + 2];

    top->enable = 1;
    top->bg_pixel_in = RGB_TO_PIX(bg_r, bg_g, bg_b);
    top->fg_pixel_in = RGB_TO_PIX(fg_r, fg_g, fg_b);
    top->eval();

    uint8_t r = PIX_TO_R(top->pixel_out);
    uint8_t g = PIX_TO_G(top->pixel_out);
    uint8_t b = PIX_TO_B(top->pixel_out);

    index = (y * bg.width + x) << 2;
    output.data[index + 0] = r;
    output.data[index + 1] = g;
    output.data[index + 2] = b;
    output.data[index + 3] = 255;
}

void run_test_pair(const std::string &bg_file, const std::string &fg_file, const std::string &output_file) {
    Image background;
    Image foreground;
    Image output;
    load_rgb_image(background, bg_file);
    load_rgb_image(foreground, fg_file);

    if (background.width != foreground.width || background.height != foreground.height) {
        std::cout << "Images must be the same size" << std::endl;
        exit(EXIT_FAILURE);
    }

    output.width = background.width;
    output.height = background.height;
    output.data.resize(output.width * output.height * 4);

    for (int y = 0; y < background.height; y++) {
        for (int x = 0; x < background.width; x++) {
            run_pixel(output, background, foreground, x, y);
        }
    }

    std::cout << "Saving output to " << output_file << std::endl;
    write_image(output, output_file);
}

int main(int argc, char **argv) {
    Verilated::commandArgs(argc, argv);

    top = new Vpipeline_chroma_key;

    run_test_pair("test/images/test_bg.png", "test/images/test_fg.png", "output.png");

    top->final();
    delete top;
}
