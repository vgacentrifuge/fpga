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
    // input [15:0] colour_bus_2,
    // input dataclkin_2,
    // input vsin_2,
    // input hsin_2,
    
    // DAC 0
    output [15:0] colour_bus_0,
    output hsync_out_0,
    output vsync_out_0,
    output dacclk_out_0

    // SRAM
   inout [35:0] sram_data_bus_0,
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
    
    wire clk160;
    wire clk40; // Unused
    clk_wiz_160 clk_wiz(
        .clk_in1(gclk100),
        .clk_out160(clk160),
        .clk_out40(clk40)
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
        .rd_clk_0(clk160)
    );
    
    // DAC FIFO
    wire [37:0] dac_fifo_out;
    wire [37:0] dac_fifo_in;
    wire dac_fifo_empty;
    wire dac_fifo_write;
    wire dac_fifo_read;
    pixel_FIFO_dac dac_fifo(
        .FIFO_WRITE_0_wr_data(dac_fifo_in),
        .FIFO_WRITE_0_wr_en(dac_fifo_write),
        .wr_clk_0(clk160),
        
        .FIFO_READ_0_rd_data(dac_fifo_out),
        .FIFO_READ_0_empty(dac_fifo_empty),
        .FIFO_READ_0_rd_en(dac_fifo_read),
        .rd_clk_0(dataclkin_2)
    );
    
    // DAC
    dac_handle dac(
        .pixelclk(dataclkin_1),
        .has_pixel(~dac_fifo_empty),
        .pixel_in(dac_fifo_out[15:0]),
        .pixel_x(dac_fifo_out[37:27]),
        .pixel_y(dac_fifo_out[26:16]),
        
        .hw_colour_bus(colour_bus_0),
        .hw_hsync_out(hsync_out_0),
        .hw_vsync_out(vsync_out_0),
        .hw_dacclk_out(dacclk_out_0)
    );
    assign dac_fifo_read = 1'b1;
    

    reg [10:0] x;
    reg [10:0] y;

    wire request_active;
    wire data_ready;
    wire [15:0] data;

    // SRAM module
    sram_wrapper sram(
        .clk(clk160),
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
        .request_active(request_active),
        .request_x(x),
        .request_y(y),
        .request_ready(data_ready),
        .request_data(data),

        // Hardware port wiring
        .hw_sram_addr(sram_addr_bus_0),
        .hw_sram_data(sram_data_bus_0[17:0]),
        .hw_sram_advload(sram_adv_ld_0),
        .hw_sram_write_enable(sram_we_0),
        .hw_sram_chip_enable(sram_ce2_0),
        .hw_sram_oe(sram_oe_0),
        .hw_sram_clk_enable(sram_cen_0),
        .hw_sram_clk(sram_clk_0)
    );
    reg [3:0] shifter; // so we can simulate a fg request every four cycles
    always @(posedge clk160) begin
        if (shifter == 4'0000) begin
            shifter <= 4'b1000;
        end else begin
            shifter <= {shifter[2:0],shifter[3]};
        end
        if (shifter[2]) begin
            if (x == 1055) begin
                x <= 0;
                if(y == 627) begin
                    y <= 0;
                end else begin
                    y <= y+1;
                end
            end else begin
                x <= x + 1;
            end
        end
    end
    // make request
    assign request_active = shifter[3];
    // pass result to dac
    assign dac_fifo_write = data_ready;
    assign dac_fifo_in = {x, y, data};


endmodule
