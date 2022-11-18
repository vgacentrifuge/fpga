module pixel_counter (
    input clk,
    output reg [9:0] counter_x,
    output reg [9:0] counter_y,
    output in_display_area
);
  parameter X_RES = 640;
  parameter Y_RES = 480;

  parameter H_SYNC = 96;
  parameter V_SYNC = 2;

  parameter H_FRONT_PORCH = 16;
  parameter V_FRONT_PORCH = 10;
  parameter H_BACK_PORCH = 48;
  parameter V_BACK_PORCH = 33;

  wire counter_x_max = (counter_x == (X_RES + H_SYNC + H_BACK_PORCH + H_FRONT_PORCH));
  wire counter_y_max = (counter_y == (Y_RES + V_SYNC + V_BACK_PORCH + V_FRONT_PORCH));

  always @(posedge clk)
    if (counter_x_max) counter_x <= 0;
    else counter_x <= counter_x + 1;

  always @(posedge clk) begin
    if (counter_x_max) begin
      if (counter_y_max) counter_y <= 0;
      else counter_y <= counter_y + 1;
    end
  end

  assign in_display_area = (counter_x < X_RES) && (counter_y < Y_RES);
endmodule
