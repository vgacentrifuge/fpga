module sram_demo_top(input clk,
                     input [3:0] switch,
                     input [3:0] button,
                     output [19:0] hw_sram_addr,
                     inout [17:0] hw_sram_data,
                     output [1:0] hw_sram_bw,
                     output hw_sram_advload,
                     output hw_sram_we,
                     output [2:0] hw_sram_ce,
                     output hw_sram_oe,
                     output hw_sram_cen,
                     output hw_sram_clk,
                     output [15:0] led);
    reg [31:0] counter_val;
    wire [19:0] addr;
    wire [17:0] data_in;
    wire [17:0] data_out;
    wire write_enable;
    
    sram_interface sram(
    .clk(counter_val[26]),
    .addr(addr),
    .data_in(data_in),
    .data_out(data_out),
    .write_enable(write_enable),
    .sram_addr(hw_sram_addr),
    .sram_data(hw_sram_data),
    .sram_bw(hw_sram_bw),
    .sram_advload(hw_sram_advload),
    .sram_write_enable(hw_sram_we),
    .sram_chip_enable(hw_sram_ce),
    .sram_oe(hw_sram_oe),
    .sram_clk_enable(hw_sram_cen),
    .sram_clk(hw_sram_clk)
    );
    
    always @(posedge clk) begin
        counter_val <= counter_val + 1;
    end
    
    
    assign led[11:1]      = 12'b0;
    assign led[0]       = counter_val[26];
    assign led[15:12]     = data_out[3:0];
    assign data_in[17:4] = 12'b0;
    assign data_in[3:0] = switch[3:0];
    assign write_enable = button[0];
    assign addr[19:0] = 19'b0;
    
endmodule
