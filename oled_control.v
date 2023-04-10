`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.02.2022 18:21:02
// Design Name: 
// Module Name: oled_control
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


module oled_control(
    input clock,//100 Mhz
    input reset,
// oled interface 
    output wire oled_spi_clk,
    output wire oled_spi_data,
    output reg oled_vdd,
    output reg oled_vbat,
    output reg oled_reset_n,
    output reg oled_dc_n,
    //
    input [6:0] send_data,
    input send_data_valid,
    output reg send_done    
    );
    
    reg [4:0] state;
    reg [4:0] next_state;
    reg start_delay;
    reg [7:0] spi_data;
    reg spi_load_data;
    reg [1:0] curr_page;
    reg [7:0] coulmn_addr;
    reg [3:0] byte_counter;
    wire spi_done;
    wire delay_done;
    wire [63:0] char_bit_map;
    parameter IDLE =         'd0,
              DELAY=         'd1,
              INIT =         'd2,
              RESET=         'd3,
              CHARGE_PUMP  = 'd4,
              WAIT_SPI     = 'd5,
              CHARGE_PUMP1 = 'd6,
              PRE_CHARGE   = 'd7,
              PRE_CHARGE1  = 'd8,
              VBAT_ON      = 'd9,
              CONTRST      = 'd10,
              CONTRAST1    = 'd11,
              SEG_REMAP    = 'd12,
              SCAN_DIR     = 'd13,
              SET_COM     =  'd14,
              SET_COM1    =  'd15,
              DISPLAY_ON  =  'd16,
              FULL_DISPLAY=  'd17,
              DONE       =   'd18,
              PAGE_ADDR  =   'd19,
              PAGE_ADDR1  =  'd20,
              PAGE_ADDR2  =  'd21,
              COLOUMN_ADDR = 'd22,
              SEND_DATA    = 'd23;
              
              
              
    always@(posedge clock)
    begin
        if(reset)
        begin
            state<=IDLE;
            next_state<=IDLE;
            oled_vdd<=1'b1;
            oled_vbat<=1'b1;
            oled_reset_n<=1'b1;
            oled_dc_n<=1'b1;
            start_delay<=1'b0;
            spi_data<=8'b0;
            spi_load_data<=1'b0;
            curr_page<=0;
            send_done<=0;
            coulmn_addr<=0;
        end
        else
        begin
            case(state)
                IDLE:begin
                    oled_vbat<=1'b1;
                    oled_reset_n<=1'b1;
                    oled_dc_n<=1'b0;
                    oled_vdd<=1'b0;
                    state<= DELAY;
                    next_state<=INIT;
                end
                DELAY:begin
                    start_delay<=1'b1;
                    if(delay_done)
                    begin
                        state<=next_state;  
                        start_delay<=1'b0;
                    end    
                end
                INIT:begin
                    spi_data<= 'hAE;
                    spi_load_data<=1'b1;
                    if(spi_done)
                    begin
                        spi_load_data<=1'b0;
                        oled_reset_n<=1'b0;
                        state<=DELAY;
                        next_state<=RESET;
                    end  
                end
                RESET:begin
                    oled_reset_n<=1'b1;
                    state<=DELAY;
                    next_state<=CHARGE_PUMP;
                end
                CHARGE_PUMP:begin
                    spi_data<= 'h8D;
                    spi_load_data<=1'b1;
                    if(spi_done)
                    begin
                        spi_load_data<=1'b0;
                        state<=WAIT_SPI;
                        next_state<=CHARGE_PUMP1;
                    end  
                end
                WAIT_SPI:begin
                    if(!spi_done)
                    begin
                        state<=next_state;
                    end
                end
                CHARGE_PUMP1:begin
                    spi_data<= 'h14;
                    spi_load_data<=1'b1;
                    if(spi_done)
                    begin
                        spi_load_data<=1'b0;
                        state<=WAIT_SPI;
                        next_state<=PRE_CHARGE;
                    end  
                end
                PRE_CHARGE:begin
                    spi_data<= 'hD9;
                    spi_load_data<=1'b1;
                    if(spi_done)
                    begin
                        spi_load_data<=1'b0;
                        state<=WAIT_SPI;
                        next_state<=PRE_CHARGE1;
                    end  
                end
                PRE_CHARGE1:begin
                    spi_data<= 'hF1;
                    spi_load_data<=1'b1;
                    if(spi_done)
                    begin
                        spi_load_data<=1'b0;
                        state<=WAIT_SPI;
                        next_state<=VBAT_ON;
                    end  
                end
                VBAT_ON:begin
                    oled_vbat<=1'b0;
                    state<=DELAY;
                    next_state<=CONTRST;
                end
                CONTRST:begin
                    spi_data<= 'h81;
                    spi_load_data<=1'b1;
                    if(spi_done)
                    begin
                        spi_load_data<=1'b0;
                        state<=WAIT_SPI;
                        next_state<=CONTRAST1;
                    end 
                end
                CONTRAST1:begin
                    spi_data<= 'hFF;
                    spi_load_data<=1'b1;
                    if(spi_done)
                    begin
                        spi_load_data<=1'b0;
                        state<=WAIT_SPI;
                        next_state<=SEG_REMAP;
                    end 
                end
                SEG_REMAP:begin
                    spi_data<= 'hA0;
                    spi_load_data<=1'b1;
                    if(spi_done)
                    begin
                        spi_load_data<=1'b0;
                        state<=WAIT_SPI;
                        next_state<=SCAN_DIR;
                    end 
                end
                SCAN_DIR:begin
                    spi_data<= 'hC0;
                    spi_load_data<=1'b1;
                    if(spi_done)
                    begin
                        spi_load_data<=1'b0;
                        state<=WAIT_SPI;
                        next_state<=SET_COM;
                    end    
                end
                SET_COM:begin
                    spi_data<= 'hDA;
                    spi_load_data<=1'b1;
                    if(spi_done)
                    begin
                        spi_load_data<=1'b0;
                        state<=WAIT_SPI;
                        next_state<=SET_COM1;
                    end    
                end
                SET_COM1:begin
                    spi_data<= 'h00;
                    spi_load_data<=1'b1;
                    if(spi_done)
                    begin
                        spi_load_data<=1'b0;
                        state<=WAIT_SPI;
                        next_state<=DISPLAY_ON;
                    end    
                end
               DISPLAY_ON:begin
                    spi_data<= 'hAF;
                    spi_load_data<=1'b1;
                    if(spi_done)
                    begin
                        spi_load_data<=1'b0;
                        state<=WAIT_SPI;
                        next_state<=PAGE_ADDR;//FULL_DISPLAY;
                    end    
               end
               PAGE_ADDR:begin
                    spi_data<= 'h22;
                    spi_load_data<=1'b1;
                    oled_dc_n<=1'b0;
                    if(spi_done)
                    begin
                        spi_load_data<=1'b0;
                        state<=WAIT_SPI;
                        next_state<=PAGE_ADDR1;//FULL_DISPLAY;
                    end    
               end
               PAGE_ADDR1:begin
                    spi_data<=curr_page;
                    spi_load_data<=1'b1;
                    if(spi_done)
                    begin
                        spi_load_data<=1'b0;
                        state<=WAIT_SPI;
                        curr_page<=curr_page+1;
                        next_state<=PAGE_ADDR2;//FULL_DISPLAY;
                    end
               end
               PAGE_ADDR2:begin
                    spi_data<=curr_page;
                    spi_load_data<=1'b1;
                    if(spi_done)
                    begin
                        spi_load_data<=1'b0;
                        state<=WAIT_SPI;
                        next_state<=COLOUMN_ADDR;//FULL_DISPLAY;
                    end
               end
               COLOUMN_ADDR:begin
                    spi_data<= 'h10;
                    spi_load_data<=1'b1;
                    if(spi_done)
                    begin
                        spi_load_data<=1'b0;
                        state<=WAIT_SPI;
                        next_state<=DONE;//FULL_DISPLAY;
                    end   
               end
               /*FULL_DISPLAY:begin
                    spi_data<= 'hA5;
                    spi_load_data<=1'b1;
                    if(spi_done)
                    begin
                        spi_load_data<=1'b0;
                        state<=WAIT_SPI;
                        next_state<=DONE;
                    end    
               end*/ 
               DONE:begin
                    send_done<=1'b0;
                    if(send_data_valid & coulmn_addr != 128 & !send_done)
                    begin
                        state<=SEND_DATA;
                        byte_counter<=8;
                    end
                    else if(send_data_valid & coulmn_addr == 128 &!send_done)
                    begin
                        state<=PAGE_ADDR;
                        byte_counter<=8;
                        coulmn_addr<=0;
                    end
               end
               SEND_DATA:begin
                    spi_data<= char_bit_map[(byte_counter*8-1)-:8 ];
                    spi_load_data<=1'b1;
                    oled_dc_n<=1'b1;
                    if(spi_done)
                    begin
                        coulmn_addr<=coulmn_addr+1;
                        spi_load_data<=1'b0;
                        state<=WAIT_SPI;
                        if(byte_counter!=1)
                        begin
                            byte_counter<=byte_counter-1;
                            next_state<=SEND_DATA;
                        end
                        else
                        begin
                            next_state<=DONE;
                            send_done<=1'b1;
                        end
                    end    
               end                     
            endcase
        end
    end
    
    
    SpiControll spc(
    .clock(clock),
    .data_in(spi_data),
    .reset(reset),
    .load_data(spi_load_data),
    .done_send(spi_done),
    .spi_clk(oled_spi_clk),// 10 MHz max  
    .spi_data(oled_spi_data)   
    );
    
    
    //delay generation
    
    delay_gen dg(
    .clock(clock),
    .delay_en(start_delay),
    .delay_done(delay_done)
    );
    
    char_rom CR(
    .addr(send_data),
    .data(char_bit_map)
    );
endmodule
