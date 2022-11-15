module pipeline_spi_control #(
    parameter PRECISION = 11
)(
        input clk,
        
        // How to merge the background and foreground
        // 0: No foreground
        // 1: Chroma key'd
        // 2: Direct overlay
        output [1:0] ctrl_overlay_mode,
        
        // Foreground scaling, i.e. if we should change the size of the foreground
        // See pipeline_foreground_scale.v for more info
        output [1:0] ctrl_fg_scale,

        // Foreground offsets, i.e. where to position the foreground on the screen
        // See pipeline_foreground_offset.v for more info
        output signed [PRECISION:0] ctrl_fg_offset_x,
        output signed [PRECISION:0] ctrl_fg_offset_y

        // SPI HW interface
        input hw_spi_clk,
        input hw_spi_ss,
        input hw_spi_mosi,
        
        output hw_spi_miso,
);
    // TODO: Implement this module
endmodule