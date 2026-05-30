`timescale 1ns / 1ps

module sync_fifo (
    input        clk,
    input        rst,
    input        wr_en,
    input        rd_en,
    input  [7:0] data_in,

    output       full,
    output       empty,
    output reg [7:0] data_out
);

    // FIFO Memory (64 x 8)
    reg [7:0] mem [0:63];

    // Read & Write Pointers
    reg [5:0] wr_ptr;
    reg [5:0] rd_ptr;

    // FIFO Counter
    reg [6:0] fifo_count;

    // Status Flags
    assign full  = (fifo_count == 64);
    assign empty = (fifo_count == 0);

    //--------------------------------------------------
    // Write Operation
    //--------------------------------------------------
    always @(posedge clk) begin
        if (wr_en && !full)
            mem[wr_ptr] <= data_in;
    end

    //--------------------------------------------------
    // Read Operation
    //--------------------------------------------------
    always @(posedge clk or posedge rst) begin
        if (rst)
            data_out <= 8'd0;
        else if (rd_en && !empty)
            data_out <= mem[rd_ptr];
    end

    //--------------------------------------------------
    // Pointer Logic
    //--------------------------------------------------
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

    //--------------------------------------------------
    // FIFO Counter Logic
    //--------------------------------------------------
    always @(posedge clk or posedge rst) begin
        if (rst)
            fifo_count <= 0;

        else if ((wr_en && !full) && (rd_en && !empty))
            fifo_count <= fifo_count;   // Read and Write together

        else if (wr_en && !full)
            fifo_count <= fifo_count + 1; // Write only

        else if (rd_en && !empty)
            fifo_count <= fifo_count - 1; // Read only

        else
            fifo_count <= fifo_count;     // No operation
    end

endmodule
