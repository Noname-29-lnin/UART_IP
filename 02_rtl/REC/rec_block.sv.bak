module rec_block #(
    parameter SIZE_DATA     = 9 ,
    parameter OVER_SAMPLING = 16
)(
    input logic                     i_clk   ,
    input logic                     i_rst_n ,
    input logic                     i_stick ,
    input logic                     i_rx_en ,
    input logic                     i_en_rd ,
    input logic [2:0]               i_size_frame    ,
    input logic [1:0]               i_parity_bit    ,
    input logic                     i_stop_bit      ,
    input logic                     i_data          ,
    output logic [SIZE_DATA-1:0]    o_data          ,
    output logic                    o_done_rx       ,
    output logic                    o_error_overun  ,
    output logic                    o_error_frame   ,
    output logic                    o_error_parity   
);

logic w_en_rx;
assign w_en_rx = i_rx_en & ~w_full;
rec #(
    .SIZE_DATA          (SIZE_DATA),
    .OVER_SAMPLING      (OVER_SAMPLING)
) rec_unit (
    .i_clk                      (i_clk),
    .i_rst_n                    (i_rst_n),
    .i_stick                    (w_stick),
    .i_rx_en                    (w_en_rx),
    .i_size_frame               (i_size_frame),
    .i_parity_bit               (i_parity_bit),
    .i_stop_bit                 (i_stop_bit),
    .i_data                     (i_data),
    .o_data                     (w_data),
    .o_done_rx                  (o_done_rx),
    .o_error_overun             (o_error_overun),
    .o_error_frame              (o_error_frame),
    .o_error_parity             (o_error_parity) 
);

logic [SIZE_DATA-1:0] w_data;
logic w_stick;
fifo #(
    .SIZE_DATA  (SIZE_DATA),
    .SIZE_DEPTH (16)
) fifo_rec (
    .i_clk                  (i_clk),
    .i_rst_n                (i_rst_n),
    .i_en_wr                (o_done_rx),
    .i_en_rd                (i_en_rd),
    .i_data                 (w_data),
    .o_data                 (o_data),
    .o_fifo_full            (w_full),
    .o_fifo_empty           ()
);
logic w_full;

baud_generator #(
    .SIZE_BAUD     (SIZE_BAUD)
) baud_generator_rec (
    .i_clk                  (i_clk),
    .i_rst_n                (i_rst_n),
    .i_baud_value           (i_baud_value),
    .o_stick                (w_stick)
);

endmodule
