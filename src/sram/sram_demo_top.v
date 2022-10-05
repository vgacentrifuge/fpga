module sram_demo_top(
                     input clk,
                     output [19:0] sram_addr,
                     inout [17:0] sram_data,
                     output [1:0] sram_bw,
                     output sram_advload,
                     output sram_we,
                     output [2:0] sram_ce,
                     output sram_oe,
                     output sram_cen,
                     output sram_clk,
                     output [15:0] led
                     );
    reg [15:0] led_reg;
    wire [31:0] counter_val
    wire [17:0] sram_data;
    wire reset;

    sram_interface sram(
        .clk(counter_val[27])
        .addr(addr)
        .data_in(18'b0)
        .data_out(sram_data)
        .write_enable(1'b0)
        .sram_addr(sram_addr)
        .sram_data(sram_data)
        .sram_bw(sram_bw)
        .sram_advload(sram_advload)
        .sram_write_enable(sram_we)
        .sram_chip_enable(sram_ce)
        .sram_oe(sram_oe)
        .sram_clk_enable(sram_cen)
        .sram_clk(sram_clk)
    );

    counter addr_counter(
        .clk(clk),
        .reset(reset),
        .double(1'b0),
        .value(counter_val)
    );

    always @(posedge counter_val[27]) begin
        led_reg <= sram_data[15:0];
    end

    assign led = led_reg;
    assign addr[3:0] = counter_val[31:28];
    assign addr[19:4] = 16'b0;

endmodule