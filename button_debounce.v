`timescale 1ns / 1ps
module button_debounce 
#(
    parameter CNT_MAX = 64'd99_999 
)
(
    input wire clk,       
    input wire rst_n,    
    input wire key_in,   
    output reg key_out    

);

reg [63:0] cnt_20ms;    


always @(posedge clk or posedge rst_n) begin
    if (rst_n) 
        cnt_20ms <= 64'b0;
    else if (!key_in) 
        cnt_20ms <= 64'b0;
    else if (cnt_20ms == CNT_MAX && key_in) 
        cnt_20ms <= cnt_20ms;
    else 
        cnt_20ms <= cnt_20ms + 1'b1;
end
always @(posedge clk or posedge rst_n) begin
    if (rst_n) 
        key_out <= 1'b0;
    else if (cnt_20ms == CNT_MAX) 
        key_out <= 1'b1;
    else 
        key_out <= 1'b0;
end

endmodule