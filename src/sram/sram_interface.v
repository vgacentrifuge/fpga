/*
 * This module interfaces with an SRAM chip
 */
module sram_interface(
                      // module signals
                      input clk,
                      input write_enable,
                      input [19:0] addr,
                      output [17:0] data_out,
                      input [17:0] data_in,
                      // SRAM signals
                      output [19:0] sram_addr,
                      inout [17:0] sram_data,
                      output sram_advload,
                      output sram_write_enable,
                      output sram_chip_enable,
                      output sram_oe,
                      output sram_clk_enable,
                      output sram_clk);

    // Constant signals (for our purposes)
    assign sram_advload     = 0;
    assign sram_chip_enable = 1;
    assign sram_clk_enable  = 0;

    // Latch register to store data till next sram negedge
    reg [19:0] addr_latch;
    reg we_latch;
    reg [17:0] data_latch;
    // Holding addr on sram
    reg [19:0] addr_hold;
    reg we_hold;
    // offsetting data and OE two cycles 
    reg [17:0] data_wait_1;
    reg [17:0] data_wait_2;
    reg oe_wait_2; 
    reg [17:0] data_hold;
    reg oe_hold;
    // latch output
    reg [17:0] out_latch;

    // Latch data on clk posedge
    always @(posedge clk) begin
        addr_latch <= addr;
        we_latch <= write_enable;
        data_latch <= data_in;
    end
    // place onto sram on negedge, shift registers forward one tick
    always @(negedge clk) begin 
        addr_hold <= addr_latch;
        we_hold <= we_latch;
        data_wait_1 <= data_latch;
        oe_wait_2 <= we_hold;
        data_wait_2 <= data_wait_1;
        data_hold <= data_wait_2;
        oe_hold <= oe_wait_2;
    end


    
    assign sram_write_enable = ~we_hold;
    assign sram_oe           = oe_hold;
    assign sram_addr         = addr_hold;
    assign sram_clk          = clk;
    
    // control inout:
    assign sram_data = (oe_hold)?data_hold:18'bz;
    assign data_out  = out_latch;
    
endmodule
