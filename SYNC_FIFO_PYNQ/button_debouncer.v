`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/30/2026 03:50:02 PM
// Design Name: 
// Module Name: button_debouncer
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


module button_debouncer #(
    parameter CLK_FREQ = 125_000_000, // 125 MHz for PYNQ-Z2
    parameter DEBOUNCE_MS = 20        // 20 milliseconds bounce window
)(
    input  clk,
    input  rst,
    input  btn_in,
    output btn_pulse
);

    // Calculate max count for 20ms at 125 MHz
    localparam MAX_COUNT = (CLK_FREQ / 1000) * DEBOUNCE_MS;

    reg sync_0, sync_1;
    reg [$clog2(MAX_COUNT)-1:0] count;
    reg state;
    reg state_prev;

    // Stage 1: Synchronize asynchronous button input to clock domain
    always @(posedge clk) begin
        if (rst) begin
            sync_0 <= 0; 
            sync_1 <= 0;
        end else begin
            sync_0 <= btn_in; 3
        end
    end

    // Stage 2: Debounce counter
    always @(posedge clk) begin
        if (rst) begin
            count <= 0;
            state <= 0;
        end else begin
            if (sync_1 != state) begin
                count <= count + 1;
                // If stable for 20ms, register the new state
                if (count == MAX_COUNT - 1) begin
                    state <= sync_1;
                    count <= 0;
                end
            end else begin
                count <= 0; // Reset counter on glitch
            end
        end
    end

    // Stage 3: Edge Detector for single-pulse generation
    always @(posedge clk) begin
        if (rst) 
            state_prev <= 0;
        else 
            state_prev <= state;
    end

    // Pulse is high for exactly 1 clock cycle on the rising edge
    assign btn_pulse = state & ~state_prev;

endmodule
