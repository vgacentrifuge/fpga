#include <verilated.h>

#include <iostream>

#include "Vpipeline_spi_control_16b.h"
#include "control.h"
#include "png_helper.h"
#include "spi_helper.h"

#define SPI_SIGNED_2_BYTE(x) \
    { (uint8_t)((((uint16_t)x) >> 8) & 0xFF), (uint8_t)(x & 0xFF) }

Vpipeline_spi_control_16b *control;
uint16_t last_x, last_y, last_pixel;

void eval() {
    control->eval();
    if (control->ctrl_image_pixel_ready) {
        last_x = control->ctrl_image_pixel_x;
        last_y = control->ctrl_image_pixel_y;
        last_pixel = control->ctrl_image_pixel;
    }
}

template <typename T>
void expect(const std::string name, T *ptr, T expected) {
    T actual = (T)*ptr;

    if (actual != expected) {
        std::cout << name << ": Expected " << expected << " but got " << actual
                  << std::endl;
        exit(EXIT_FAILURE);
    }
}

void run_command(SPISlave &slave, command_t command,
                 std::initializer_list<uint8_t> args) {
    write_byte(slave, command);

    for (auto arg : args) {
        write_byte(slave, arg);
    }

    for (int i = 0; i < 6; i++) {
        *slave.clk = i % 2;
        eval();
    }
}

void show_progress_bar(uint32_t progress_int, uint32_t total) {
    float progress = (float) progress_int / total;

    int barWidth = 70;

    std::cout << "\033[F[";
    int pos = barWidth * progress;
    for (int i = 0; i < barWidth; ++i) {
        if (i < pos)
            std::cout << "=";
        else if (i == pos)
            std::cout << ">";
        else
            std::cout << " ";
    }

    std::cout << "] " << int(progress * 100.0) << "% (" << progress_int << "/" << total << ")\r";
    std::cout.flush();
    std::cout << std::endl;
}

void send_image(SPISlave &slave, Image *image) {
    PixelRGB pixel;

    uint16_t width = image->getWidth() >> 2;
    uint16_t height = image->getHeight() >> 2;

    uint32_t pixels = width * height;
    uint32_t progress = 0;

    for (uint16_t y = 0; y < height; y++) {
        if (y % 6 == 0) {
            if (y != 0) end_transmission(slave);

            start_transmission(slave);
            run_command(slave, command_t::CMD_FG_IMG_UPLOAD,
                        SPI_SIGNED_2_BYTE(y));
        }

        for (uint16_t x = 0; x < width; x++) {
            image->get_rgb(x, y, pixel);

            uint16_t pixel_data = RGB_TO_PIX(pixel.r, pixel.g, pixel.b);

            write_byte(slave, (pixel_data >> 8) & 0xFF);
            write_byte(slave, pixel_data & 0xFF);

            std::string progress_str =
                std::to_string(++progress) + "/" + std::to_string(pixels);

            expect<uint16_t>(progress_str + ": SPI pixel X", &last_x, x);
            expect<uint16_t>(progress_str + ": SPI pixel Y", &last_y, y);
            expect<uint16_t>(progress_str + ": SPI pixel data", &last_pixel,
                             pixel_data);

            show_progress_bar(progress, pixels);
        }
    }

    end_transmission(slave);
    std::cout << "Image sent succesfully!" << std::endl;
}

int main(int argc, char const *argv[]) {
    Verilated::commandArgs(argc, argv);

    control = new Vpipeline_spi_control_16b;

    SPISlave slave = {.clk = &control->clk,
                      .eval = eval,
                      .hw_spi_clk = &control->hw_spi_clk,
                      .hw_spi_mosi = &control->hw_spi_mosi,
                      .hw_spi_ss = &control->hw_spi_ss};

    Image *image = load_rgb_image("test/images/test_bg.png");

    send_image(slave, image);

    control->final();

    delete control;
    delete image;

    return 0;
}
