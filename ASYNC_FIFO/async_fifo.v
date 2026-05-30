`timescale 1ns / 1ps

module async_fifo (
    input  wr_clk,
    input  rd_clk,
    input  rst,

    input  wr_en,
    input  rd_en,

    input  [7:0] data_in,
    output reg [7:0] data_out,

    output full,
    output empty
);

    // FIFO memory
    reg [7:0] mem [0:63];

    // pointers
    reg [5:0] wr_ptr;
    reg [5:0] rd_ptr;

    // counter (simple method)
    reg [6:0] count;

    //----------------------------------------------------
    // EMPTY & FULL
    //----------------------------------------------------
    assign empty = (count == 0);
    assign full  = (count == 64);

    //----------------------------------------------------
    // WRITE OPERATION (write clock)
    //----------------------------------------------------
    always @(posedge wr_clk or posedge rst) begin
        if (rst) begin
            wr_ptr <= 0;
        end
        else if (wr_en && !full) begin
            mem[wr_ptr] <= data_in;
            wr_ptr <= wr_ptr + 1;
        end
    end

    //----------------------------------------------------
    // READ OPERATION (read clock)
    //----------------------------------------------------
    always @(posedge rd_clk or posedge rst) begin
        if (rst) begin
            rd_ptr   <= 0;
            data_out <= 0;
        end
        else if (rd_en && !empty) begin
            data_out <= mem[rd_ptr];
            rd_ptr   <= rd_ptr + 1;
        end
    end

    //----------------------------------------------------
    // COUNTER LOGIC (simple control)
    //----------------------------------------------------
    always @(posedge wr_clk or posedge rd_clk or posedge rst) begin
        if (rst)
            count <= 0;

        else begin
            // write only
            if (wr_en && !full && !(rd_en && !empty))
                count <= count + 1;

            // read only
            else if (rd_en && !empty && !(wr_en && !full))
                count <= count - 1;
        end
    end

endmodule
