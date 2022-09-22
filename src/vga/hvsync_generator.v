module hvsync_generator(input clk,
                        output vga_h_sync,
                        output vga_v_sync,
                        output reg inDisplayArea,
                        output reg [9:0] CounterX,
                        output reg [9:0] CounterY);
    reg vga_HS, vga_VS;

    parameter X_RES = 640;
    parameter Y_RES = 480;
    
    parameter H_SYNC = 96;
    parameter V_SYNC = 2;

    parameter H_FRONT_PORCH = 16;
    parameter V_FRONT_PORCH = 10;
    parameter H_BACK_PORCH = 48;
    parameter V_BACK_PORCH = 33;
    
    wire CounterXmaxed = (CounterX == (X_RES + H_SYNC + H_BACK_PORCH + H_FRONT_PORCH));
    wire CounterYmaxed = (CounterY == (Y_RES + V_SYNC + V_BACK_PORCH + V_FRONT_PORCH)); // 10 + 2 + 33 + 480
    
    always @(posedge clk)
        if (CounterXmaxed)
            CounterX <= 0;
        else
            CounterX <= CounterX + 1;
    
    always @(posedge clk)
    begin
        if (CounterXmaxed)
        begin
            if (CounterYmaxed)
                CounterY <= 0;
            else
                CounterY <= CounterY + 1;
        end
    end
    
    always @(posedge clk)
    begin
        vga_HS <= (CounterX > (X_RES + H_FRONT_PORCH) && (CounterX < (X_RES + H_SYNC + H_BACK_PORCH + H_FRONT_PORCH)));   // active for 96 clocks
        vga_VS <= (CounterY > (Y_RES + V_FRONT_PORCH) && (CounterY < (Y_RES + V_SYNC + V_BACK_PORCH + V_FRONT_PORCH)));    // active for 2 clocks
    end
    
    always @(posedge clk)
    begin
        inDisplayArea <= (CounterX < X_RES) && (CounterY < Y_RES);
    end
    
    // Active high cuz why not
    assign vga_h_sync = vga_HS;
    assign vga_v_sync = vga_VS;
    
endmodule
