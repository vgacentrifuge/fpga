module top(input clk,
           output [2:0] pixel,
           output hsync_out,
           output vsync_out);
    
    wire vga_clk;
    
    clock_divider clock_divider(
    .clk(clk),
    .vga_clk(vga_clk)
    );
    
    vgademo_top vgademo(
    .clk(vga_clk),
    .pixel(pixel),
    .hsync_out(hsync_out),
    .vsync_out(vsync_out)
    );
    
endmodule
