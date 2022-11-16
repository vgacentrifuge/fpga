#include <verilated.h>

#include <iostream>
#include <queue>

#include "Vpipeline_1080.h"
#include "control.h"
#include "png_helper.h"

#define FOREGROUND_FETCH_DELAY 3
#define BLANKING_AREA_SIZE 50

Vpipeline_1080 *pipeline;

struct fg_request_t {
    int16_t x;
    int16_t y;
    bool active;
};

void check_fg_request(std::queue<fg_request_t> &request_queue) {
    fg_request_t request = {(int16_t)pipeline->fg_pixel_request_x,
                            (int16_t)pipeline->fg_pixel_request_y,
                            (bool)pipeline->fg_pixel_request_active};
    request_queue.push(request);
}

void write_fg_request(Image *foreground,
                      std::queue<fg_request_t> &request_queue) {
    fg_request_t request = request_queue.front();
    request_queue.pop();

    PixelRGB fg_pixel;
    uint16_t fg_pixel_in = 0;
    if (request.active) {
        foreground->get_rgb(request.x, request.y, fg_pixel);
        fg_pixel_in = RGB_TO_PIX(fg_pixel.r, fg_pixel.g, fg_pixel.b);
    }

    pipeline->fg_pixel_in = fg_pixel_in;
    pipeline->fg_pixel_skip = !request.active;
    pipeline->fg_pixel_ready = 1;
}

void run_image(Image *foreground, Image *background,
               pipeline_control_t &settings) {
    if (background->getWidth() != foreground->getWidth() ||
        background->getHeight() != foreground->getHeight()) {
        std::cout << "Images must be the same size" << std::endl;
        exit(EXIT_FAILURE);
    }

    Image output(background->getWidth(), background->getHeight());

    // Constant for the entire run. Set them here, and then we don't need to
    // worry about them
    pipeline->ctrl_fg_scale = settings.scale;
    pipeline->ctrl_overlay_mode = settings.overlay;
    pipeline->ctrl_fg_offset_x = settings.offset_x;
    pipeline->ctrl_fg_offset_y = settings.offset_y;
    pipeline->ctrl_fg_opacity = settings.opacity;
    pipeline->ctrl_fg_clip_left = settings.clip_left;
    pipeline->ctrl_fg_clip_right = settings.clip_right;
    pipeline->ctrl_fg_clip_top = settings.clip_top;
    pipeline->ctrl_fg_clip_bottom = settings.clip_bottom;
    pipeline->bg_pixel_ready = 0;
    pipeline->fg_pixel_ready = 0;

    PixelRGB bg_pixel;
    uint16_t bg_pixel_in, pixel_out;
    uint8_t r, g, b;

    std::queue<fg_request_t> request_queue;
    for (int i = 0; i < FOREGROUND_FETCH_DELAY; i++) {
        request_queue.push({0, 0, false});
    }

    // Perform iterations for each pixel, including the blanking areas. For this
    // simulation we just define an arbitrary number of pixels that are blank.
    for (int y = 0; y < output.getHeight() + BLANKING_AREA_SIZE; y++) {
        for (int x = 0; x < output.getWidth() + BLANKING_AREA_SIZE; x++) {
            pipeline->clk = 0;
            pipeline->eval();

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
            pipeline->bg_pixel_ready = 1;
            pipeline->in_blanking_area = blanking_area;

            // Run a few iterations to simulate that the pixel clock for BG
            // is much slower than the actual clock
            for (int k = 0; k < 2; k++) {
                pipeline->clk = 1;
                write_fg_request(foreground, request_queue);
                pipeline->eval();
                check_fg_request(request_queue);

                if (pipeline->pixel_ready_out) {
                    pixel_out = pipeline->pixel_out;
                    blanking_area =
                        pipeline->pixel_x_out >= output.getWidth() ||
                        pipeline->pixel_y_out >= output.getHeight();

                    if (!blanking_area) {
                        r = PIX_TO_R(pixel_out);
                        g = PIX_TO_G(pixel_out);
                        b = PIX_TO_B(pixel_out);
                        output.set_rgba(pipeline->pixel_x_out,
                                        pipeline->pixel_y_out, {r, g, b, 255});
                    }
                }

                pipeline->bg_pixel_ready = 0;
                pipeline->clk = 0;
                pipeline->eval();
            }
        }
    }

    std::string output_file =
        "test_pipeline_" + format_pipeline_mode(settings) + ".png";
    std::cout << "Writing output to file " << output_file << std::endl;
    write_image(output, output_file);
}

int main(int argc, char const *argv[]) {
    Verilated::commandArgs(argc, argv);

    pipeline = new Vpipeline_1080;

    Image *background = load_rgb_image("test/images/test_bg.png");
    Image *foreground = load_rgb_image("test/images/test_fg.png");

    pipeline_control_t settings = {
        .scale = MODE_SCALE_HALF,
        .overlay = MODE_OVERLAY_DIRECT,
        .offset_x = 0,
        .offset_y = 0,
        .opacity = 4,
        .clip_left = 0,
        .clip_right = 0,
        .clip_top = 0,
        .clip_bottom = 0,
    };

    mode_overlay_t overlay_modes[2] = {MODE_OVERLAY_DIRECT,
                                       MODE_OVERLAY_CHROMA_KEY};

    mode_scale_t scale_modes[3] = {MODE_SCALE_HALF, MODE_SCALE_FULL,
                                   MODE_SCALE_QUARTER};

    int16_t offset_modes[3] = {0, 100, -100};

    uint8_t opacity_modes[3] = {4, 8};

    uint16_t clip_modes[3] = {0, 150, 400};

    for (int i = 0; i < 2; i++) {
        settings.overlay = overlay_modes[i];

        for (int j = 0; j < 3; j++) {
            settings.scale = scale_modes[j];

            for (int k = 0; k < 3; k++) {
                settings.offset_x = offset_modes[k];
                settings.offset_y = offset_modes[k];

                for (int l = 0; l < 2; l++) {
                    settings.opacity = opacity_modes[l];

                    for (int m = 0; m < 3; m++) {
                        settings.clip_left = clip_modes[m];
                        settings.clip_right = clip_modes[m];
                        settings.clip_top = clip_modes[m];
                        settings.clip_bottom = clip_modes[m];
                        run_image(foreground, background, settings);
                    }
                }
            }
        }
    }

    pipeline->final();

    delete pipeline;
    delete background;
    delete foreground;
    return 0;
}
