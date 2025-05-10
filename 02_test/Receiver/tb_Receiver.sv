`timescale 1us/1ps
module tb_Receiver;

parameter SIZE_DATA = 8;
parameter OVER_SAMPLE = 16;
parameter MID_SAMPLE = 8;

logic w_clk, w_rst_n;
logic w_stick;
logic w_rx_en;
logic w_fifo_full;
logic w_idata;
logic [SIZE_DATA-1:0] w_odata;
logic w_rx_done;

always #10 w_clk = ~w_clk; // FREQUENCY = 50MHz

baud_generator #(
    .SIZE_BAUD      (24) ,// 3byte
    .BAUDRATE_VALUE (325) // BAUD=9600, OVER_SAMPLE=16
) baudrate (
    .i_clk          (w_clk),    // clock for CPU
    .i_rst_n        (w_rst_n),  // active low reset
    .o_stick        (w_stick)   // baud rate signal
);

Receiver #(
    .SIZE_DATA      (SIZE_DATA  ),
    .OVER_SAMPLE    (OVER_SAMPLE),
    .MID_SAMPLE     (MID_SAMPLE)
) uut (
    .i_clk          (w_clk), // clock for CPU
    .i_rst_n        (w_rst_n), // active low reset
    .i_stick        (w_stick), // baud rate signal
    .i_rx_en        (w_rx_en), // enable signal for receiver
    .i_fifo_full    (w_fifo_full), // FIFO full signal
    .i_rx_serial    (w_idata), // serial data to be received

    .o_rx_data      (w_odata), // data to be received parallel
    .o_rx_done      (w_rx_done) // end signal
);

initial begin
    $dumpfile("tb_Receiver.vcd");
    $dumpvars(0, tb_Receiver); 
    w_clk = 0;
end

initial begin
    w_rst_n = 0;
    w_idata = 1; // idle state
    #1000 w_rst_n = 1; // release reset
    w_rx_en = 1; // enable receiver
    w_fifo_full = 0; // FIFO not full
    #1000 $display("Start at time %t", $time);
    $display("Reset at time %t", $time);
    Creak_Frame(8'b01010101); // create frame
end

task automatic Creak_Frame(logic [SIZE_DATA-1:0] data);
    // create start bit
    integer count;
    w_idata = 1'b0; // start bit
    count = 0;
    $display("------------ Start Frame ------------");
    $display("At time first: %t, w_idata = %b, w_odata = %b, w_rx_done = %b", $time, w_idata, w_odata, w_rx_done);
    while (count < OVER_SAMPLE-1) begin
        @( posedge w_clk );
            if(w_stick) count = count + 1;
            else count = count;
    end

    $display("At time final: %t, w_idata = %b, w_odata = %b, w_rx_done = %b", $time, w_idata, w_odata, w_rx_done);
    // create data bits
    $display("------------ Data Frame ------------");
    for (int i = 0; i < SIZE_DATA; i++) begin
        w_idata = data[i];
        count = 0;
        $display("At time first: %t, w_idata = %b, w_odata = %b, w_rx_done = %b", $time, w_idata, w_odata, w_rx_done);
        while (count < OVER_SAMPLE-1) begin
            @( posedge w_clk );
            if(w_stick) count = count + 1;
            else count = count;
        end
        $display("At time final: %t, w_idata = %b, w_odata = %b, w_rx_done = %b", $time, w_idata, w_odata, w_rx_done);
    end
    // create stop bit
    w_idata = 1'b1; // stop bit
    count = 0;
    $display("------------ Stop Frame ------------");
    $display("At time first: %t, w_idata = %b, w_odata = %b, w_rx_done = %b", $time, w_idata, w_odata, w_rx_done);
    while (count < OVER_SAMPLE-1) begin
        @( posedge w_clk );
            if(w_stick) count = count + 1;
            else count = count;
    end
    $display("At time final: %t, w_idata = %b, w_odata = %b, w_rx_done = %b", $time, w_idata, w_odata, w_rx_done);
    $display("------------ End Frame ------------");
    
    count = 0;
    while (count < OVER_SAMPLE-1) begin
        @( posedge w_clk );
            if(w_stick) count = count + 1;
            else count = count;
    end
    $display("At time %t, w_idata = %b, w_odata = %b, w_rx_done = %b", $time, data, w_odata, w_rx_done);

    #1000;
    $display("Finish Frame at time %t", $time);
    $finish;
endtask //automatic 

endmodule
// `timescale 1ns/1ps
// module tb_Receiver;

