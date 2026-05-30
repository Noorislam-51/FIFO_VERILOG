`timescale 1ns / 1ps

module sync_fifo_tb;

    reg clk;
    reg rst;
    reg wr_en;
    reg rd_en;
    reg [7:0] data_in;

    wire [7:0] data_out;
    wire full;
    wire empty;

    // DUT
    sync_fifo dut (
        .clk(clk),
        .rst(rst),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .data_in(data_in),
        .data_out(data_out),
        .full(full),
        .empty(empty)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin

        // Initialize
        rst     = 1;
        wr_en   = 0;
        rd_en   = 0;
        data_in = 8'h00;

        // Reset
        #20;
        rst = 0;

        // Write 8 values
        $display("Writing data into FIFO");
        repeat(8) begin
            @(posedge clk);
            wr_en   = 1;
            data_in = data_in + 8'h01;
        end

        @(posedge clk);
        wr_en = 0;

        // Check Full
        if(full)
            $display("FIFO FULL");
        else
            $display("FIFO NOT FULL");

        // Try writing when full
        @(posedge clk);
        wr_en = 1;
        data_in = 8'hFF;

        @(posedge clk);
        wr_en = 0;

        // Read all values
        $display("Reading data from FIFO");

        repeat(8) begin
            @(posedge clk);
            rd_en = 1;
        end

        @(posedge clk);
        rd_en = 0;

        // Check Empty
        if(empty)
            $display("FIFO EMPTY");
        else
            $display("FIFO NOT EMPTY");

        // Try reading when empty
        @(posedge clk);
        rd_en = 1;

        @(posedge clk);
        rd_en = 0;

        #20;
        $finish;

    end

    // Monitor signals
    initial begin
        $monitor(
            "Time=%0t | wr_en=%b rd_en=%b data_in=%h data_out=%h full=%b empty=%b wr_ptr=%d rd_ptr=%d",
            $time, wr_en, rd_en, data_in, data_out,
            full, empty,
            dut.wr_ptr, dut.rd_ptr
        );
    end

endmodule