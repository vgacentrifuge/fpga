/*
 * Utility module for reading more than 1 byte from SPI at a time.
 */
module spi_multibyte_reader #(
    parameter BYTE_COUNT = 2
) (
    input clk,
    input reset,

    input spi_byte_ready,
    input [7:0] spi_byte_in,

    output reg [BYTE_COUNT * 8 - 1:0] bytes_out,
    output reg bytes_ready
);
    // This does limit us to a max byte count, but if we need more than the limit
    // we can just increase the amount of bits used
    reg [7:0] byte_count;

    always @ (posedge clk) begin
        if (reset) begin 
            byte_count <= 0;
            bytes_ready <= 0;
        end
        else begin
            bytes_ready <= 0;

            if (spi_byte_ready) begin
                bytes_out <= {bytes_out[(BYTE_COUNT - 1) * 8 - 1:0], spi_byte_in};
                byte_count <= byte_count + 1;

                if (byte_count == BYTE_COUNT - 1) begin
                    bytes_ready <= 1;
                    byte_count <= 0;
                end
            end
        end
    end
endmodule