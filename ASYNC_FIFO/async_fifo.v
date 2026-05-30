`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 30.05.2026 10:08:19
// Design Name: Synchronous FIFO
// Module Name: sync_fifo
// Description:
// 64 x 8-bit Synchronous FIFO Memory
// - Supports independent read and write operations
// - Provides FULL and EMPTY status flags
// - Uses read and write pointers for memory access
// - FIFO follows First-In First-Out data transfer mechanism
//////////////////////////////////////////////////////////////////////////////////

module sync_fifo(
    input clk,              // System clock
    input rst,              // Asynchronous reset
    input wr_en,            // Write enable
    input rd_en,            // Read enable

    output buf_full,        // FIFO full flag
    output buf_empty,       // FIFO empty flag

    input [7:0] data_in,    // Data input bus
    output reg [7:0] data_out // Data output bus
);

    // Counts number of occupied locations in FIFO
    reg [6:0] fifo_counter;

    // Write and Read pointers
    reg [5:0] wr_ptr, rd_ptr;

    // FIFO memory array (64 locations × 8 bits)
    reg [7:0] mem [63:0];

    // Empty flag asserted when FIFO contains no data
    assign buf_empty = (fifo_counter == 0);

    // Full flag asserted when FIFO is completely filled
    assign buf_full  = (fifo_counter == 64);

    //////////////////////////////////////////////////////////////////////
    // FIFO Counter Logic
    // Keeps track of number of valid data entries in FIFO
    //////////////////////////////////////////////////////////////////////
    always @(posedge clk or posedge rst) begin
        if (rst)
            fifo_counter <= 0;

        // Simultaneous read and write
        // Number of stored elements remains unchanged
        else if ((!buf_full && wr_en) && (!buf_empty && rd_en))
            fifo_counter <= fifo_counter;

        // Write only
        else if (!buf_full && wr_en)
            fifo_counter <= fifo_counter + 1;

        // Read only
        else if (!buf_empty && rd_en)
            fifo_counter <= fifo_counter - 1;

        else
            fifo_counter <= fifo_counter;
    end

    //////////////////////////////////////////////////////////////////////
    // Read Operation
    // Data is read from FIFO memory using read pointer
    //////////////////////////////////////////////////////////////////////
    always @(posedge clk or posedge rst) begin
        if (rst)
            data_out <= 0;

        else begin
            if (rd_en && !buf_empty)
                data_out <= mem[rd_ptr];
        end
    end

    //////////////////////////////////////////////////////////////////////
    // Write Operation
    // Data is stored into FIFO memory using write pointer
    //////////////////////////////////////////////////////////////////////
    always @(posedge clk) begin
        if (wr_en && !buf_full)
            mem[wr_ptr] <= data_in;
    end

    //////////////////////////////////////////////////////////////////////
    // Read and Write Pointer Update Logic
    //////////////////////////////////////////////////////////////////////
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            wr_ptr <= 0;    // Reset write pointer
            rd_ptr <= 0;    // Reset read pointer
        end
        else begin

            // Increment write pointer after successful write
            if (wr_en && !buf_full)
                wr_ptr <= wr_ptr + 1;

            // Increment read pointer after successful read
            if (rd_en && !buf_empty)
                rd_ptr <= rd_ptr + 1;
        end
    end

endmodule
