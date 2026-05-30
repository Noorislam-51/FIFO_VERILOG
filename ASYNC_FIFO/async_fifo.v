`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.05.2026 10:08:19
// Design Name: 
// Module Name: sync_fifo
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


module sync_fifo(
    input clk,
    input rst,
    input wr_en,
    input rd_en,
    
    output buf_full,buf_empty,
    input [7:0] data_in,
    output reg [7:0] data_out
    );
    
    reg [6:0]fifo_counter;
    reg [5:0]wr_ptr,rd_ptr;
    reg [7:0]mem[63:0];
    
    assign buf_empty=fifo_counter==0;
    assign buf_full=fifo_counter==64;
    
    always @(posedge clk or posedge rst)begin
        if(rst)
            fifo_counter<=0;
        else if ((!buf_full && wr_en)&&(!buf_empty&& rd_en))
            fifo_counter<=fifo_counter;
        else if (!buf_full&&wr_en)
            fifo_counter<=fifo_counter+1;
        else if (!buf_empty && rd_en)
            fifo_counter<=fifo_counter-1;
        else 
            fifo_counter<=fifo_counter;
    end
    
    always @(posedge clk or posedge rst)begin 
        if(rst)
            data_out<=0;
        else begin 
            if(rd_en&& !buf_empty)
                data_out<= mem[rd_ptr];
        end 
    end 
    
    always @(posedge clk)begin 
        if(wr_en && !buf_full)
            mem[wr_ptr]<=data_in;
    end 
    
    always @(posedge clk or posedge rst)begin 
        if (rst)begin
            wr_ptr<=0;
            rd_ptr<=0;
        end
        else begin 
            if(wr_en && !buf_full)
                wr_ptr<=wr_ptr+1;
                
            if(rd_en && !buf_empty)
                rd_ptr<=rd_ptr+1;            
        end
    end 
       
    
    
        
        
    
    
endmodule
