// This is a wrapper module handling freezeframe, adc and spi image input
// SPI input is currently in danger of overwriting if fg reads are issued simultaneously,
//   will probably add a FIFO later to deal with it (or we just don't output when reading images)
// Freezeframe is sort of handled, but should be changed to only stop reading adc at the end of a frame so we avoid tearing
module sram_wrapper (
    // module signals
    input clk,
    input frozen,
    // SPI image input
    input spi_active,
    input [15:0] spi_pixel_in,
    input [10:0] spi_pixel_x,
    input [10:0] spi_pixel_y,
    // ADC FIFO input
    input [37:0] adc_pixel_data,
    input adc_pixel_ready,
    output reg adc_pixel_read,
    // Pipeline request signals
    input request_active,
    input [10:0] request_x,
    input [10:0] request_y,
    output reg [15:0] request_data,
    output reg request_ready,
    // SRAM signals
    output [19:0] hw_sram_addr,
    inout [16:0] hw_sram_data,
    output hw_sram_advload,
    output hw_sram_write_enable,
    output hw_sram_chip_enable,
    output hw_sram_oe,
    output hw_sram_clk_enable,
    output hw_sram_clk
    );

parameter X_RES = 800;
parameter Y_RES = 600;

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
    .sram_addr(hw_sram_addr),
    .sram_data(hw_sram_data),
    .sram_advload(hw_sram_advload),
    .sram_write_enable(hw_sram_write_enable),
    .sram_chip_enable(hw_sram_chip_enable),
    .sram_oe(hw_sram_oe),
    .sram_clk_enable(hw_sram_clk_enable),
    .sram_clk(hw_sram_clk)
);


reg [5:0] read_issued;
reg [5:0] out_of_bounds_read;

always @(posedge clk) begin
    adc_pixel_read <= 0;
    sram_data_in <= 17'b0;
    sram_we <= 0;
    read_issued <= {read_issued[4:0], 1'b0};
    out_of_bounds_read <= {out_of_bounds_read[4:0], 1'b0};
    if (request_active) begin
        // Read from SRAM
        if (request_x >= X_RES || request_y >= Y_RES) begin
            // Request is located outside view area, so we can silently ignore SRAM, and output a blank pixel later
            out_of_bounds_read <= {out_of_bounds_read[4:0], 1'b1};
        end else begin
            sram_addr <= {request_x[9:0], request_y[9:0]};
        end
        read_issued <= {read_issued[4:0], 1'b1};
    end else begin
        // Attempt to write from elsewhere:
        if (adc_pixel_ready) begin
            // Only write if pixel is within window (and we do not have freeze_frame)
            if(~frozen && adc_pixel_data[37:27] < X_RES && adc_pixel_data[26:16] < Y_RES) begin
                // Write pixel to SRAM, use the 10 lowest bits of x and y
                sram_addr <= {adc_pixel_data[36:27], adc_pixel_data[25:16]};
                sram_we <= 1;
                sram_data_in <= {1'b0, adc_pixel_data[15:0]};
            end 
            // Consume pixel, no matter where it ended up
            adc_pixel_read <= 1;
        end else if (spi_active) begin
            // TODO: Add fifo for storing spi pixels so they can't be skipped during requests
            //       Might also make sense to just assume no fg requests are made during spi image writes
            //       We won't be able to send the entire image during a single frame anyway
            
            // Write SPI-pixel into SRAM
            sram_addr <= {spi_pixel_x[9:0], spi_pixel_y[9:0]};
            sram_we <= 1;
            sram_data_in <= {1'b0, spi_pixel_in};
        end
    end
    // Relay SRAM reads to fg requester
    if( out_of_bounds_read[5] ) begin
        request_data <= 16'b0;
    end else begin
        request_data <= sram_data_out;
    end
    request_ready <= read_issued[5];
end
    


endmodule