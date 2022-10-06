module sram_interface(input clk,
                      input [19:0] addr,
                      input [17:0] data_in,
                      input write_enable,
                      output [17:0] data_out,
                      output [19:0] sram_addr,
                      inout [17:0] sram_data,
                      output [1:0] sram_bw,
                      output sram_advload,
                      output sram_write_enable,
                      output [2:0] sram_chip_enable,
                      output sram_oe,
                      output sram_clk_enable,
                      output sram_clk);
    
    // Timer registers to shift write data 2 cycles
    //reg write_in_2;
    //reg write_in_1;
    reg [17:0] data_in_2;
    reg [17:0] data_in_1;
    
    // Constant signals (for our purposes)
    assign sram_advload     = 0;
    assign sram_chip_enable = 3'b010;
    assign sram_clk_enable  = 0 ;
    assign sram_clk         = clk;
    assign sram_bw          = 2'b0;
    assign sram_oe          = 1'b0;
    
    // issue read/write
    
    
    
    always @(posedge clk) begin
        data_in_2 <= data_in;
        data_in_1 <= data_in_2;
        
    end
    
    assign sram_write_enable = ~write_enable;
    assign sram_addr         = addr;
    
    // control inout:
    assign sram_data = (1'b0)?data_in_1:18'bz;
    assign data_out  = sram_data;
    
endmodule
