#include <verilated.h>

#include <iostream>

#include "../include/png_helper.h"
#include "Vpipeline_mode_chroma_key.h"

Vpipeline_mode_chroma_key *top;

void run_pixel(Image &output, Image *bg, Image *fg, int x, int y) {
    PixelRGB bg_pixel;
    PixelRGB fg_pixel;

    bg->get_rgb(x, y, bg_pixel);
    fg->get_rgb(x, y, fg_pixel);

    top->fg_pixel_ready = 1;
    top->bg_pixel_in = RGB_TO_PIX(bg_pixel.r, bg_pixel.g, bg_pixel.b);
    top->fg_pixel_in = RGB_TO_PIX(fg_pixel.r, fg_pixel.g, fg_pixel.b);
    top->eval();

    if (top->use_fg_pixel) {
        output.set_rgba(x, y, {fg_pixel.r, fg_pixel.g, fg_pixel.b, 255});
    } else {
        output.set_rgba(x, y, {bg_pixel.r, bg_pixel.g, bg_pixel.b, 255});
    }
}

void run_test_pair(const std::string &bg_file, const std::string &fg_file,
                   const std::string &output_file) {
    Image *background = load_rgb_image(bg_file);
    Image *foreground = load_rgb_image(fg_file);

    if (background->getWidth() != foreground->getWidth() ||
        background->getHeight() != foreground->getHeight()) {
        std::cout << "Images must be the same size" << std::endl;
        exit(EXIT_FAILURE);
    }

    top->ctrl_green_screen_filter = 0b0010010110001100;

    Image output(background->getWidth(), background->getHeight());

    for (int y = 0; y < output.getHeight(); y++) {
        for (int x = 0; x < output.getWidth(); x++) {
            run_pixel(output, background, foreground, x, y);
        }
    }

    std::cout << "Saving output to " << output_file << std::endl;
    write_image(output, output_file);

    delete background;
    delete foreground;
}

int main(int argc, char **argv) {
    Verilated::commandArgs(argc, argv);

    top = new Vpipeline_mode_chroma_key;

    run_test_pair("test/images/test_bg.png", "test/images/test_fg.png",
                  "test_chroma_key.png");

    top->final();
    delete top;
}
