#include <verilated.h>

#include <iostream>

#include "Vpipeline.h"
#include "png_helper.h"

/*
input clk,

// The input position of the current pixel
input [9:0] pixel_x,
input [9:0] pixel_y,

input [15:0] bg_pixel_in,
input output_enable, // Whether we are blanking screen

// Foreground coord sent to SRAM, pixel recieved
input  [15:0] fg_pixel_in,
input  fg_pixel_skip,
output signed [10:0] fg_pixel_request_x,
output signed [10:0] fg_pixel_request_x,
output fg_pixel_request_active,

// Resulting pixel. Positions for sanity checks.
output reg [15:0] pixel_out,
output reg [9:0] pixel_x_out,
output reg [9:0] pixel_y_out,

// Control signals:
input [1:0] ctrl_overlay_mode,
input [1:0] ctrl_fg_scale,
input [9:0] ctrl_fg_offset_x,
input [9:0] ctrl_fg_offset_y
*/

int main(int argc, char const *argv[]) {
    Verilated::commandArgs(argc, argv);

    return 0;
}
