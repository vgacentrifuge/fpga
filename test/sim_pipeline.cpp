#include <verilated.h>

#include <iostream>
#include <queue>

#include "Vpipeline_1080.h"
#include "mode_helper.h"
#include "png_helper.h"

#define FOREGROUND_FETCH_DELAY 3
#define BLANKING_AREA_SIZE 50

Vpipeline_1080 *pipeline;

struct ForegroundRequest {
    int16_t x;
    int16_t y;
    bool active;
};

void run_image(Image *foreground, Image *background,
               const std::string output_file, uint8_t scale_mode,
               uint8_t overlay_mode, int16_t offset_x, int16_t offset_y) {
    if (background->getWidth() != foreground->getWidth() ||
        background->getHeight() != foreground->getHeight()) {
        std::cout << "Images must be the same size" << std::endl;
        exit(EXIT_FAILURE);
    }

    Image output(background->getWidth(), background->getHeight());

    // Constant for the entire run. Set them here, and then we don't need to
    // worry about them
    pipeline->ctrl_fg_scale = scale_mode;
    pipeline->ctrl_overlay_mode = overlay_mode;
    pipeline->ctrl_fg_offset_x = offset_x;
    pipeline->ctrl_fg_offset_y = offset_y;

    // Initialize a bunch of empty requests to start with
    std::queue<ForegroundRequest> foreground_requests;
    for (int i = 0; i < FOREGROUND_FETCH_DELAY; i++) {
        foreground_requests.push({0, 0, false});
    }

    PixelRGB bg_pixel, fg_pixel;
    uint16_t bg_pixel_in, fg_pixel_in, pixel_out;
    uint8_t r, g, b;
    ForegroundRequest fg_request;

    // Perform iterations for each pixel, including the blanking areas. For this
    // simulation we just define an arbitrary number of pixels that are blank.
    for (int y = 0; y < output.getHeight() + BLANKING_AREA_SIZE; y++) {
        for (int x = 0; x < output.getWidth() + BLANKING_AREA_SIZE; x++) {
            pipeline->clk = 0;
            pipeline->eval();

            pipeline->clk = 1;

            // Set the inputs for the current pixel
            pipeline->pixel_x = x;
            pipeline->pixel_y = y;

            bool blanking_area =
                x >= output.getWidth() || y >= output.getHeight();
            bg_pixel_in = 0;
            if (!blanking_area) {
                background->get_rgb(x, y, bg_pixel);
                bg_pixel_in = RGB_TO_PIX(bg_pixel.r, bg_pixel.g, bg_pixel.b);
            }

            pipeline->bg_pixel_in = bg_pixel_in;
            pipeline->output_enable = !blanking_area;

            // Get the current foreground request
            fg_request = foreground_requests.front();
            foreground_requests.pop();
            fg_pixel_in = 0;
            if (fg_request.active) {
                foreground->get_rgb(fg_request.x, fg_request.y, fg_pixel);
                fg_pixel_in = RGB_TO_PIX(fg_pixel.r, fg_pixel.g, fg_pixel.b);
            }

            pipeline->fg_pixel_in = fg_pixel_in;
            pipeline->fg_pixel_skip = !fg_request.active;

            pipeline->eval();

            // Get the output pixel
            pixel_out = pipeline->pixel_out;
            if (!blanking_area) {
                r = PIX_TO_R(pixel_out);
                g = PIX_TO_G(pixel_out);
                b = PIX_TO_B(pixel_out);
                output.set_rgba(x, y, {r, g, b, 255});
            }

            // Add the next foreground request
            foreground_requests.push({(int16_t)pipeline->fg_pixel_request_x,
                                      (int16_t)pipeline->fg_pixel_request_y,
                                      (bool)pipeline->fg_pixel_request_active});
        }
    }

    std::cout << "Writing output to file " << output_file << std::endl;
    write_image(output, output_file);
}

int main(int argc, char const *argv[]) {
    Verilated::commandArgs(argc, argv);

    pipeline = new Vpipeline_1080;

    Image *background = load_rgb_image("test/images/test_bg.png");
    Image *foreground = load_rgb_image("test/images/test_fg.png");

    run_image(foreground, background, "test_output_half_direct_0_0.png",
              MODE_SCALE_HALF, MODE_OVERLAY_DIRECT, 0, 0);

    run_image(foreground, background, "test_output_half_direct_100_100.png",
                MODE_SCALE_HALF, MODE_OVERLAY_DIRECT, 100, 100);

    run_image(foreground, background, "test_output_half_direct_-100_-100.png",
                MODE_SCALE_HALF, MODE_OVERLAY_DIRECT, -100, -100);

    run_image(foreground, background, "test_output_full_chroma_0_0.png",
                MODE_SCALE_FULL, MODE_OVERLAY_CHROMA_KEY, 0, 0);

    run_image(foreground, background, "test_output_full_chroma_100_100.png",
                MODE_SCALE_FULL, MODE_OVERLAY_CHROMA_KEY, 100, 100);

    run_image(foreground, background, "test_output_full_chroma_-100_-100.png",
                MODE_SCALE_FULL, MODE_OVERLAY_CHROMA_KEY, -100, -100);

    run_image(foreground, background, "test_output_half_chroma_250_250.png",
                MODE_SCALE_HALF, MODE_OVERLAY_CHROMA_KEY, 250, 250);

    pipeline->final();

    delete pipeline;
    delete background;
    delete foreground;
    return 0;
}
