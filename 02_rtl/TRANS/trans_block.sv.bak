module trans_block #(
    parameter SIZE_DATA     = 9     ,
    parameter OVER_SAMPLING = 16    ,
    parameter SIZE_BAUD     = 24
)(
    input logic                     i_clk       ,
    input logic                     i_rst_n     ,
    input logic                     i_tx_en     ,
    input logic                     i_en_wr     ,
    input logic [2:0]               i_size_frame,
    input logic [1:0]               i_parity_bit,
    input logic                     i_stop_bit  ,
    input logic [SIZE_DATA-1:0]     i_data      ,
    input logic [SIZE_BAUD-1:0]     i_baud_value,
    output logic                    o_data_tx   ,
    output logic                    o_done_tx
);
logic w_en_tx;
assign w_en_tx = i_tx_en & ~w_empty;
trans #(
    .SIZE_DATA     (9)     ,
    .OVER_SAMPLING (16)
) trans_unit (
    .i_clk                  (i_clk),
    .i_rst_n                (i_rst_n),
    .i_stick                (w_stick),
    .i_tx_en                (w_en_tx),
    .i_size_frame           (i_size_frame),
    .i_parity_bit           (i_parity_bit),
    .i_stop_bit             (i_stop_bit),
    .i_data                 (w_data),
    .o_data_tx              (o_done_tx),
    .o_done_tx              (o_done_tx)
);
logic [SIZE_DATA-1:0] w_data;
logic w_stick;
fifo #(
    .SIZE_DATA  (SIZE_DATA),
    .SIZE_DEPTH (16)
) fifo_trans (
    .i_clk                  (i_clk),
    .i_rst_n                (i_rst_n),
    .i_en_wr                (i_en_wr),
    .i_en_rd                (o_done_tx),
    .i_data                 (i_data),
    .o_data                 (w_data),
    .o_fifo_full            (),
    .o_fifo_empty           (w_empty)
);
logic w_empty;

baud_generator #(
    .SIZE_BAUD     (SIZE_BAUD)
) baud_generator_trans (
    .i_clk                  (i_clk),
    .i_rst_n                (i_rst_n),
    .i_baud_value           (i_baud_value),
    .o_stick                (w_stick)
);
endmodule

