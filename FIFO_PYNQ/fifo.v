`timescale 1ns / 1ps

module sync_fifo (
    input        clk,
    input        rst,
    input        wr_en,
    input        rd_en,
    input  [1:0]  data_in,

    output        full,
    output        empty,
    output reg [1:0] data_out
);

    reg [3:0] mem [0:15];

    reg [3:0] wr_ptr;
    reg [3:0] rd_ptr;

    reg [6:0] fifo_count;

    assign full  = (fifo_count == 16);
    assign empty = (fifo_count == 0);

    always @(posedge clk) begin
        if (wr_en && !full)
            mem[wr_ptr] <= data_in;
    end

    always @(posedge clk or posedge rst) begin
        if (rst)
            data_out <= 4'd0;
        else if (rd_en && !empty)
            data_out <= mem[rd_ptr];
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
        end
        else begin
            if (wr_en && !full)
                wr_ptr <= wr_ptr + 1;

            if (rd_en && !empty)
                rd_ptr <= rd_ptr + 1;
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst)
            fifo_count <= 0;

        else if ((wr_en && !full) && (rd_en && !empty))
            fifo_count <= fifo_count;

        else if (wr_en && !full)
            fifo_count <= fifo_count + 1;

        else if (rd_en && !empty)
            fifo_count <= fifo_count - 1;
    end

endmodule