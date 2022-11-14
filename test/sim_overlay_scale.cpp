#include <iostream>
#include <verilated.h>

#include "Vpipeline_foreground_overlay.h"
#include "Vpipeline_foreground_scale_1080.h"
#include "png_helper.h"

#define MODE_SCALE_FULL 0b11
#define MODE_SCALE_HALF 0b10
#define MODE_SCALE_QUARTER 0b01

Vpipeline_foreground_scale_1080 *scaler;
Vpipeline_foreground_overlay *overlay;

// Takes in a background coordinate and uses the scaler's logic to compute
// the corresponding foreground coordinate which will sit on top of the
// current background.
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

void do_scale_overlay_run(Image &background, Image &foreground,
                  const std::string output_file, int fg_offset_x,
                  int fg_offset_y, int scale_mode, int fg_opacity) {
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
            overlay->fg_opacity = fg_opacity; // In default case precision=3 so max val=7
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

    // First 6 are all with fully-opaque foreground, so normal overlay
    do_scale_overlay_run(background, foreground, "test_scale_full_100%.png", 0, 0,
                 MODE_SCALE_FULL, 7);
    do_scale_overlay_run(background, foreground, "test_scale_half_100%.png", 0, 0,
                 MODE_SCALE_HALF, 7);
    do_scale_overlay_run(background, foreground, "test_scale_quarter_100%.png", 0, 0,
                 MODE_SCALE_QUARTER, 7);

    do_scale_overlay_run(background, foreground, "test_scale_offset_1_100%.png", 100, 100,
                 MODE_SCALE_HALF, 7);
    do_scale_overlay_run(background, foreground, "test_scale_offset_2_100%.png", -200, -200,
                 MODE_SCALE_HALF, 7);
    do_scale_overlay_run(background, foreground, "test_scale_offset_3_100%.png", 500, -100,
                 MODE_SCALE_HALF, 7);

    // Here should be at 50% opacity
    do_scale_overlay_run(background, foreground, "test_scale_full_50%.png", 0, 0,
                 MODE_SCALE_FULL, 4);
    do_scale_overlay_run(background, foreground, "test_scale_half_50%.png", 0, 0,
                 MODE_SCALE_HALF, 4);
    do_scale_overlay_run(background, foreground, "test_scale_quarter_50%.png", 0, 0,
                 MODE_SCALE_QUARTER, 4);

    // Here should be at 25% opacity
    do_scale_overlay_run(background, foreground, "test_scale_full_25%.png", 0, 0,
                 MODE_SCALE_FULL, 2);
    do_scale_overlay_run(background, foreground, "test_scale_half_25%.png", 0, 0,
                 MODE_SCALE_HALF, 2);
    do_scale_overlay_run(background, foreground, "test_scale_quarter_25%.png", 0, 0,
                 MODE_SCALE_QUARTER, 2);

    // Here should be at 0% opacity
    do_scale_overlay_run(background, foreground, "test_scale_full_0%.png", 0, 0,
                 MODE_SCALE_FULL, 0);
    do_scale_overlay_run(background, foreground, "test_scale_half_0%.png", 0, 0,
                 MODE_SCALE_HALF, 0);
    do_scale_overlay_run(background, foreground, "test_scale_quarter_0%.png", 0, 0,
                 MODE_SCALE_QUARTER, 0);

    scaler->final();
    overlay->final();
    return 0;
}
