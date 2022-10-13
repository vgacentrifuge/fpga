module sram_demo_top(input clk,
                     input [3:0] switch,
                     input [3:0] button,
                     output [19:0] sram_addr,
                     inout [17:0] sram_data,
                     output [1:0] sram_bw,
                     output sram_advload,
                     output sram_we,
                     output [2:0] sram_ce,
                     output sram_oe,
                     output sram_cen,
                     output sram_clk,
                     output [15:0] led);
    reg [31:0] counter_val;
    wire [19:0] addr;
    wire [17:0] data_in;
    wire [17:0] data_out;
    wire write_enable;
    wire sram_clk_mid;
    
    sram_interface sram(
    .clk(counter_val[24]),
    .addr(addr),
    .data_in(data_in),
    .data_out(data_out),
    .write_enable(write_enable),
    .sram_addr(sram_addr),
    .sram_data(sram_data),
    .sram_bw(sram_bw),
    .sram_advload(sram_advload),
    .sram_write_enable(sram_we),
    .sram_chip_enable(sram_ce),
    .sram_oe(sram_oe),
    .sram_clk_enable(sram_cen),
    .sram_clk(sram_clk_mid)
    );
    
    always @(posedge clk) begin
        counter_val <= counter_val + 1;
    end
    
    
    assign led[11:0]      = 12'b0;
    assign led[12]       = sram_clk_mid;
    assign led[15:13]     = data_out[2:0];
    assign data_in[17:3] = 13'b0;
    assign data_in[2:0] = switch[2:0];
    assign write_enable = button[0];
    assign addr[19:1] = 19'b0;
    assign addr[0] = switch[3];
    assign sram_clk = sram_clk_mid;
    
endmodule
