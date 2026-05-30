`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.05.2026 11:00:04
// Design Name: 
// Module Name: sync_fifo_tb
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


module sync_fifo_tb;

    reg clk;
    reg rst;
    reg wr_en;
    reg rd_en;
    reg [7:0] data_in;

    wire buf_full;
    wire buf_empty;
    wire [7:0] data_out;

    // DUT
    sync_fifo uut (
        .clk(clk),
        .rst(rst),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .data_in(data_in),
        .buf_full(buf_full),
        .buf_empty(buf_empty),
        .data_out(data_out)
    );

    // Clock generation (10 ns period)
    always #5 clk = ~clk;

    integer i;

    initial begin
        clk = 0;
        rst = 1;
        wr_en = 0;
        rd_en = 0;
        data_in = 0;

        // Reset
        #20;
        rst = 0;

        //--------------------------------------------------
        // Write 10 values
        //--------------------------------------------------
        $display("Writing data...");

        for(i = 0; i < 10; i = i + 1) begin
            @(posedge clk);
            wr_en = 1;
            data_in = i + 8'hA0;
        end

        @(posedge clk);
        wr_en = 0;

        //--------------------------------------------------
        // Read 10 values
        //--------------------------------------------------
        $display("Reading data...");

        for(i = 0; i < 10; i = i + 1) begin
            @(posedge clk);
            rd_en = 1;
        end

        @(posedge clk);
        rd_en = 0;

        //--------------------------------------------------
        // Fill FIFO completely
        //--------------------------------------------------
        $display("Filling FIFO...");

        for(i = 0; i < 64; i = i + 1) begin
            @(posedge clk);
            wr_en = 1;
            data_in = i;
        end

        @(posedge clk);
        wr_en = 0;

        //--------------------------------------------------
        // Check Full Flag
        //--------------------------------------------------
        if(buf_full)
            $display("FIFO FULL detected successfully");
        else
            $display("FIFO FULL detection failed");

        //--------------------------------------------------
        // Empty FIFO completely
        //--------------------------------------------------
        $display("Emptying FIFO...");

        for(i = 0; i < 64; i = i + 1) begin
            @(posedge clk);
            rd_en = 1;
        end

        @(posedge clk);
        rd_en = 0;

        //--------------------------------------------------
        // Check Empty Flag
        //--------------------------------------------------
        if(buf_empty)
            $display("FIFO EMPTY detected successfully");
        else
            $display("FIFO EMPTY detection failed");

        //--------------------------------------------------
        // Simultaneous Read & Write
        //--------------------------------------------------
        $display("Testing simultaneous read/write...");

        @(posedge clk);
        wr_en = 1;
        data_in = 8'h55;

        @(posedge clk);
        wr_en = 1;
        rd_en = 1;
        data_in = 8'hAA;

        @(posedge clk);
        wr_en = 0;
        rd_en = 0;

        #50;

        $finish;
    end

    // Monitor
    initial begin
        $monitor("Time=%0t rst=%b wr=%b rd=%b data_in=%h data_out=%h count=%0d full=%b empty=%b",
                 $time, rst, wr_en, rd_en,
                 data_in, data_out,
                 uut.fifo_counter,
                 buf_full, buf_empty);
    end

endmodule
