/*
 * This module wraps signals for an SRAM chip
 * The read port guarantees data ready after 4 cycles
 * Write port may be written independently, and will delay by a single cycle if reading is attempted at the same time
 * Note that writing on two subsequent cycles may cause the second write to be ignored if the first is delayed by a read
 * Reading on two subsequent cycles will also cause a write during the first cycle to be ignored
 */
module sram_interface(
                      // module signals
                      input clk,
                      // Read line, guaranteed 4 cycle delay
                      input read_enable,
                      input [19:0] r_addr,
                      output [17:0] data_out,
                      output data_ready, // If read is issued, active when data is available
                      // Write line, eventual write guaranteed, but may be issued a cycle later if read conflicts
                      input write_enable,
                      input [19:0] w_addr,
                      input [17:0] data_in,
                      // SRAM signals
                      output [19:0] sram_addr,
                      inout [17:0] sram_data,
                      output [1:0] sram_bw,
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
    assign sram_bw          = 2'b0;


    // Latch register to store data till next sram negedge
    reg [19:0] addr_latch;
    reg we_latch;
    reg [17:0] data_latch;
    // Holding addr on sram
    reg [19:0] addr_hold;
    // offsetting data and write_enable two cycles 
    reg [17:0] data_wait_1;
    reg we_wait_1;
    reg [17:0] data_wait_2;
    reg we_wait_2;
    reg [17:0] data_hold;
    reg we_hold;
    // hold output
    reg [17:0] out_latch;
    reg data_ready_latch;
    // Write wait register, if line is occupied
    reg [19:0] w_addr_wait;
    reg [17:0] w_data_wait;
    reg we_wait;
    
    // Latch data on clk posedge
    always @(posedge clk) begin
        if (read_enable) begin
            // Read issued, delay write by one cycle
            addr_latch <= r_addr;
            we_latch <= 0;
            data_latch <= 18'b0;
            // Delay write
            w_addr_wait <= w_addr;
            w_data_wait <= data_in;
            we_wait <= write_enable;
        end else if (we_wait) begin
            // No read, write delayed last cycle
            addr_latch <= w_addr_wait;
            we_latch <= we_wait;
            data_latch <= w_data_wait;
        end else begin
            // No read, write as normal
            addr_latch <= w_addr;
            we_latch <= write_enable;
            data_latch <= data_in;
        end
        // latch output
        out_latch <= sram_data;
        data_ready <= ~write_enable;
    end
    // place onto sram on negedge, shift registers forward one tick
    always @(negedge clk) begin 
        addr_hold <= addr_latch;
        data_wait_1 <= data_latch;
        data_wait_2 <= data_wait_1;
        data_hold <= data_wait_2;
        we_wait_1 <= we_latch;
        we_wait_2 <= we_wait_1;
        we_hold <= we_wait_2;
    end


    
    assign sram_write_enable = ~we_wait_1;
    assign sram_oe           =  1'b0;
    assign sram_addr         = addr_hold;
    assign sram_clk          = clk;
    
    // control inout:
    assign sram_data = (we_hold)?data_hold:18'bz;
    assign data_out  = out_latch;
    
endmodule
