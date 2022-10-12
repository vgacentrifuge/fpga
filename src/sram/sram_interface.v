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

    // Constant signals (for our purposes)
    assign sram_advload     = 0;
    assign sram_chip_enable = 3'b010;
    assign sram_clk_enable  = 0 ;
    assign sram_clk         = clk;
    assign sram_bw          = 2'b0;
    assign sram_oe          = 1'b0;



    //SRAM clk:
    reg [1:0] counter_val;
    assign sram_clk = counter_val[1];
    always @(posedge clk) begin
        counter_val <= counter_val + 1;
    end

    // Latch register to store data till next sram negedge
    reg [19:0] addr_latch;
    reg write_latch;
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
    
    // Latch data on sram_posedge
    always @(posedge sram_clk) begin
        addr_latch <= addr;
        we_latch <= write_enable;
        data_latch <= data_in;
        // latch output
        out_latch <= sram_data;
    end
    // place onto sram on negedge, shift registers forward one tick
    always @(negedge sram_clk) begin 
        addr_hold <= addr_latch;
        data_wait_1 <= data_latch;
        data_wait_2 <= data_wait_1;
        data_hold <= data_wait_2;
        we_wait_1 <= we_latch;
        we_wait_2 <= we_wait_1;
        we_hold <= we_wait_2;
    end


    
    assign sram_write_enable = ~we_hold;
    assign sram_addr         = addr_hold;
    
    // control inout:
    assign sram_data = (we_hold)?data_hold:18'bz;
    assign data_out  = sram_data;
    
endmodule
