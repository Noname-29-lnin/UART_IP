`timescale 1us/1ps
module tb_Transmitter;

parameter SIZE_DATA = 8;
parameter OVER_SAMPLE = 16;
parameter MID_SAMPLE = 8;

logic w_clk, w_rst_n;
logic w_stick;
logic w_tx_en;
logic w_fifo_empty;
logic [SIZE_DATA-1:0] w_idata;
logic w_odata;
logic w_tx_done;

always #10 w_clk = ~w_clk; // FREQUENCY = 50MHz

baud_generator #(
    .SIZE_BAUD      (24) ,// 3byte
    .BAUDRATE_VALUE (325) // BAUD=9600, OVER_SAMPLE=16
) baudrate (
    .i_clk          (w_clk),    // clock for CPU
    .i_rst_n        (w_rst_n),  // active low reset
    .o_stick        (w_stick)   // baud rate signal
);

Transmitter #(
    .SIZE_DATA   (SIZE_DATA),
    .OVER_SAMPLE (OVER_SAMPLE)// oversampling
) uut (
    .i_clk          (w_clk), // clock for CPU
    .i_rst_n        (w_rst_n), // active low reset
    .i_stick        (w_stick), // baud rate signal
    .i_tx_en        (w_tx_en), // start signal
    .i_fifo_empty   (w_fifo_empty), // FIFO empty signal
    .i_tx_data      (w_idata), // data to be transmitted parallel
    .o_tx_serial    (w_odata), // serial data output 
    .o_tx_done      (w_tx_done) // end signal
);

initial begin
    $dumpfile("tb_Transmitter.vcd");
    $dumpvars(0, tb_Transmitter);
end

initial begin
    w_clk = 1'b0;
    w_rst_n = 1'b0;
    w_idata = '0;
    #1000;
    w_rst_n = 1'b1;
    w_tx_en = 1'b1;
    w_fifo_empty = 1'b0;
    w_idata = 8'b01010101;
    // while (1) begin
    //     if(uut.w_update_sample) begin
    //         $display("w_idata = &b \t| w_odata = %b",w_idata,  w_odata);
    //     end
    //     if(w_tx_done) begin
    //         #1000;
    //         $display("w_tx_done = %b", w_tx_done);
    //         $finish;
    //     end
    // end
    #1000000;
    $finish;
end

endmodule
