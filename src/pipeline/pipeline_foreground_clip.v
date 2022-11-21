module pipeline_foreground_clip #(
    parameter PRECISION = 11,
    parameter RESOLUTION_X = 800,
    parameter RESOLUTION_Y = 600
) (
    input in_fg_request_active,
    input signed [PRECISION:0] fg_pixel_x,
    input signed [PRECISION:0] fg_pixel_y,

    input [PRECISION - 1:0] ctrl_fg_clip_left,
    input [PRECISION - 1:0] ctrl_fg_clip_right,
    input [PRECISION - 1:0] ctrl_fg_clip_top,
    input [PRECISION - 1:0] ctrl_fg_clip_bottom,

    output out_fg_request_active
);
    wire clip_left = fg_pixel_x < {1'b0, ctrl_fg_clip_left};
    wire clip_right = fg_pixel_x >= RESOLUTION_X - {1'b0, ctrl_fg_clip_right};
    wire clip_top = fg_pixel_y < {1'b0, ctrl_fg_clip_top};
    wire clip_bottom = fg_pixel_y >= RESOLUTION_Y - {1'b0, ctrl_fg_clip_bottom};
    wire clip = clip_left || clip_right || clip_top || clip_bottom;

    assign out_fg_request_active = in_fg_request_active && !clip;
endmodule
