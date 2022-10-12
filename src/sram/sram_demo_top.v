module sram_demo_top(input clk,
                     input reset,
                     input [3:0] switch,
                     input [2:0] button,
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
    reg [15:0] led_reg;
    reg [31:0] counter_val;
    wire [17:0] sram_data;
    wire [19:0] addr;
    wire [17:0] data_in;
    wire write_enable;
    wire sram_clk_mid;
    
    sram_interface sram(
    .clk(counter_val[27]),
    .addr(addr),
    .data_in(data_in),
    .data_out(sram_data),
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
        if (~reset)
            counter_val <= 0;
        else
            counter_val <= counter_val + 1;
    end
    
    always @(posedge counter_val[26]) begin
        led_reg[0:11] <= 14'b0;
        led_reg[13:15] <= sram_data[3:0];
    end
    
    assign led[0:11]      = led_reg[0:11];
    assign led[0:2]       = sram_clk_mid;
    assign led[13:15]     = led_reg[13:15];
    assign data_in[19:3] = 15'b0;
    assign data_in[2:0] = switch[2:0];
    assign write_enable = button[0];
    assign addr[19:1] = 16'b0;
    assign addr[0] = switch[3];
    assign sram_clk = sram_clk_mid
    
endmodule
