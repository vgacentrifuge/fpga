module counter (input clk,
                input reset,
                output [31:0] value);
    reg [31:0] counter_register;
    
    always @(posedge clk)
    begin
        if (reset)
            counter_register <= 0;
        else
            counter_register <= counter_register + 1;
    end
    
    assign value = counter_register[31:0];
endmodule