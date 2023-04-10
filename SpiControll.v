`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.02.2022 17:03:16
// Design Name: 
// Module Name: SpiControll
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


module SpiControll(
    input clock,
    input [7:0] data_in,
    input reset,
    input load_data,
    output reg done_send,
    output spi_clk,// 10 MHz max  
    output reg spi_data
    
);
    reg [1:0] state;
    reg [2:0] counter=0;
    reg [2:0] data_count;
    reg [7:0] shiftreg;
    reg clock_10;
    reg ce;
    assign spi_clk=(ce==1)?clock_10:1'b1;
    
    always@(posedge clock)
    begin
        if(counter!=4)
        begin
            counter <= counter+1;
        end
        else
            counter <= 0;
    end
    
    initial clock_10<=0;
        
    always@(posedge clock)
    begin
        if(counter==4)
        begin
            clock_10<=~clock_10;
        end
    end
    parameter IDLE= 'd0;
    parameter SEND= 'd1;
    parameter DONE= 'd2;
                
    always@(negedge clock_10)
    begin
        if(reset)
        begin
            state<=IDLE;
            data_count<=0;
            done_send<=1'b0;
            ce<=10;  
            spi_data<=1'b0;
        end
        else
        begin
            case(state)
                IDLE:begin
                    if(load_data)
                    begin
                        shiftreg<=data_in;
                        data_count<=0;
                        state<=SEND;
                    end
                end
                SEND:begin
                    spi_data <= shiftreg[7];
                    shiftreg <= {shiftreg[6:0],1'b0};
                    ce<=1;
                    if(data_count!=7)
                    begin
                        data_count<=data_count+1;
                    end
                    else
                    begin
                        state<=DONE;
                    end
                end
                DONE:begin
                    done_send<=1'b1;
                    ce<=0;
                    if(!load_data)
                    begin
                        done_send<=1'b0;
                        state<=IDLE;
                    end
                end
            endcase
        end
    end
endmodule
