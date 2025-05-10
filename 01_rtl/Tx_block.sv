////////////////////////////////////////////////////////////////////////////
// Filename      : Tx_block.sv
// Description   : Transmitter block
// Author        : Noname_29_lnin
// BAUDRATE_VALUE = FREQ / (BAUDRATE * 16) - 1
////////////////////////////////////////////////////////////////////////////
module Tx_block #(
    parameter SIZE_DATA      = 8,
    parameter BAUDRATE_VALUE = 325
)(
    input wire i_clk,
    input wire i_rst_n,
    input wire i_tx_en,
    input wire [SIZE_DATA-1:0] i_tx_data,
    output reg o_tx_serial,
    output wire o_tx_done,
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
wire [SIZE_DATA-1:0] w_tx_data;

fifo #(
    .SIZE_DATA  (SIZE_DATA), // data size
    .SIZE_DEPTH (16)         // FIFO depth
) fifo_unit (
    .i_clk        (i_clk)        , // clock for CPU
    .i_rst_n      (i_rst_n)      , // active low reset
    .i_wr_en      (1'b0)         , // Enable write
    .i_rd_en      (o_tx_done)    , // Enable read
    .i_data       (i_tx_data)    , // data to be sent
    .o_data       (w_tx_data)    , // data received
    .o_fifo_full  (w_fifo_full)  , // FIFO full signal
    .o_fifo_empty (w_fifo_empty)  // FIFO empty signal
);
Transmitter #(
    .SIZE_DATA (8),
    .OVER_SAMPLE (16) // oversampling
) Transmitter_unit (
    .i_clk        (i_clk), // clock for CPU
    .i_rst_n      (i_rst_n), // active low reset
    .i_stick      (w_stick), // baud rate signal
    .i_tx_en      (i_tx_en), // start signal
    .i_fifo_empty (w_fifo_empty), // FIFO empty signal
    .i_tx_data    (w_tx_data), // data to be transmitted parallel
    .o_tx_serial  (o_tx_serial), // serial data output 
    .o_tx_done    (o_tx_done)  // end signal
);

assign o_fifo_empty = w_fifo_empty;
assign o_fifo_full  = w_fifo_full;

endmodule