// parameter SIZE_DATA = 8;
// parameter OVER_SAMPLE = 16;
// parameter MID_SAMPLE = 8;

// logic w_clk, w_rst_n;
// logic w_stick;
// logic w_rx_en;
// logic w_fifo_full;
// logic w_idata;
// logic [SIZE_DATA-1:0] w_odata;
// logic w_rx_done;

// always #10 w_clk = ~w_clk; // FREQUENCY = 50MHz

// baud_generator #(
//     .SIZE_BAUD      (24),       // 3 bytes
//     .BAUDRATE_VALUE (325)       // BAUD=9600, OVER_SAMPLE=16
// ) baudrate (
//     .i_clk          (w_clk),
//     .i_rst_n        (w_rst_n),
//     .o_stick        (w_stick)
// );

// Receiver #(
//     .SIZE_DATA      (SIZE_DATA),
//     .OVER_SAMPLE    (OVER_SAMPLE),
//     .MID_SAMPLE     (MID_SAMPLE)
// ) uut (
//     .i_clk          (w_clk),
//     .i_rst_n        (w_rst_n),
//     .i_stick        (w_stick),
//     .i_rx_en        (w_rx_en),
//     .i_fifo_full    (w_fifo_full),
//     .i_rx_serial    (w_idata),
//     .o_rx_data      (w_odata),
//     .o_rx_done      (w_rx_done)
// );

// initial begin
//     $dumpfile("tb_Receiver.vcd");
//     $dumpvars(0, tb_Receiver); 
//     w_clk = 0;
// end

// initial begin
//     w_rst_n = 0;
//     w_idata = 1; // Idle state
//     w_rx_en = 0;
//     w_fifo_full = 0;
//     #50 w_rst_n = 1; // Release reset
//     w_rx_en = 1; // Enable receiver
//     #1000 $display("Start simulation at time %t", $time);
//     Create_Frame(8'b01010101); // Test with data 01010101
// end

// task automatic Create_Frame(logic [SIZE_DATA-1:0] data);
//     integer count;
//     $display("------------ Start UART Frame ------------");

//     // Start bit
//     w_idata = 0; // Start bit is low
//     $display("Start bit at time %t: w_idata = %b", $time, w_idata);
//     count = 0;
//     while (count < OVER_SAMPLE-1) begin
//         @(posedge w_clk);
//         if (w_stick) count = count + 1;
//         else count = count;
//     end
//     $display("End start bit at time %t: w_odata = %b, w_rx_done = %b", $time, w_odata, w_rx_done);

//     // Data bits
//     $display("------------ Data Bits ------------");
//     for (int i = 0; i < SIZE_DATA; i++) begin
//         w_idata = data[i];
//         $display("Data bit %0d at time %t: w_idata = %b", i, $time, w_idata);
//         count = 0;
//         while (count < OVER_SAMPLE-1) begin
//             @(posedge w_clk);
//             if (w_stick) count = count + 1;
//             else count = count;
//         end
//         $display("End data bit %0d at time %t: w_odata = %b, w_rx_done = %b", i, $time, w_odata, w_rx_done);
//     end

//     // Stop bit
//     w_idata = 1; // Stop bit is high
//     $display("Stop bit at time %t: w_idata = %b", $time, w_idata);
//     count = 0;
//     while (count < OVER_SAMPLE-1) begin
//         @(posedge w_clk);
//         if (w_stick) count = count + 1;
//         else count = count;
//     end
//     $display("End stop bit at time %t: w_odata = %b, w_rx_done = %b", $time, w_odata, w_rx_done);

//     // Wait for receiver to complete
//     @(posedge w_clk);
//     $display("------------ End UART Frame ------------");
//     $display("Received data: w_odata = %b, w_rx_done = %b at time %t", w_odata, w_rx_done, $time);

//     // Verify received data
//     if (w_odata == data && w_rx_done == 1) begin
//         $display("Test PASSED: Received data matches transmitted data (%b)", data);
//     end else begin
//         $display("Test FAILED: Expected %b, got %b, w_rx_done = %b", data, w_odata, w_rx_done);
//     end

//     #1000;
//     $display("Simulation finished at time %t", $time);
//     $finish;
// endtask

// endmodule