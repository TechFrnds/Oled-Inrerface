`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.02.2022 19:12:49
// Design Name: 
// Module Name: delay_gen
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module delay_gen(
    input clock,
    input delay_en,
    output reg delay_done
    );
    reg [17:0] counter;
    always@(posedge clock)
    begin
        if(delay_en & counter != 200000)
        begin
            counter<=counter+1;
        end
        else
            counter<=0;
    end
    
    always@(posedge clock)
    begin
        if(delay_en & counter == 200000)
        begin
            delay_done<=1'b1;
        end
        else
            delay_done<=1'b0;
    end    
endmodule
