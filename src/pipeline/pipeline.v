module pipeline(// Background input recieved directly
                input [15:0] BGRGB,
                input [9:0] BGX,
                input [8:0] BGY,

                input pixelEnable, // Whether we are blanking screen

                // Foreground coord sent to SRAM, pixel recieved
                output [9:0] FGX,
                output [8:0] FGY,
                input  [15:0] FGRGB,

                // Resulting pixel
                output [15:0] pixelOut,

                // Control signals:
                input chroma_key
                // etc. etc.
                );

    assign pixelOut = BGRGB;
endmodule
