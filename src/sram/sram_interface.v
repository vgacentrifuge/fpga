/*
 * This module interfaces with an SRAM chip.
 * Inputs and outputs are latched on posedge.
 * Write by sending address, data and write_enable HIGH
 * Read by sending address, and write_enable LOW. Data is ready and stable on data_out 4 cycles later.
 */
module sram_interface(
                      // module signals
                      input clk,
                      input write_enable,
                      input [19:0] addr,
                      output [16:0] data_out,
                      input [16:0] data_in,
                      
                      // SRAM signals
                      output [19:0] hw_sram_addr,
                      inout [16:0] hw_sram_data,
                      output hw_sram_advload,
                      output hw_sram_write_enable,
                      output hw_sram_chip_enable,
                      output hw_sram_oe,
                      output hw_sram_clk_enable,
                      output hw_sram_clk);
                      
    

    // Constant signals (for our purposes)
    assign hw_sram_advload     = 0; // active high, we don't burst
    assign hw_sram_chip_enable = 1; // active high
    assign hw_sram_clk_enable  = 0; // active low

    // Latch register to store input data on posedge till next sram negedge
    reg [19:0] addr_latch;
    reg we_latch;
    reg [16:0] data_in_latch;
    
    // Holding addr on sram, for neg to neg
    reg [19:0] addr_hold;
    reg we_hold; // Also serves as oe_wait_1
    
    // offsetting data and OE two cycles. All latched on negedge
    reg [16:0] data_wait_1;
    reg [16:0] data_wait_2;
    reg oe_wait_2;
    reg [16:0] data_hold;
    reg oe_hold;
    
    // latch output, on posedge
    reg [16:0] data_out_latch;

    // Latch data on clk posedge
    always @(posedge clk) begin
        addr_latch <= addr;
        we_latch <= write_enable;
        data_in_latch <= data_in;
        // Mask write data so we get blank pixels if we mess up and attempt to read data from a write cycle
        data_out_latch <= (oe_hold) ? 17'b0 : hw_sram_data; 
    end
    
    // place onto sram on negedge, shift registers forward one tick
    always @(negedge clk) begin 
        addr_hold <= addr_latch;
        we_hold <= we_latch;
        data_wait_1 <= data_in_latch;
        
        oe_wait_2 <= we_hold;
        data_wait_2 <= data_wait_1;
        
        data_hold <= data_wait_2;
        oe_hold <= oe_wait_2;
    end
    // Assign HW-signals
    assign hw_sram_write_enable = ~we_hold;
    // We only want OE to be active for half a cycle, as keeping it active a whole cycle messes up the next read cycle
    assign hw_sram_oe           = (oe_hold && ~clk); // Active low. When writing, we want NO output!
    assign hw_sram_addr         = addr_hold;
    
    // Phase shift the SRAM clock so we can be certain timing constraints are fulfilled
    clk_wiz_0 sram_clocker(
        .clk_in80(clk),
        .clk_out80shift(hw_sram_clk)
    );
    // control inout:
    // When OE is low (active), the SRAM can write data, so we tristate
    assign hw_sram_data = (hw_sram_oe)?data_hold:17'bz;

    // Connect output to latch
    assign data_out = data_out_latch;
endmodule
