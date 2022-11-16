#include <verilated.h>

#include <iostream>

#include "Vpipeline_spi_control_16b.h"
#include "control.h"
#include "spi_helper.h"

#define SPI_SIGNED_2_BYTE(x) \
    { (uint8_t)((((uint16_t)x) >> 8) & 0xFF), (uint8_t)(x & 0xFF) }

Vpipeline_spi_control_16b *control;

void eval() { control->eval(); }

void run_command(SPISlave &slave, command_t command,
                 std::initializer_list<uint8_t> args) {
    start_transmission(slave);
    write_byte(slave, command);

    for (auto arg : args) {
        write_byte(slave, arg);
    }

    for (int i = 0; i < 10; i++) {
        eval();
    }

    end_transmission(slave);
}

template <typename T>
void expect(const std::string name, T *ptr, T expected) {
    T actual = (T)*ptr;

    if (actual != expected) {
        std::cout << name << ": Expected " << expected << " but got " << actual
                  << std::endl;
        exit(EXIT_FAILURE);
    } else {
        std::cout << name << ": Success" << std::endl;
    }
}

template <typename T>
void run_and_expect(const std::string name, SPISlave &slave, command_t command,
                    std::initializer_list<uint8_t> args, T *ptr, T expected) {
    run_command(slave, command, args);
    expect<T>(name, ptr, expected);
}

int main(int argc, char const *argv[]) {
    Verilated::commandArgs(argc, argv);

    control = new Vpipeline_spi_control_16b;

    SPISlave slave = {.eval = eval,
                      .clk = &control->clk,
                      .hw_spi_clk = &control->hw_spi_clk,
                      .hw_spi_ss = &control->hw_spi_ss,
                      .hw_spi_mosi = &control->hw_spi_mosi};

    // Probably more stuff we can test, but it all uses pretty much the same
    // logic so I'm not going to bother for now. Can add if there is an issue.

    run_and_expect<uint16_t>("FG Offset X 1", slave, CMD_FG_OFFSET_X,
                             SPI_SIGNED_2_BYTE(200), &control->ctrl_fg_offset_x,
                             200);
    run_and_expect<uint16_t>("FG Offset X 2", slave, CMD_FG_OFFSET_X,
                             SPI_SIGNED_2_BYTE(-600),
                             &control->ctrl_fg_offset_x, -600);
    run_and_expect<uint16_t>("FG Offset Y 1", slave, CMD_FG_OFFSET_Y,
                             SPI_SIGNED_2_BYTE(200), &control->ctrl_fg_offset_y,
                             200);
    run_and_expect<uint16_t>("FG Offset Y 2", slave, CMD_FG_OFFSET_Y,
                             SPI_SIGNED_2_BYTE(-600),
                             &control->ctrl_fg_offset_y, -600);

    run_and_expect<uint8_t>("FG Mode None", slave, CMD_FG_MODE,
                            {MODE_OVERLAY_NONE}, &control->ctrl_overlay_mode,
                            MODE_OVERLAY_NONE);
    run_and_expect<uint8_t>(
        "FG Mode Chroma Key", slave, CMD_FG_MODE, {MODE_OVERLAY_CHROMA_KEY},
        &control->ctrl_overlay_mode, MODE_OVERLAY_CHROMA_KEY);
    run_and_expect<uint8_t>("FG Mode Direct", slave, CMD_FG_MODE,
                            {MODE_OVERLAY_DIRECT}, &control->ctrl_overlay_mode,
                            MODE_OVERLAY_DIRECT);

    run_and_expect<uint8_t>("FG Scale Full", slave, CMD_FG_SCALE,
                            {MODE_SCALE_FULL}, &control->ctrl_fg_scale,
                            MODE_SCALE_FULL);
    run_and_expect<uint8_t>("FG Scale Half", slave, CMD_FG_SCALE,
                            {MODE_SCALE_HALF}, &control->ctrl_fg_scale,
                            MODE_SCALE_HALF);
    run_and_expect<uint8_t>("FG Scale Quarter", slave, CMD_FG_SCALE,
                            {MODE_SCALE_QUARTER}, &control->ctrl_fg_scale,
                            MODE_SCALE_QUARTER);

    run_command(slave, CMD_RESET, {});
    expect<uint16_t>("Reset", &control->ctrl_fg_offset_x, 0);
    expect<uint16_t>("Reset", &control->ctrl_fg_offset_y, 0);

    expect<uint8_t>("Reset", &control->ctrl_overlay_mode, MODE_OVERLAY_NONE);
    expect<uint8_t>("Reset", &control->ctrl_fg_scale, MODE_SCALE_FULL);

    control->final();

    delete control;
    return 0;
}
