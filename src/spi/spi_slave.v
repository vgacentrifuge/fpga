// Slave SPI module with CPOL = 0 and CPHA = 0

// Uses the internal clock and oversamples the SPI clock. This makes a lot of stuff
// simpler to deal with (e. g. detecting start/end of messages)
module spi_slave (input clk,
                  input spi_clk,
                  input spi_ss,
                  input spi_mosi,
                  output spi_miso,
                  output [7:0] byte_out,
                  output byte_ready);
    // Store the state of the SPI clock in a register so we can check states to
    // determine if there is a falling/rising edge
    reg [1:0] spi_clk_sr;
    always @ (posedge clk)
        spi_clk_sr <= {spi_clk_sr[0], spi_clk};
    
    wire spi_clk_posedge = ~spi_clk_sr[1] && spi_clk_sr[0];
    wire spi_clk_negedge = spi_clk_sr[1] && ~spi_clk_sr[0];
    
    // Check if the slave select line just became high
    // reg [1:0] spi_ss_sr;
    // always @ (posedge clk)
    //     spi_ss_sr <= {spi_ss_sr[0], spi_ss};
    
    wire spi_active = ~spi_ss;
    // Slave select is active low, so signals are inverted here
    // wire spi_ss_posedge = spi_ss_sr[1] & ~spi_ss_sr[0];
    // wire spi_ss_negedge = ~spi_ss_sr[1] & spi_ss_sr[0];
    
    reg [2:0] counter;
    reg [7:0] data_in;
    reg data_ready;
    reg data_out;
    
    always @ (posedge clk) begin
        data_ready <= 0;

        if (~spi_active) begin
            counter <= 3'b000; // Reset counter when there is no message
        end else begin
            if (spi_clk_posedge)
            begin
                counter <= counter + 3'b001;
                data_in <= {data_in[6:0], spi_mosi};
                data_ready <= counter == 3'b111;
            end
            else
            begin
                if (spi_clk_negedge)
                    data_out <= spi_active; // Just write back one to let MCU know we are reading
            end
        end
    end
                
    assign byte_ready = data_ready;
    assign byte_out   = data_in;
    assign spi_miso   = data_out;
endmodule
