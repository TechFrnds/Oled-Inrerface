`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.02.2022 18:09:10
// Design Name: 
// Module Name: top
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


module top(
    input clock,//100 Mhz
    input reset,
// oled interface 
    output  oled_spi_clk,
    output  oled_spi_data,
    output  oled_vdd,
    output  oled_vbat,
    output  oled_reset_n,
    output  oled_dc_n
    );
    
    parameter my_string="ThanksAnithaMam";
    parameter string_length=15;
    reg [7:0] send_data; 
    reg send_data_valid;
    reg state;
    wire send_done;
    integer byte_counter;
    parameter IDLE= 'd0,
              SEND= 'd1,
              DONE= 'd2; 
    
    always@(posedge clock)
    begin
       if(reset)
       begin
            state<=IDLE;
            byte_counter<=string_length;
            send_data_valid<=0;
       end
       else
       begin
            case(state)
                IDLE:begin
                    if(!send_done)
                    begin    
                        send_data<=my_string[(byte_counter*8-1)-:8];
                        send_data_valid<=1'b1;
                        state<=SEND;
                    end    
                end
                SEND:begin
                    if(send_done)
                    begin
                        send_data_valid<=1'b0;
                        byte_counter<=byte_counter-1;
                        if(byte_counter!=1)
                        begin
                            state<=IDLE;
                        end
                        else
                        begin
                            state<=DONE;
                        end
                    end
                end
                DONE:begin
                    state<=DONE;
                end
            endcase
       end 
    end
    
    
    oled_control OC(
    .clock(clock),//100 Mhz
    .reset(reset),
// oled interface 
    .oled_spi_clk(oled_spi_clk),
    .oled_spi_data(oled_spi_data),
    .oled_vdd(oled_vdd),
    .oled_vbat(oled_vbat),
    .oled_reset_n(oled_reset_n),
    .oled_dc_n(oled_dc_n),
    //
    .send_data(send_data),
    .send_data_valid(send_data_valid),
    .send_done(send_done)    
    );
endmodule
