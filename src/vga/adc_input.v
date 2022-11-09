module vga_driver (
    input hw_pixel_clk,
    input [15:0] hw_rgb_in,

    input hw_vsync_in,
    input hw_hsync_in,

    output reg [17:0] fifo_write_data,
    output reg fifo_write_request);

// contains position of pixel at posedge
reg [9:0] x;
reg [9:0] y;

parameter X_RES = 800;
parameter Y_RES = 600;
    
parameter H_SYNC = 128;
parameter V_SYNC = 4;
    
parameter H_FRONT_PORCH = 40;
parameter V_FRONT_PORCH = 1;
parameter H_BACK_PORCH  = 88;
parameter V_BACK_PORCH  = 23;

// The ADC rgb has 18 cycles of latency, while HSYNC has 5. We compensate
parameter H_SYNC_SIGNAL_HEADSTART = 18-5;

reg h_sync_state;
reg v_sync_state;

parameter HISTORY_WIDTH = 5;
reg [4:0] h_sync_history;
reg [4:0] v_sync_history;

always @ (posedge hw_pixel_clk) begin

    fifo_write_data <= 18'b0;
    fifo_write_request <= 1; // We always push to the fifo

    if(x < X_RES && y < Y_RES) begin
        // Use two MSB to signal start of new line and new column
        fifo_write_data <= {x==0, y==0, hw_rgb_in};
    end
    if(x != X_RES) begin
        // If the next pixel is on x=0, start a new line
        if (x+1 == 0 && y != Y_RES)
            y <= y+1;
        x <= x+1;
    end

    if(~h_sync_state && h_sync_history == 5'b11111) begin
        x <= -H_BACK_PORCH + HISTORY_WIDTH + 1 - H_SYNC_SIGNAL_HEADSTART;
        // Once x wraps around to 0, the active area begins
        h_sync_state <= 1;
    end
    if(h_sync_state && h_sync_history == 5'b00000)
        h_sync_state <= 0;

    if(~v_sync_state && v_sync_history == 5'b11111) begin
        y <= -V_BACK_PORCH;
        // Once y wraps around to 0, the active area begins
        v_sync_state <= 1;
    end
    if(v_sync_state && v_sync_history == 5'b00000)
        v_sync_state <= 0;

    h_sync_history <= {h_sync_history[3:0], hw_hsync_in};
    v_sync_history <= {v_sync_history[3:0], hw_vsync_in};
end

endmodule

