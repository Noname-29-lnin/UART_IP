`timescale 1us / 1ps
module tb_baud_generator;

logic w_clk, w_rst_n;
logic w_stick;

baud_generator #(
    .SIZE_BAUD      (24 ),// 3byte
    .BAUDRATE_VALUE (325)
) uut (
    .i_clk       (w_clk), // clock for CPU
    .i_rst_n     (w_rst_n), // active low reset
    .o_stick     (w_stick)  // baud rate signal
);

always #25 w_clk = ~w_clk; // clock generation

initial begin
    $dumpfile("tb_baud_generator.vcd");
    $dumpvars(0, tb_baud_generator);
end

initial begin
    w_clk   = 1'b0;
    w_rst_n = 1'b0;
    #50 w_rst_n = 1'b1; // release reset
    $display("Reset at time %t", $time);
    wait(w_stick == 1'b1); // wait for baud rate signal
    $display("Baud rate signal is HIGH at time %t", $time);
    #100 $finish; // finish simulation
end

endmodule
