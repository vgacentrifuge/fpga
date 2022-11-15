// Slave SPI module with CPOL = 0 and CPHA = 0

// Uses the internal clock and oversamples the SPI clock. This makes a lot of stuff
// simpler to deal with (e. g. detecting start/end of messages)
module spi_slave (input clk,
                  input hw_spi_clk,
                  input hw_spi_ss,
                  input hw_spi_mosi,
                  output spi_active,
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
    
    // We were experiencing some issues with it sometimes missing messages. Suspect
    // this is due to noise on the SPI slave select line, so we use this buffer to
    // make it very biased towards remaining active
    reg [7:0] spi_ss_history;
    always @ (posedge clk)
        spi_ss_history <= {spi_ss_history[6:0], hw_spi_ss};
    
    // If any bit is low, consider it active. Being active for 1 cycle even if we
    // shouldn't be will not cause any issues. Being inactive for 1 cycle where we
    // should be active will cause big issues
    assign spi_active = spi_ss_history != 8'hFF;
    
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
            data_in <= {data_in[6:0], hw_spi_mosi};
            
            // If counter now rolls over, a byte is ready in data_in
            data_ready <= counter == 3'b111;
            counter <= counter + 3'b001;
        end else if (spi_clk_negedge) begin
            data_out <= spi_active; // Just write back one to let MCU know we are reading
            spi_clk_state <= 1'b0;
        end
    end
                
    assign byte_ready = data_ready;
    assign byte_out   = data_in;
    assign hw_spi_miso   = data_out;
endmodule
