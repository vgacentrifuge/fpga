#include <verilated.h>

#include <iostream>

#include "Vpipeline_foreground_scale_1080.h"
#include "control.h"
#include "png_helper.h"

Vpipeline_foreground_scale_1080 *scaler;

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

void do_scale_overlay_run(Image *background, Image *foreground,
                  const std::string output_file, int fg_offset_x,
                  int fg_offset_y, mode_scale_t scale_mode) {
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

            PixelRGBA pix;
            if (fg_active) {
                foreground->get_rgba(fg_x, fg_y, pix);
            } else {
                background->get_rgba(x, y, pix);
            }

            output.set_rgba(x, y, pix);
        }
    }

    std::cout << "Saving output to " << output_file << std::endl;
    write_image(output, output_file);
}

int main(int argc, char const *argv[]) {
    Verilated::commandArgs(argc, argv);
    scaler = new Vpipeline_foreground_scale_1080;

    Image *background = load_image("test/images/test_bg.png");
    Image *foreground = load_image("test/images/test_fg.png");

    // First 6 are all with fully-opaque foreground, so normal overlay
    do_scale_overlay_run(background, foreground, "test_scale_full.png", 0, 0,
                 MODE_SCALE_FULL);
    do_scale_overlay_run(background, foreground, "test_scale_half.png", 0, 0,
                 MODE_SCALE_HALF);
    do_scale_overlay_run(background, foreground, "test_scale_quarter.png", 0, 0,
                 MODE_SCALE_QUARTER);

    do_scale_overlay_run(background, foreground, "test_scale_offset_1.png", 100, 100,
                 MODE_SCALE_HALF);
    do_scale_overlay_run(background, foreground, "test_scale_offset_2.png", -200, -200,
                 MODE_SCALE_HALF);
    do_scale_overlay_run(background, foreground, "test_scale_offset_3.png", 500, -100,
                 MODE_SCALE_HALF);

    scaler->final();

    delete scaler;
    delete background;
    delete foreground;

    return 0;
}
