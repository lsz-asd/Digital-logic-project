`timescale 1ns / 1ps
module clock_divider(
    input clk_in,          
    input reset,           
    output reg clk_out     
);

    reg [63:0] counter =0; 

    always @(posedge clk_in or posedge reset) begin
        if (reset) begin
            counter <= 0;
            clk_out <= 0;
        end else begin
            if (counter == 50000) begin
                counter <= 0;
                clk_out <= ~clk_out;
            end else begin
                counter <= counter + 1;
            end
        end
    end
endmodule
