module sync_fifo (
    input  wire       clk,
    input  wire       rst,
    input  wire       wr_en,
    input  wire       rd_en,
    input  wire [7:0] data_in,  
    output reg  [7:0] data_out,
    output wire       full,
    output wire       empty
);

   
    reg [7:0] fifo_mem [0:7];

    
    reg [3:0] wr_ptr;
    reg [3:0] rd_ptr;

    
    assign empty = (wr_ptr == rd_ptr);
    assign full  = (wr_ptr[2:0] == rd_ptr[2:0]) && (wr_ptr[3] != rd_ptr[3]);

    
    always @(posedge clk) begin
        if (rst) begin
            wr_ptr <= 0;
        end else if (wr_en && !full) begin
            fifo_mem[wr_ptr[2:0]] <= data_in; 
            wr_ptr <= wr_ptr + 1;          
        end
    end

    
    always @(posedge clk) begin
        if (rst) begin
            rd_ptr <= 0;
            data_out <= 0;
        end else if (rd_en && !empty) begin
            data_out <= fifo_mem[rd_ptr[2:0]];
            rd_ptr <= rd_ptr + 1;              
        end
    end

endmodule