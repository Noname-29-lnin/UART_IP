module fifo #(
    parameter SIZE_DATA  = 8,
    parameter SIZE_DEPTH = 16
)(
    input logic                     i_clk       ,
    input logic                     i_rst_n     ,
    input logic                     i_en_wr     ,
    input logic                     i_en_rd     ,
    input logic [SIZE_DATA-1:0]     i_data      ,
    output logic [SIZE_DATA-1:0]    o_data      ,
    output logic                    o_fifo_full ,
    output logic                    o_fifo_empty
);

// logic [SIZE_DATA-1:0] fifo_mem [0:SIZE_DEPTH-1];

localparam SIZE_ADDR = $clog2(SIZE_DEPTH);
logic [SIZE_ADDR:0] ptr_wr, ptr_rd;
logic [SIZE_ADDR:0] n_ptr_wr, n_ptr_rd;

assign o_fifo_empty = (ptr_wr == ptr_rd) ? 1'b1 : 1'b0;
assign o_fifo_full  = (~|(ptr_rd[SIZE_ADDR-1:0]^ptr_wr[SIZE_ADDR-1:0])) & (ptr_rd[SIZE_ADDR] ^ ptr_wr[SIZE_ADDR]);

logic w_update_wr, w_update_rd;
assign w_update_wr = i_en_wr & ~o_fifo_full;
assign n_ptr_wr = (w_update_wr) ? (ptr_wr + 1'b1) : ptr_wr;
assign w_update_rd = i_en_rd & ~o_fifo_empty;
assign n_ptr_rd = (w_update_rd) ? (ptr_rd + 1'b1) : ptr_rd;

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) 
        ptr_wr <= '0;
    else
        ptr_wr <= n_ptr_wr;
end 

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) 
        ptr_rd <= '0;
    else
        ptr_rd <= n_ptr_rd;
end 

logic [SIZE_DATA-1:0] w_odata;
simple_dual_port_ram_single_clock #(
    .DATA_WIDTH(SIZE_DATA), 
    .ADDR_WIDTH(SIZE_ADDR)
) dual_port_ram (
	.data       (i_data),
	.read_addr  (ptr_rd[SIZE_ADDR-1:0]),
    .write_addr (ptr_wr[SIZE_ADDR-1:0]),
	.we         (w_update_wr),
    .clk        (i_clk),
	.q          (w_odata)
);

always @(*) begin
    if(w_update_rd)
        o_data = w_odata;
    else
        o_data = '0;
end 

endmodule

