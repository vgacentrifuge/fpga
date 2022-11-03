`include "src/vga/dac_handle.v"
`include "src/vga/pixel_counter.v"

module vgademo_top(input gclk100,
                   input clk25,
                   input [15:0] colour_bus_0,
                   input dataclkin_0,
                   input vsin_0,
                   input hsin_0,
                   input fidin_0,
                   input [15:0] colour_bus_1,
                   input dataclkin_1,
                   input vsin_1,
                   input hsin_1,
                   input fidin_1,
                   output [15:0] colour_bus_2,
                   output hsync_out_0,
                   output vsync_out_0,
                   output dacclk_out_0,
                   inout [35:0] sram_data_bus_0,
                   output [19:0] sram_addr_bus_0,
                   output sram_ce1p3_0,
                   output sram_ce2_0,
                   output sram_cen_0,
                   output sram_we_0,
                   output sram_clk_0,
                   output sram_oe_0,
                   output sram_adv_ld_0,
                   inout [23:0] auxio_bus_0);
    
    wire in_display_area;
    wire [9:0] pixel_x;
    wire [9:0] pixel_y;
    reg [15:0] pixel;
    
    pixel_counter counter(
        .clk(clk25),
        .counter_x(pixel_x),
        .counter_y(pixel_y),
        .in_display_area(in_display_area)
    );
    
    dac_handle dac(
        .clk25(clk25),
        .pixel_in(pixel),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .hw_colour_bus(colour_bus_2),
        .hw_hsync_out(hsync_out_0),
        .hw_vsync_out(vsync_out_0),
        .hw_dacclk_out(dacclk_out_0)
    );
    
    always @(posedge clk25)
    begin
        if (in_display_area)
            pixel <= {pixel_x, 6'b0};
        else
            pixel <= 16'h0000;
    end
endmodule
