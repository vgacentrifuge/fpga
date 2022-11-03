/*
 * Module that delays the signal by SHIFT_AMOUNT + half a clock cycle. This is
 * done by updating the output signal on the negedge of the clock in combination
 * with a shift register.
 */
module signal_half_delay #(parameter SHIFT_AMOUNT = 4)
                          (input clk,
                           input signal_in,
                           output reg signal_out
                           );
    reg [SHIFT_AMOUNT-1:0] shift_reg;
    
    always @(posedge clk)
        shift_reg <= {shift_reg[SHIFT_AMOUNT-2:0], signal_in};
    
    always @(negedge clk)
        signal_out <= shift_reg[SHIFT_AMOUNT-1];
endmodule
