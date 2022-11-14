module adc_input (
    input hw_pixel_clk,
    input [15:0] hw_rgb_in,

    input hw_vsync_in,
    input hw_hsync_in,

    output reg [15:0] fifo_write_data,
    output [10:0] pixel_x,
    output [10:0] pixel_y,
    output reg fifo_write_request
);

// contains position of pixel at posedge
reg [10:0] x;
reg [10:0] y;

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

    fifo_write_data <= 16'b0;
    fifo_write_request <= 1; // We always push to the fifo

    if(x < X_RES && y < Y_RES) begin
        // Use two MSB to signal start of new line and new column
        fifo_write_data <= hw_rgb_in;
    end
    
    x <= x+1;
    // If the next pixel is on x=0, start a new line
    if (x+1 == X_RES+H_FRONT_PORCH+H_SYNC+H_BACK_PORCH) begin
        x <= 0;
        y <= y+1;
        if (y+1 == Y_RES+V_FRONT_PORCH+V_SYNC+V_BACK_PORCH)
            y <= 0;
    end
        
    if(~h_sync_state && h_sync_history == 5'b11111) begin
        // Only update the x coord if we are at least a few pixels away from matching up with the given HSYNC
        if(x < X_RES + H_SYNC + H_FRONT_PORCH + HISTORY_WIDTH + 1 - H_SYNC_SIGNAL_HEADSTART - 3 
        || x > X_RES + H_SYNC + H_FRONT_PORCH + HISTORY_WIDTH + 1 - H_SYNC_SIGNAL_HEADSTART + 1)
            x <= X_RES + H_SYNC + H_FRONT_PORCH + HISTORY_WIDTH + 1 - H_SYNC_SIGNAL_HEADSTART;
        h_sync_state <= 1;
    end
    if(h_sync_state && h_sync_history == 5'b00000)
        h_sync_state <= 0;

    if(~v_sync_state && v_sync_history == 5'b11111) begin
        if (y < Y_RES + V_SYNC + V_FRONT_PORCH - 3 || y > Y_RES + V_SYNC + V_FRONT_PORCH + 1)
            y <= Y_RES + V_SYNC + V_FRONT_PORCH;
        // Once y wraps around to 0, the active area begins
        v_sync_state <= 1;
    end
    if(v_sync_state && v_sync_history == 5'b00000)
        v_sync_state <= 0;

    h_sync_history <= {h_sync_history[3:0], hw_hsync_in};
    v_sync_history <= {v_sync_history[3:0], hw_vsync_in};
end

// expose pixel coordinates
assign pixel_x = x;
assign pixel_y = y;

endmodule

