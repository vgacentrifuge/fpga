// All the ports here are hardware ports
module top(input gclk100,
    
    // ADC 0
    input [15:0] colour_bus_0,
    input dataclkin_0,
    input vsin_0,
    input hsin_0,
    input fidin_0,


    // ADC 1
    input [15:0] colour_bus_1,
    input dataclkin_1,
    input vsin_1,
    input hsin_1,
    input fidin_1,    
    
    // DAC 0
    output [15:0] colour_bus_2,
    output hsync_out_0,
    output vsync_out_0,
    output dacclk_out_0,

    // SRAM
    inout [35:0] sram_data_bus_0,
    output [19:0] sram_addr_bus_0,
    output sram_ce1p3_0,
    output sram_ce2_0,
    output sram_cen_0,
    output sram_we_0,
    output sram_clk_0,
    output sram_oe_0,
    output sram_adv_ld_0,

    // Auxillary
    inout [23:0] auxio_bus_0
    );
    
endmodule
