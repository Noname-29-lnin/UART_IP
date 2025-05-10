////////////////////////////////////////////////////////////////////////////
// Filename      : baud_generator.sv
// Description   : baud rate generator
// Author        : Noname_29_lnin
// i_bdr_value = FREQ / (BAUDRATE * 16) - 1
////////////////////////////////////////////////////////////////////////////
module baud_generator #(
    parameter SIZE_BAUD      = 24 ,// 3byte
    parameter BAUDRATE_VALUE = 325
)(
    input wire i_clk       , // clock for CPU
    input wire i_rst_n     , // active low reset
    output wire o_stick     // baud rate signal
);
reg [SIZE_BAUD - 1 : 0] bdr_count, n_bdr_count; // baud rate counter

assign o_stick = (bdr_count == BAUDRATE_VALUE) ? 1'b1 : 1'b0; // baud rate signal

assign n_bdr_count = (o_stick) ? '0 : (bdr_count + 1'b1); // baud rate counter
always_ff @( posedge i_clk or negedge i_rst_n ) begin : proc_divider_baud
    if(~i_rst_n)
        bdr_count <= '0;
    else
        bdr_count <= n_bdr_count;
end
endmodule 
