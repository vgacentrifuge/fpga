#include <verilated.h>

#include <iostream>

#include "Vpipeline_foreground_overlay.h"
#include "Vpipeline_foreground_scale_1080.h"
#include "mode_helper.h"
#include "png_helper.h"

Vpipeline_foreground_scale_1080 *scaler;
Vpipeline_foreground_overlay *overlay;

void get_foreground_position(int &fg_x, int &fg_y, bool &fg_active, int bg_x,
                             int bg_y) {
    scaler->clk = 0;
    scaler->eval();

    scaler->pixel_x = bg_x;
    scaler->pixel_y = bg_y;
    scaler->clk = 1;
    scaler->eval();

    fg_x = scaler->fg_pixel_x;
    fg_y = scaler->fg_pixel_y;
    fg_active = scaler->fg_active;
}

void do_scale_run(Image *background, Image *foreground,
                  const std::string output_file, int fg_offset_x,
                  int fg_offset_y, int scale_mode) {
    if (background->getWidth() != foreground->getWidth() ||
        background->getHeight() != foreground->getHeight()) {
        std::cout << "Images must be the same size" << std::endl;
        exit(EXIT_FAILURE);
    }

    scaler->ctrl_foreground_scale = scale_mode;
    scaler->fg_offset_x = fg_offset_x;
    scaler->fg_offset_y = fg_offset_y;

    Image output(background->getWidth(), background->getHeight());

    for (int y = 0; y < output.getHeight(); y++) {
        for (int x = 0; x < output.getWidth(); x++) {
            int fg_x, fg_y;
            bool fg_active;

            get_foreground_position(fg_x, fg_y, fg_active, x, y);

            PixelRGB bg_pixel;
            PixelRGB fg_pixel = {0, 0, 0};
            background->get_rgb(x, y, bg_pixel);

            if (fg_active) {
                foreground->get_rgb(fg_x, fg_y, fg_pixel);
            }

            overlay->bg_pixel_in =
                RGB_TO_PIX(bg_pixel.r, bg_pixel.g, bg_pixel.b);
            overlay->fg_pixel_in =
                RGB_TO_PIX(fg_pixel.r, fg_pixel.g, fg_pixel.b);
            overlay->enable = fg_active;
            overlay->eval();

            uint8_t r = PIX_TO_R(overlay->pixel_out);
            uint8_t g = PIX_TO_G(overlay->pixel_out);
            uint8_t b = PIX_TO_B(overlay->pixel_out);

            output.set_rgba(x, y, {r, g, b, 255});
        }
    }

    write_image(output, output_file);
}

int main(int argc, char const *argv[]) {
    Verilated::commandArgs(argc, argv);
    scaler = new Vpipeline_foreground_scale_1080;
    overlay = new Vpipeline_foreground_overlay;

    Image *background = load_rgb_image("test/images/test_bg.png");
    Image *foreground = load_rgb_image("test/images/test_fg.png");

    do_scale_run(background, foreground, "test_scale_full.png", 0, 0,
                 MODE_SCALE_FULL);
    do_scale_run(background, foreground, "test_scale_half.png", 0, 0,
                 MODE_SCALE_HALF);
    do_scale_run(background, foreground, "test_scale_quarter.png", 0, 0,
                 MODE_SCALE_QUARTER);

    do_scale_run(background, foreground, "test_scale_offset_1.png", 100, 100,
                 MODE_SCALE_HALF);
    do_scale_run(background, foreground, "test_scale_offset_2.png", -200, -200,
                 MODE_SCALE_HALF);
    do_scale_run(background, foreground, "test_scale_offset_3.png", 500, -100,
                 MODE_SCALE_HALF);

    scaler->final();
    overlay->final();

    delete scaler;
    delete overlay;
    delete background;
    delete foreground;

    return 0;
}
