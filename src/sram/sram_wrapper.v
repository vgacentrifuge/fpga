// This is a wrapper module handling freezeframe, adc and spi image input
module sram_wrapper #(
    // Resolution of FG image, reads and writes from outside this range are ignored or return black pixels
    parameter X_RES = 800,
    parameter Y_RES = 600,

    // The amount of bits used to represent an unsigned position on screen
    parameter PRECISION = 11,

    // The delay between the issuing of a FG-request and the resulting output, should not be changed
    localparam SRAM_DELAY = 5
)(
    // module signals
    input clk,
    input frozen,

    // SPI image input

    // Should be raised high when there is a pixel ready on the inputs
    input spi_pixel_ready,
    // Raised high when pixel has been written
    output reg spi_pixel_read,
    // The pixel to write and its coordinates
    input [15:0] spi_pixel_in,       
    input signed [PRECISION:0] spi_pixel_x,
    input signed [PRECISION:0] spi_pixel_y,


    // ADC FIFO input, wire directly to the FIFO
    input [37:0] adc_pixel_data,
    input adc_pixel_ready,
    output adc_pixel_read,


    // Pipeline request signals

    // Raise high to signal a new request
    input request_active,

    // Coordinates of the desired pixel
    input signed [PRECISION:0] request_x,
    input signed [PRECISION:0] request_y,

    // The data of the resulting pixel
    output reg [15:0] request_data,

    // Raised high when the result of a request is ready on request_data
    // Data is ready SRAM_DELAY cycles after request_active is high
    output reg request_ready,


    // SRAM signals to HW
    output [19:0] hw_sram_addr,
    inout [16:0] hw_sram_data,
    output hw_sram_advload,
    output hw_sram_write_enable,
    output hw_sram_chip_enable,
    output hw_sram_oe,
    output hw_sram_clk_enable,
    output hw_sram_clk
    );

// Interface module
reg sram_we;
reg [19:0] sram_addr;
reg [16:0] sram_data_in;
wire [16:0] sram_data_out;

sram_interface sram(
    .clk(clk),
    .write_enable(sram_we),
    .addr(sram_addr),
    .data_in(sram_data_in),
    .data_out(sram_data_out),
    .hw_sram_addr(hw_sram_addr),
    .hw_sram_data(hw_sram_data),
    .hw_sram_advload(hw_sram_advload),
    .hw_sram_write_enable(hw_sram_write_enable),
    .hw_sram_chip_enable(hw_sram_chip_enable),
    .hw_sram_oe(hw_sram_oe),
    .hw_sram_clk_enable(hw_sram_clk_enable),
    .hw_sram_clk(hw_sram_clk)
);

reg [SRAM_DELAY-1:0] read_issued;
reg [SRAM_DELAY-1:0] out_of_bounds_read;
reg [SRAM_DELAY-1:0] spi_write_issued;

always @(posedge clk) begin
    //adc_pixel_read <= 0;
    sram_data_in <= 17'b0;
    sram_we <= 0;
    sram_addr <= {request_x[9:0], request_y[9:0]};
    
    read_issued <= {read_issued[SRAM_DELAY-2:0], 1'b0};
    
    out_of_bounds_read <= {out_of_bounds_read[SRAM_DELAY-2:0], 1'b0};
    
    spi_pixel_read <= 1'b0;
    spi_write_issued <= {spi_write_issued[SRAM_DELAY-2:0], 1'b0};
    
    if (~spi_pixel_ready && request_active) begin
        // Read from SRAM
        if (request_x >= X_RES || request_y >= Y_RES || request_x < 0 || request_y < 0) begin
            // Request is located outside view area, so we can silently skip SRAM request, and output a blank pixel later
            out_of_bounds_read <= {out_of_bounds_read[SRAM_DELAY-2:0], 1'b1};
        end else begin
            sram_addr <= {request_x[9:0], request_y[9:0]};
        end
        read_issued <= {read_issued[SRAM_DELAY-2:0], 1'b1};
    end else begin
        // Read from ADC, lowest priority
        if (adc_pixel_ready && ~frozen && adc_pixel_data[37:27] < X_RES && adc_pixel_data[26:16] < Y_RES) begin
            // We are within frame and not freeze-framing
            // Write pixel to SRAM, use the 10 lowest bits of x and y
            sram_addr <= {adc_pixel_data[36:27], adc_pixel_data[25:16]};
            sram_we <= 1;
            sram_data_in <= {1'b0, adc_pixel_data[15:0]};
        end else if (spi_pixel_ready && frozen) begin
            // Write SPI-pixel into SRAM
            spi_write_issued <= {spi_write_issued[SRAM_DELAY-2:0], 1'b1};
            sram_addr <= {spi_pixel_x[9:0], spi_pixel_y[9:0]};
            sram_we <= 1;
            sram_data_in <= {1'b0, spi_pixel_in};
        end
    end
    // Relay SRAM reads to fg requester
    if( out_of_bounds_read[SRAM_DELAY-1] ) begin
        request_data <= 16'b0;
    end else begin
        request_data <= sram_data_out[15:0];
    end
    
    if(spi_write_issued[SRAM_DELAY-1] ) begin
        // we want to only ack once, even if we have been writing the same pixel several times, so we empty the psi_write_issued register
        spi_pixel_read <= 1'b1;
        spi_write_issued <= 0;
    end
    request_ready <= read_issued[SRAM_DELAY-1];
end
    

// Consumption of pixel from SRAM, this must not be a register, otherwise the read pixel will not be consumed in the FIFO before
//      the next cycle, causing us to double-read the same pixel. We should still consume the pixel, even when frozen,
//      as we need to throw away old values to make room for new ones when we eventually start reading again
assign adc_pixel_read = (~request_active && adc_pixel_ready);

endmodule
