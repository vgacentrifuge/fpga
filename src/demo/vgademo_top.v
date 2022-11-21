module vgademo_top(input gclk100,

                   output [15:0] colour_bus_2,
                   output hsync_out_0,
                   output vsync_out_0,
                   output dacclk_out_0);
    
    wire in_display_area;
    wire [9:0] pixel_x;
    wire [9:0] pixel_y;
    reg [15:0] pixel;
    
    wire clk25;
    clock_divider divider(
        .clk100(gclk100),
        .clk25(clk25)
    );
    
    pixel_counter counter(
        .clk(clk25),
        .counter_x(pixel_x),
        .counter_y(pixel_y),
        .in_display_area(in_display_area)
    );
    
    dac_handle dac(
        .clk25(clk25),
        .pixel_in(pixel),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .hw_colour_bus(colour_bus_2),
        .hw_hsync_out(hsync_out_0),
        .hw_vsync_out(vsync_out_0),
        .hw_dacclk_out(dacclk_out_0)
    );
    
    always @(posedge clk25)
    begin
        if (in_display_area)
            pixel <= {pixel_x, pixel_y[5:0]};
        else
            pixel <= 16'h0000;
    end
endmodule
