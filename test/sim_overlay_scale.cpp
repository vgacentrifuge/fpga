#include <iostream>

#include "Vpipeline_foreground_overlay.h"
#include "Vpipeline_foreground_scale_1080.h"
#include "png_helper.h"

#define MODE_SCALE_FULL 0b11
#define MODE_SCALE_HALF 0b10
#define MODE_SCALE_QUARTER 0b01

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

void do_scale_run(Image &background, Image &foreground,
                  const std::string output_file, int fg_offset_x,
                  int fg_offset_y, int scale_mode) {
    if (background.width != foreground.width ||
        background.height != foreground.height) {
        std::cout << "Images must be the same size" << std::endl;
        exit(EXIT_FAILURE);
    }

    scaler->ctrl_foreground_scale = scale_mode;
    scaler->fg_offset_x = fg_offset_x;
    scaler->fg_offset_y = fg_offset_y;

    Image output;
    output.width = background.width;
    output.height = background.height;
    output.data.resize(output.width * output.height * 4);

    for (int y = 0; y < background.height; y++) {
        for (int x = 0; x < background.width; x++) {
            int fg_x, fg_y;
            bool fg_active;

            get_foreground_position(fg_x, fg_y, fg_active, x, y);

            int index = (y * background.width + x) * 3;
            uint8_t bg_r = background.data[index + 0];
            uint8_t bg_g = background.data[index + 1];
            uint8_t bg_b = background.data[index + 2];

            uint8_t fg_r, fg_g, fg_b;
            if (fg_active) {
                index = (fg_y * foreground.width + fg_x) * 3;
                fg_r = foreground.data[index + 0];
                fg_g = foreground.data[index + 1];
                fg_b = foreground.data[index + 2];
            } else {
                fg_r = 0;
                fg_g = 0;
                fg_b = 0;
            }

            overlay->bg_pixel_in = RGB_TO_PIX(bg_r, bg_g, bg_b);
            overlay->fg_pixel_in = RGB_TO_PIX(fg_r, fg_g, fg_b);
            overlay->enable = fg_active;
            overlay->eval();

            uint8_t r = PIX_TO_R(overlay->pixel_out);
            uint8_t g = PIX_TO_G(overlay->pixel_out);
            uint8_t b = PIX_TO_B(overlay->pixel_out);

            index = (y * background.width + x) << 2;
            output.data[index + 0] = r;
            output.data[index + 1] = g;
            output.data[index + 2] = b;
            output.data[index + 3] = 255;
        }
    }

    write_image(output, output_file);
}

int main(int argc, char const *argv[]) {
    Verilated::commandArgs(argc, argv);
    scaler = new Vpipeline_foreground_scale_1080;
    overlay = new Vpipeline_foreground_overlay;

    Image background;
    Image foreground;
    load_rgb_image(background, "test/images/test_bg.png");
    load_rgb_image(foreground, "test/images/test_fg.png");

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
    return 0;
}
