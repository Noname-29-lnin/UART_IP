module fifo_archsyn #(
    parameter SIZE_DATA  = 8 ,
    parameter SIZE_DEPTH = 16
)(
    input logic                 i_clk_wr,
    input logic                 i_clk_rd,
    input logic                 i_rst_n ,

    input logic                 i_wr_en ,
    input logic                 i_rd_en ,

    input logic [SIZE_DATA-1:0]     i_data  ,
    output logic [SIZE_DATA-1:0]    o_data  ,

    output logic                    o_fifo_full ,
    output logic                    o_fifo_empty
);

endmodule

