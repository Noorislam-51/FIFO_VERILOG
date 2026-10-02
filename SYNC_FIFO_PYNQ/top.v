module top(
    input  [1:0] sw,      // Changed to 2-bit vector to match XDC
    input  sysclk,
    input  btn0,          // Raw RST button
    input  btn1,          // Raw WR_EN button
    input  btn2,          // Raw RD_EN button
    output [3:0] led      // LEDs: [1:0] Data Out, [2] Empty, [3] Full
);
    
    wire [1:0] data_out;
    wire full;
    wire empty;

    // 1. Declare NEW internal wires for the cleaned signals
    // Do NOT assign them to btn0 or btn1 here.
    wire wr_pulse;
    wire rd_pulse;

    // 2. Debouncer for Write Button (btn1)
    button_debouncer debounce_wr (
        .clk(sysclk),
        .rst(btn0),
        .btn_in(btn1),           // Raw button goes IN
        .btn_pulse(wr_pulse)     // Clean pulse comes OUT
    );

    // 3. Debouncer for Read Button (btn2)
    button_debouncer debounce_rd (
        .clk(sysclk),
        .rst(btn0),
        .btn_in(btn2),           // Raw button goes IN
        .btn_pulse(rd_pulse)     // Clean pulse comes OUT
    );

    // 4. Instantiate the FIFO using the cleaned pulse wires
    sync_fifo uut (
        .clk(sysclk),
        .rst(btn0),
        .wr_en(wr_pulse),        // Connected to clean write pulse
        .rd_en(rd_pulse),        // Connected to clean read pulse
        .data_in(sw),            // Connected directly to the switch vector
        .data_out(data_out),
        .empty(empty),
        .full(full)
    );
                
    // 5. Map outputs to LEDs
    assign led[1:0] = data_out; 
    assign led[2] = empty;
    assign led[3] = full;
    
endmodule