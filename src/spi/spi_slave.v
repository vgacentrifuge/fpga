// Slave SPI module with CPOL = 0 and CPHA = 0

// Uses the internal clock and oversamples the SPI clock. This makes a lot of stuff
// simpler to deal with (e. g. detecting start/end of messages)
module spi_slave (input clk,
                  input hw_spi_clk,
                  input hw_spi_ss,
                  input hw_spi_mosi,
                  output hw_spi_miso,
                  output [7:0] byte_out,
                  output byte_ready);
    // Store the state of the SPI clock in a register so we can check states to
    // determine if there is a falling/rising edge
    reg spi_clk_state;
    reg [7:0] spi_clk_history;
    always @ (posedge clk)
        spi_clk_history <= {spi_clk_history[6:0], hw_spi_clk};
    
    // Wait for signal to be stable for 8 (FPGA) clock cycles so any noise
    // will not trigger a false positive for SPI clock cycle
    wire spi_clk_posedge = ~spi_clk_state && spi_clk_history == 8'hFF;
    wire spi_clk_negedge = spi_clk_state && spi_clk_history == 8'h00;
    
    // Remap for active high on the SPI slave select
    wire spi_active = ~hw_spi_ss;
    
    reg [2:0] counter;
    reg [7:0] data_in;
    reg data_ready;
    reg data_out;
    
    always @ (posedge clk) begin
        data_ready <= 0;

        if (~spi_active) begin
            spi_clk_state <= 1'b0;
            counter <= 3'b000; // Reset counter when there is no message
        end else if (spi_clk_posedge) begin
            spi_clk_state <= 1'b1;
            counter <= counter + 3'b001;
            data_in <= {data_in[6:0], hw_spi_mosi};
            data_ready <= counter == 3'b111;
        end else if (spi_clk_negedge) begin
            data_out <= spi_active; // Just write back one to let MCU know we are reading
            spi_clk_state <= 1'b0;
        end
    end
                
    assign byte_ready = data_ready;
    assign byte_out   = data_in;
    assign hw_spi_miso   = data_out;
endmodule
