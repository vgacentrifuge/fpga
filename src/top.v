/*
 * Main top module for the entire project. This module instantiates all other
 * modules and connects them together.
 */

// All the ports here are hardware ports
module top(
    input gclk100,
    
    // ADC 1
    input [15:0] colour_bus_1,
    input dataclkin_1,
    input vsin_1,
    input hsin_1,

    // ADC 2
    input [15:0] colour_bus_2,
    input dataclkin_2,
    input vsin_2,
    input hsin_2,
    
    // DAC 0
    output [15:0] colour_bus_0,
    output hsync_out_0,
    output vsync_out_0,
    output dacclk_out_0,

    // SRAM
    inout [16:0] sram_data_bus_0,
    output [19:0] sram_addr_bus_0,
    output sram_ce1p3_0,
    output sram_ce2_0,
    output sram_cen_0,
    output sram_we_0,
    output sram_clk_0,
    output sram_oe_0,
    output sram_adv_ld_0

    // Auxillary
    //inout [23:0] auxio_bus_0
);
    localparam PRECISION = 11;
    localparam R_WIDTH = 5;
    localparam G_WIDTH = 6;
    localparam B_WIDTH = 5;
    localparam PIXEL_SIZE = R_WIDTH + G_WIDTH + B_WIDTH;
    
    wire clk40; // Unused
    wire clk80;
    wire clk120;
    clk_wiz_160 clk_wiz(
        .clk_in1(gclk100),
        .clk_out160(clk160),
        .clk_out40(clk40),
        .clk_out80(clk80),
        .clk_out120(clk120)
    );
    
    // ADC 2    
    wire [37:0] adc2_fifo_write_data;
    wire adc2_fifo_write_req;
    adc_input adc2(
        .hw_pixel_clk(dataclkin_2),
        .hw_rgb_in(colour_bus_2),
        .hw_vsync_in(vsin_2),
        .hw_hsync_in(hsin_2),
        
        .fifo_write_data(adc2_fifo_write_data[15:0]),
        .pixel_x(adc2_fifo_write_data[37:27]),
        .pixel_y(adc2_fifo_write_data[26:16]),
        .fifo_write_request(adc2_fifo_write_req)
    );
    // ADC 2 FIFO
    wire adc2_fifo_empty;
    wire [37:0] adc2_fifo_out;
    wire adc2_fifo_read;
    pixel_FIFO_adc adc2_fifo(
        .FIFO_WRITE_0_wr_data(adc2_fifo_write_data),
        .FIFO_WRITE_0_wr_en(adc2_fifo_write_req),
        .wr_clk_0(dataclkin_2),
        
        .FIFO_READ_0_rd_data(adc2_fifo_out),
        .FIFO_READ_0_empty(adc2_fifo_empty),
        .FIFO_READ_0_rd_en(adc2_fifo_read),
        .rd_clk_0(clk80)
    );
    
    // ADC 1   
    wire [37:0] adc1_fifo_write_data;
    wire adc1_fifo_write_req;
    adc_input adc1(
        .hw_pixel_clk(dataclkin_1),
        .hw_rgb_in(colour_bus_1),
        .hw_vsync_in(vsin_1),
        .hw_hsync_in(hsin_1),
        
        .fifo_write_data(adc1_fifo_write_data[15:0]),
        .pixel_x(adc1_fifo_write_data[37:27]),
        .pixel_y(adc1_fifo_write_data[26:16]),
        .fifo_write_request(adc1_fifo_write_req)
    );
    // ADC 1 FIFO
    wire adc1_fifo_empty;
    wire [37:0] adc1_fifo_out;
    wire adc1_fifo_read;
    pixel_FIFO_adc adc1_fifo(
        .FIFO_WRITE_0_wr_data(adc1_fifo_write_data),
        .FIFO_WRITE_0_wr_en(adc1_fifo_write_req),
        .wr_clk_0(dataclkin_1),
        
        .FIFO_READ_0_rd_data(adc1_fifo_out),
        .FIFO_READ_0_empty(adc1_fifo_empty),
        .FIFO_READ_0_rd_en(adc1_fifo_read),
        .rd_clk_0(clk80)
    );
    
    wire dac_pixel_clock = clk40;
    // DAC FIFO
    wire [37:0] dac_fifo_out;
    wire [37:0] dac_fifo_in;
    wire dac_fifo_empty;
    wire dac_fifo_write;
    wire dac_fifo_read;
    pixel_FIFO_dac dac_fifo(
        .FIFO_WRITE_0_wr_data(dac_fifo_in),
        .FIFO_WRITE_0_wr_en(dac_fifo_write),
        .wr_clk_0(clk80),
        
        .FIFO_READ_0_rd_data(dac_fifo_out),
        .FIFO_READ_0_empty(dac_fifo_empty),
        .FIFO_READ_0_rd_en(dac_fifo_read),
        .rd_clk_0(dac_pixel_clock)
    );
    
    // DAC
    dac_handle dac(
        .pixelclk(dac_pixel_clock),
        .has_pixel(~dac_fifo_empty),
        .pixel_in(dac_fifo_out[15:0]),
        .pixel_x(dac_fifo_out[37:27]),
        .pixel_y(dac_fifo_out[26:16]),
        
        .hw_colour_bus(colour_bus_0),
        .hw_hsync_out(hsync_out_0),
        .hw_vsync_out(vsync_out_0),
        .hw_dacclk_out(dacclk_out_0)
    );
    
    wire signed [PRECISION:0] fg_pixel_req_x;
    wire signed [PRECISION:0] fg_pixel_req_y;
    wire fg_pixel_req_active;
    wire [PIXEL_SIZE - 1:0] fg_pixel_response;
    wire fg_pixel_response_ready;

    // SRAM module
    sram_wrapper sram(
        .clk(clk80),
        .frozen(0),
        // ADC FIFO connection
        .adc_pixel_data(adc1_fifo_out),
        .adc_pixel_ready(~adc1_fifo_empty),
        .adc_pixel_read(adc1_fifo_read),
        // SPI-pipeline connection (not currently used)
        .spi_active(0),
        .spi_pixel_in(0),
        .spi_pixel_x(0),
        .spi_pixel_y(0),
        // FG requests
        .request_active(fg_pixel_req_active),
        .request_x(fg_pixel_req_x),
        .request_y(fg_pixel_req_y),
        .request_ready(fg_pixel_response_ready),
        .request_data(fg_pixel_response),

        // Hardware port wiring
        .hw_sram_addr(sram_addr_bus_0),
        .hw_sram_data(sram_data_bus_0),
        .hw_sram_advload(sram_adv_ld_0),
        .hw_sram_write_enable(sram_we_0),
        .hw_sram_chip_enable(sram_ce2_0),
        .hw_sram_oe(sram_oe_0),
        .hw_sram_clk_enable(sram_cen_0),
        .hw_sram_clk(sram_clk_0)
    );
    
    // Graphics pipeline
    pipeline #(
        .PRECISION(PRECISION),
        .R_WIDTH(R_WIDTH),
        .G_WIDTH(G_WIDTH),
        .B_WIDTH(B_WIDTH)
    ) pipeline(
        .clk(clk80),
        // Input pixel
        .pixel_x(adc2_fifo_out[37:27]),
        .pixel_y(adc2_fifo_out[26:16]),
        .bg_pixel_in(adc2_fifo_out[15:0]),
        .bg_pixel_ready(~adc2_fifo_empty),
        .in_blanking_area(1'b0),
        // SRAM requests
        .fg_pixel_in(fg_pixel_response),
        .fg_pixel_skip(~fg_pixel_response_ready),
        .fg_pixel_ready(fg_pixel_response_ready),
        .fg_pixel_request_x(fg_pixel_req_x),
        .fg_pixel_request_y(fg_pixel_req_y),
        .fg_pixel_request_active(fg_pixel_req_active),
        // Output to DAC
        .pixel_out(dac_fifo_in[15:0]),
        .pixel_x_out(dac_fifo_in[37:27]),
        .pixel_y_out(dac_fifo_in[26:16]),
        .pixel_ready_out(dac_fifo_write),
        // Control signals
        .ctrl_overlay_mode(2'b10),
        .ctrl_fg_scale(2'b00),
        .ctrl_fg_offset_x(0),
        .ctrl_fg_offset_y(0),
        .ctrl_fg_clip_left(0),
        .ctrl_fg_clip_right(0),
        .ctrl_fg_clip_top(0),
        .ctrl_fg_clip_bottom(0),
        .ctrl_fg_opacity(4'h8)
);
    

endmodule
