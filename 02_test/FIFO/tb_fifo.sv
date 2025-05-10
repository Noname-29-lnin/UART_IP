`timescale 1us / 1ps
module tb_fifo;

  parameter SIZE_DATA = 8;
  parameter SIZE_DEPTH = 16;
  localparam SIZE_ADDR = $clog2(SIZE_DEPTH);

  logic w_clk, w_rst_n;
  always #25 w_clk = ~w_clk; // clock generation FREQ = 50MHz

  logic w_fifo_full, w_fifo_empty;
  logic [SIZE_DATA-1:0] w_idata;
  logic [SIZE_DATA-1:0] w_odata;
  logic w_wr_en, w_rd_en;

  fifo #(
         .SIZE_DATA  (SIZE_DATA ),
         .SIZE_DEPTH (SIZE_DEPTH)
       ) uut (
         .i_clk          (w_clk),        // clock for CPU
         .i_rst_n        (w_rst_n),      // active low reset
         .i_wr_en        (w_wr_en),      // Enable write
         .i_rd_en        (w_rd_en),      // Enable read
         .i_data         (w_idata),      // data to be sent
         .o_data         (w_odata),      // data received
         .o_fifo_full    (w_fifo_full),  // FIFO full signal
         .o_fifo_empty   (w_fifo_empty)  // FIFO empty signal
       );

  initial
  begin
    $dumpfile("tb_fifo.vcd");
    $dumpvars(0, tb_fifo);
  end

  initial
  begin
    w_clk   = 1'b0;
    w_rst_n = 1'b0;
    w_wr_en = 1'b0;
    w_rd_en = 1'b0;
    w_idata = '0;
    #50 w_rst_n = 1'b1; // release reset
    $display("Reset at time %t", $time);
    #100;

    // Test case 1: Reset operation
    $display("Test case 1: Reset operation");
    w_wr_en = 1'b0; // Disable write
    w_rd_en = 1'b0; // Disable read
    @(posedge w_clk);
    #1;
    $display("Time=%t \t| i_data=%d \t| FIFO[%d]=%d \t|  ptr_rd=%d \t| ptr_wr=%d \t| o_full=%d \t| o_empty=%d \t|", $time - 1, w_idata, 0, w_odata, uut.ptr_rd[SIZE_ADDR-2:0], uut.ptr_wr[SIZE_ADDR-2:0], w_fifo_full, w_fifo_empty);
    // Check FIFO empty and full status
    $display("FIFO empty status: %d, FIFO full status: %d", w_fifo_empty, w_fifo_full);
    // Check FIFO pointers
    if (uut.ptr_rd == 0 && uut.ptr_wr == 0)
    begin
      $display("FIFO pointers are reset");
    end
    else
    begin
      $display("FIFO pointers are not reset");
    end

    #100;

    // Test write operation
    $display("Test case 2: Write operation");
    w_wr_en = 1'b1; // Enable write
    w_rd_en = 1'b0; // Disable read
    for (int i = 0; i < ((SIZE_DEPTH * 2) - 1); i++)
    begin
      w_idata = i;
      @(posedge w_clk);
      #1;
      $display("Time=%t \t| i_data=%d \t| FIFO[%d]=%d \t|  ptr_rd=%d \t| ptr_wr=%d \t| o_full=%d \t| o_empty=%d \t|", $time - 1, w_idata, i, w_odata, uut.ptr_rd[SIZE_ADDR-2:0], uut.ptr_wr[SIZE_ADDR-2:0], w_fifo_full, w_fifo_empty);
    end

    #100;

    // Test read operation
    $display("Test case 3: Read operation");
    w_wr_en = 1'b0; // Enable write
    w_rd_en = 1'b1; // Disable read
    for (int i = 0; i < ((SIZE_DEPTH * 2) - 1); i++)
    begin
      @(posedge w_clk);
      #1;
      $display("Time=%t \t| i_data=%d \t| FIFO[%d]=%d \t|  ptr_rd=%d \t| ptr_wr=%d \t| o_full=%d \t| o_empty=%d \t|", $time - 1, w_idata, i, w_odata, uut.ptr_rd[SIZE_ADDR-2:0], uut.ptr_wr[SIZE_ADDR-2:0], w_fifo_full, w_fifo_empty);
    end

    

    // Test case 4: FIFO read and write operation
    $display("Test case 4: FIFO read and write operation");
    @(posedge w_clk);
    w_wr_en = 1'b1; // Enable write
    w_rd_en = 1'b0; // Disable read
    w_idata = 8'h00; // Write data
    #1;
    $display("Time=%t \t| i_data=%d \t| FIFO[%d]=%d \t|  ptr_rd=%d \t| ptr_wr=%d \t| o_full=%d \t| o_empty=%d \t|", $time - 1, w_idata, 0, w_odata, uut.ptr_rd[SIZE_ADDR-2:0], uut.ptr_wr[SIZE_ADDR-2:0], w_fifo_full, w_fifo_empty);
    
    for(int i = 0; i < ((SIZE_DEPTH * 2) - 1); i++)
    begin
        @(posedge w_clk);
        w_wr_en = 1'b1; // Enable write
        w_rd_en = 1'b1; // Enable read
        w_idata = 8'h01 + i;
        #1;
        $display("Time=%t \t| i_data=%d \t| FIFO[%d]=%d \t|  ptr_rd=%d \t| ptr_wr=%d \t| o_full=%d \t| o_empty=%d \t|", $time - 1, w_idata, i, w_odata, uut.ptr_rd[SIZE_ADDR-2:0], uut.ptr_wr[SIZE_ADDR-2:0], w_fifo_full, w_fifo_empty);
    end

    #100 $finish; // finish simulation
  end

endmodule
