`timescale 1ns / 1ps

module tb_async_fifo;

    reg wr_clk;
    reg rd_clk;
    reg rst;

    reg wr_en;
    reg rd_en;

    reg [7:0] data_in;
    wire [7:0] data_out;

    wire full;
    wire empty;

    // DUT
    async_fifo uut (
        .wr_clk(wr_clk),
        .rd_clk(rd_clk),
        .rst(rst),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .data_in(data_in),
        .data_out(data_out),
        .full(full),
        .empty(empty)
    );

    //--------------------------------------------------
    // Write Clock (10ns period)
    //--------------------------------------------------
    always #5 wr_clk = ~wr_clk;

    //--------------------------------------------------
    // Read Clock (14ns period - different clock)
    //--------------------------------------------------
    always #7 rd_clk = ~rd_clk;

    //--------------------------------------------------
    // Test Stimulus
    //--------------------------------------------------
    initial begin
        wr_clk = 0;
        rd_clk = 0;
        rst = 1;
        wr_en = 0;
        rd_en = 0;
        data_in = 0;

        #20;
        rst = 0;

        //--------------------------------------------------
        // WRITE DATA
        //--------------------------------------------------
        repeat (10) begin
            @(posedge wr_clk);
            wr_en = 1;
            data_in = data_in + 1;
        end

        wr_en = 0;

        //--------------------------------------------------
        // READ DATA
        //--------------------------------------------------
        #20;
        repeat (10) begin
            @(posedge rd_clk);
            rd_en = 1;
        end

        rd_en = 0;

        //--------------------------------------------------
        // MIXED OPERATION
        //--------------------------------------------------
        #20;
        fork
            begin
                repeat (10) begin
                    @(posedge wr_clk);
                    wr_en = 1;
                    data_in = data_in + 1;
                end
                wr_en = 0;
            end

            begin
                repeat (10) begin
                    @(posedge rd_clk);
                    rd_en = 1;
                end
                rd_en = 0;
            end
        join

        #50;
        $finish;
    end

    //--------------------------------------------------
    // Monitor output
    //--------------------------------------------------
    initial begin
        $monitor("Time=%0t | WR_EN=%b RD_EN=%b DATA_IN=%d DATA_OUT=%d FULL=%b EMPTY=%b",
                  $time, wr_en, rd_en, data_in, data_out, full, empty);
    end

endmodule
