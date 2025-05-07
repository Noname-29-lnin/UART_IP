////////////////////////////////////////////////////////////////////////////
// Filename      : Rx_block.sv
// Description   : Receiver block
// Author        : Noname_29_lnin
// BAUDRATE_VALUE = FREQ / (BAUDRATE * 16) - 1
////////////////////////////////////////////////////////////////////////////
module Rx_block #(
    parameter SIZE_DATA      = 8,
    parameter BAUDRATE_VALUE = 325
)(
    input wire i_clk,
    input wire i_rst_n,
    input wire i_rx_en,
    input wire i_rx_data,
    output reg [SIZE_DATA-1:0] o_rx_parallel,
    output wire o_rx_done,
    output wire o_fifo_empty,
    output wire o_fifo_full
);

wire w_stick;
baud_generator #(
    .SIZE_BAUD(24), // 3byte
    .BAUDRATE_VALUE(BAUDRATE_VALUE)
) baud_generator (
    .i_clk       (i_clk)    ,   // clock for CPU
    .i_rst_n     (i_rst_n)  ,   // active low reset
    .o_stick     (w_stick)      // baud rate signal
);
wire w_fifo_empty, w_fifo_full;
wire [SIZE_DATA-1:0] w_rx_data;
fifo #(
    .SIZE_DATA  (SIZE_DATA), // data size
    .SIZE_DEPTH (16)         // FIFO depth
) fifo_unit (
    .i_clk        (i_clk)       , // clock for CPU
    .i_rst_n      (i_rst_n)     , // active low reset
    .i_wr_en      (o_rx_done)     , // Enable write
    .i_rd_en      (1'b0)            , // Enable read
    .i_data       (w_rx_data)   , // data to be sent
    .o_data       (o_rx_parallel) , // data received
    .o_fifo_full  (w_fifo_full)  , // FIFO full signal
    .o_fifo_empty (w_fifo_empty)  // FIFO empty signal
);
Receiver #(
    .SIZE_DATA   (8),
    .OVER_SAMPLE (16)
)(
    .i_clk          (i_clk), // clock for CPU
    .i_rst_n        (i_rst_n), // active low reset
    .i_stick        (w_stick), // baud rate signal
    .i_rx_en        (i_rx_en), // enable signal for receiver
    .i_fifo_full    (w_fifo_full), // FIFO full signal
    .i_rx_serial    (i_rx_data), // serial data to be received

    .o_rx_data      (w_rx_data), // data to be received parallel
    .o_rx_done      (o_rx_done) // end signal
);

assign o_fifo_empty = w_fifo_empty;
assign o_fifo_full  = w_fifo_full;

endmodule
