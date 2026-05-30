`timescale 1ns / 1ps

module sync_fifo_tb;

    reg clk;
    reg rst;
    reg wr_en;
    reg rd_en;
    reg [7:0] data_in;

    wire full;
    wire empty;
    wire [7:0] data_out;

    // DUT Instantiation
    sync_fifo uut (
        .clk(clk),
        .rst(rst),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .data_in(data_in),
        .full(full),
        .empty(empty),
        .data_out(data_out)
    );

    // Clock Generation (10 ns period)
    always #5 clk = ~clk;

    initial begin
        $display("=================================================");
        $display(" Time\tWR\tRD\tData_In\tData_Out\tFull\tEmpty");
        $display("=================================================");

        clk = 0;
        rst = 1;
        wr_en = 0;
        rd_en = 0;
        data_in = 0;

        // Reset FIFO
        #10;
        rst = 0;

        // Write Data
        #10;
        wr_en = 1; data_in = 8'h11;

        #10;
        data_in = 8'h22;

        #10;
        data_in = 8'h33;

        #10;
        data_in = 8'h44;

        #10;
        wr_en = 0;

        // Read Data
        #10;
        rd_en = 1;

        #40;
        rd_en = 0;

        // Simultaneous Read & Write
        #10;
        wr_en = 1;
        rd_en = 1;
        data_in = 8'h55;

        #10;
        data_in = 8'h66;

        #10;
        wr_en = 0;
        rd_en = 0;

        #20;
        $finish;
    end

    // Monitor Signals
    initial begin
        $monitor("%0t\t%b\t%b\t%h\t%h\t%b\t%b",
                 $time, wr_en, rd_en,
                 data_in, data_out,
                 full, empty);
    end

endmodule
