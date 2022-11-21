module pipeline_spi_image_receiver #(
    parameter PRECISION = 11,
    parameter PIXEL_SIZE = 16,

    parameter RESOLUTION_X = 800,
    parameter RESOLUTION_Y = 600
) (
    input clk,
    input enable_receive,

    input spi_byte_ready,
    input [7:0] spi_byte_in,

    output reg [PIXEL_SIZE - 1:0] pixel_out,
    output reg [PRECISION - 1:0] pixel_x,
    output reg [PRECISION - 1:0] pixel_y,
    output reg pixel_ready
);
    localparam STATE_AWAIT_ROW = 1'b0;
    localparam STATE_AWAIT_PIXEL = 1'b1;

    reg state;

    wire [15:0] bytes_in;
    wire bytes_ready;

    spi_multibyte_reader #(
        .BYTE_COUNT(2)
    ) spi_reader(
        .clk(clk),
        .reset(~enable_receive),
        .spi_byte_ready(spi_byte_ready),
        .spi_byte_in(spi_byte_in),
        .bytes_out(bytes_in),
        .bytes_ready(bytes_ready)
    );

    always @ (posedge clk) begin
        if (~enable_receive) begin 
            state <= STATE_AWAIT_ROW;
        end
        else begin
            case (state)
                STATE_AWAIT_ROW: begin
                    if (bytes_ready) begin
                        pixel_y <= bytes_in[PRECISION - 1:0];
                        pixel_x <= 0;
                        state <= STATE_AWAIT_PIXEL;
                    end
                end

                STATE_AWAIT_PIXEL: begin
                    if (bytes_ready) begin
                        pixel_out <= bytes_in[PIXEL_SIZE - 1:0];
                        pixel_ready <= 1;
                    end

                    if (pixel_ready) begin
                        pixel_ready <= 0;
                        pixel_x <= pixel_x + 1;

                        if (pixel_x == RESOLUTION_X - 1) begin
                            pixel_x <= 0;
                            pixel_y <= pixel_y + 1;

                            if (pixel_y == RESOLUTION_Y - 1) begin
                                pixel_y <= 0;
                            end
                        end
                    end
                end
            endcase
        end
    end
endmodule