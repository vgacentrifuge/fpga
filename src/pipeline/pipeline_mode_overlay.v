module pipeline_mode_overlay #(
    parameter PIXEL_SIZE = 16
) (
    input fg_pixel_ready,
    
    output use_fg_pixel
);
    assign use_fg_pixel = fg_pixel_ready;
endmodule