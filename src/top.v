/*
 * Main top module for the entire project. This module instantiates all other
 * modules and connects them together.
 */

// All the ports here are hardware ports
module top(input gclk100,
    
    // ADC 0
    input [15:0] colour_bus_0,
    input dataclkin_0,
    input vsin_0,
    input hsin_0,
    input fidin_0,


    // ADC 1
    input [15:0] colour_bus_1,
    input dataclkin_1,
    input vsin_1,
    input hsin_1,
    input fidin_1,    
    
    // DAC 0
    output [15:0] colour_bus_2,
    output hsync_out_0,
    output vsync_out_0,
    output dacclk_out_0,

    // SRAM
    inout [35:0] sram_data_bus_0,
    output [19:0] sram_addr_bus_0,
    output sram_ce1p3_0,
    output sram_ce2_0,
    output sram_cen_0,
    output sram_we_0,
    output sram_clk_0,
    output sram_oe_0,
    output sram_adv_ld_0,

    // Auxillary
    inout [23:0] auxio_bus_0
    );
    wire read_enable;
    wire write_enable;
    wire data_ready;
    wire [19:0] r_addr;
    wire [19:0] w_addr;
    wire [17:0] r_pixel_data;
    wire [15:0] w_pixel_data

    wire [15:0] output_pixel;
    wire [9:0] output_x;
    wire [9:0] output_y;


    // SRAM module
    sram_interface sram(
        .clk(gclk100),
        // Wire these to pipeline
        .read_enable(read_enable),
        .r_addr(r_addr),
        .data_out(r_pixel_data),
        // Wire these to foreground multiplexer
        .write_enable(write_enable),
        .w_addr(w_addr),
        .data_in(w_pixel_data),
        .data_ready(data_ready),
        // Hardware port wiring
        .sram_addr(sram_addr_bus_0),
        .sram_data(sram_data_bus_0[17:0]),
        .sram_advload(sram_adv_ld_0),
        .sram_write_enable(sram_we_0),
        .sram_chip_enable(sram_ce2_0),
        .sram_oe(sram_oe_0),
        .sram_clk_enable(sram_cen_0),
        .sram_clk(sram_clk_0)
    );

    // Graphics pipeline
    wire [23:0] ctrls = 24'b011000000000000000000000; // Constant for now
    pipeline pipeline(
        // Input pixel
        .pixel_x(),
        .pixel_y(),
        .bg_pixel_in(),
        .output_enable(),
        // SRAM requests
        .fg_pixel_in(r_pixel_data[15:0]),
        .fg_pixel_skip(data_ready),
        .fg_pixel_request_x(r_addr[9:0]),
        .fg_pixel_request_y(r_addr[19:10]),
        .fg_pixel_request_active(read_enable),
        // Output to DAC
        .pixel_out(output_pixel),
        .pixel_x_out(output_x),
        .pixel_y_out(output_y),
        // Control signals
        .ctrl_overlay_mode(ctrls[23:22]),
        .ctrl_fg_scale(ctrls[21:20]),
        .ctrl_fg_offset_x(ctrls[19:10]),
        .ctrl_fg_offset_y(ctrls[9:0])
    );


endmodule
