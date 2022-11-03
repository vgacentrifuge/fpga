/*
 * Module that delays the signal by SHIFT_AMOUNT clock cycles. This is
 * done by using a shift register.
 */
module signal_half_delay #(parameter SHIFT_AMOUNT = 4)
                          (input clk,
                           input signal_in,
                           output reg signal_out
                           );
    reg [SHIFT_AMOUNT-1:0] shift_reg;
    
    always @(posedge clk) begin
        shift_reg  <= {shift_reg[SHIFT_AMOUNT-2:0], signal_in};
        signal_out <= shift_reg[SHIFT_AMOUNT-1];
    end
endmodule
