module baud_generator #(
    parameter SIZE_BAUD     = 24
)(
    input logic                 i_clk   ,
    input logic                 i_rst_n ,
    input logic [SIZE_BAUD-1:0] i_baud_value,
    output logic                o_stick
);

logic [SIZE_BAUD-1:0] bdr_count;
logic [SIZE_BAUD-1:0] n_bdr_count;

assign o_stick = (bdr_count == i_baud_value) ? 1'b1 : 1'b0;

assign n_bdr_count = (o_stick) ? '0 : bdr_count;
always_ff @(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) 
        bdr_count <= '0;
    else
        bdr_count <= n_bdr_count;
end 

endmodule

