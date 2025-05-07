module fifo #(
    parameter SIZE_DATA  = 8,
    parameter SIZE_DEPTH = 16
)(
    input  wire i_clk                        , // clock for CPU
    input  wire i_rst_n                      , // active low reset
    input  wire i_wr_en                      , // Enable write
    input  wire i_rd_en                      , // Enable read
    input  wire [SIZE_DATA-1:0] i_data       , // data to be sent
    output reg  [SIZE_DATA-1:0] o_data       , // data received
    output reg  o_fifo_full                  , // FIFO full signal
    output reg  o_fifo_empty                 //, // FIFO empty signal
    // output reg  o_error_overrun              // overrun error signal
);

localparam SIZE_ADDR = $clog2(SIZE_DEPTH);

reg [SIZE_ADDR:0] ptr_wr, n_ptr_wr, ptr_rd, n_ptr_rd; // write and read pointers
assign o_fifo_empty = (ptr_rd == ptr_wr) ? 1 : 0;
// assign o_full = (n_ptr_wr == ptr_rd) ? 1 : 0;
assign o_fifo_full = (~|(ptr_rd[SIZE_ADDR-1:0] ^ ptr_wr[SIZE_ADDR-1:0])) & (ptr_rd[SIZE_ADDR] ^ ptr_wr[SIZE_ADDR]);

wire w_update_wr;
wire w_update_rd;
assign w_update_wr = (i_wr_en & ~o_fifo_full); // write update signal
assign w_update_rd = (i_rd_en & ~o_fifo_empty); // read update signal

assign n_ptr_wr = (w_update_wr) ? (ptr_wr + 1) : ptr_wr; // next write pointer
assign n_ptr_rd = (w_update_rd) ? (ptr_rd + 1) : ptr_rd; // next read pointer
always_ff @( posedge i_clk or negedge i_rst_n ) begin : proc_point
    if(~i_rst_n) begin
        ptr_wr <= '0;
        ptr_rd <= '0;
    end else begin
        if (w_update_wr) begin
            ptr_wr <= n_ptr_wr;
        end
        if (w_update_rd) begin
            ptr_rd <= n_ptr_rd;
        end
    end
end

reg [SIZE_DATA-1:0] fifo_mem [0:SIZE_DEPTH-1]; // FIFO memory
always_ff @(posedge i_clk or negedge i_rst_n) begin : proc_fifo_write
    if(~i_rst_n) begin
        o_data <= '0;
    end else begin
        if(w_update_wr) begin
            fifo_mem[ptr_wr[SIZE_ADDR-1:0]] <= i_data; // write data to FIFO 
        end else begin
            fifo_mem[ptr_wr[SIZE_ADDR-1:0]] <= fifo_mem[ptr_wr[SIZE_ADDR-1:0]]; // keep data in FIFO    
        end
    end
end
always_ff @( posedge i_clk or negedge i_rst_n ) begin : proc_fifo_read
    if(~i_rst_n) begin
        o_data <= '0;
    end else begin
        if(w_update_rd) begin
            o_data <= fifo_mem[ptr_rd[SIZE_ADDR-1:0]]; // read data from FIFO
        end else begin
            o_data <= o_data; // keep data in FIFO    
        end
    end
    
end

endmodule
