// module Receiver #(
//     parameter SIZE_DATA = 8
// )(
//     input wire i_clk, // clock for CPU
//     input wire i_rst_n, // active low reset
//     input wire i_stick, // baud rate signal

//     input wire i_fifo_full, // FIFO full signal
//     input wire i_rx_serial, // serial data to be received

//     output wire [SIZE_DATA - 1 : 0] o_rx_data, // data to be received parallel
//     output wire o_rx_done // end signal
// );



// wire w_start_signal, w_state_start; // start signal for baud rate generator
// detect_negedge detect_negedge(
//     .i_clk                  (i_clk),
//     .i_rst_n                (i_rst_n),

//     .i_rx_serial            (i_rx_serial),
//     .i_rx_en                (i_fifo_full),

//     .o_start_signal        (w_start_signal),
//     .o_rx_in               (w_state_start)
// );

// localparam SIZE_STATUS = 3;
// localparam [SIZE_STATUS-1:0] IDLE        = 3'b000,
//                              START       = 3'b001,
//                              RECEIVER    = 3'b010,
//                              //PARYTY      = 3'b011,
//                              STOP_I      = 3'b100;
//                              //STOP_II     = 3'b101;
// reg [SIZE_STATUS-1:0] state, n_state;

// parameter SIZE_COUNT = 4;// 1start bit + 8 data bits + 1 parity bit + 2 stop bits
// reg [SIZE_COUNT-1:0] count, n_count; // counter for baud rate

// parameter SIZE_INDEX = 3; // 8bits
// reg [SIZE_INDEX-1:0] index, n_index; // counter for data bits

// localparam OVER_SAMPLE = 16;
// localparam MID_SAMPLE = 8; // Mid sample point
// wire t_count_16, t_count_8;
// assign t_count_16 = (count == (OVER_SAMPLE-1)) ? 1'b1 : 1'b0;
// assign t_count_8  = (count == (MID_SAMPLE-1)) ? 1'b1 : 1'b0;

// always_comb begin : proc_state
//     case(state)
//         IDLE: begin
//             n_state = w_start_signal ? START : IDLE; // phat hien canh xuong
//             n_count = '0;
//             n_index = '0;
//             // o_rx_done = 1'b0;
//         end
//         START: begin
//             if(i_stick) begin
//                 if(t_count_8)
//                     n_state = w_state_start ? IDLE : RECEIVER; // phat hien canh xuong
//                 else
//                     n_state = state;
               
//                 n_count = (t_count_8) ? '0 : count + 1;
//             end else begin
//                 n_state = START;
//                 n_count = count;
//             end
//             n_index = '0;
//             // o_rx_done = 1'b0;
//         end
//         RECEIVER: begin
//             if(i_stick) begin
//                 n_count = (t_count_16) ? '0 : count + 1;
//                 n_index = (t_count_16) ? index + 1 : index;
//                 if(t_count_16) 
//                     n_state = (index == (SIZE_DATA-1)) ? STOP_I : RECEIVER;
//                 else
//                     n_state = state; 
//             end else begin
//                 n_state = RECEIVER;
//                 n_count = count;
//                 n_index = index;
//             end
//             // o_rx_done = 1'b0;
//         end
//         // PARYTY: begin
//         //     n_state = STOP_I;
//         //     n_count = '0;
//         //     n_index = index;
//         // end
//         STOP_I: begin
//             if(i_stick) begin
//                 n_count = (t_count_16) ? '0 : count + 1;
//                 n_index = index;
//                 n_state = (t_count_16) ? IDLE : STOP_I;
//             end else begin
//                 n_state = STOP_I;
//                 n_count = count;
//                 n_index = index;
//             end
//             // o_rx_done = 1'b1;
//         end
//         default: begin
//             n_state = IDLE;
//             n_count = '0;
//             n_index = '0;
//             // o_rx_done = 1'b0;
//         end
//     endcase
// end
// always_ff @( posedge i_clk or negedge i_rst_n ) begin : proc_state_update
//     if(~i_rst_n) begin
//         state <= IDLE;
//         count <= '0;
//         index <= '0;
//     end else begin
//         state <= n_state;
//         count <= n_count;
//         index <= n_index;
//     end
// end

// // Output data
// reg t_rx_data [SIZE_DATA - 1 : 0];

// always_ff @( posedge i_clk or negedge i_rst_n ) begin : proc_rx_out
//     if(~i_rst_n) begin
//         t_rx_data[0] <= 1'b0;
//         t_rx_data[1] <= 1'b0;
//         t_rx_data[2] <= 1'b0;
//         t_rx_data[3] <= 1'b0;
//         t_rx_data[4] <= 1'b0;
//         t_rx_data[5] <= 1'b0;
//         t_rx_data[6] <= 1'b0;
//         t_rx_data[7] <= 1'b0;
//     end else begin
//         case(state)
//             IDLE, START, STOP_I: begin
//                 t_rx_data[0] <= 1'b0;
//                 t_rx_data[1] <= 1'b0;
//                 t_rx_data[2] <= 1'b0;
//                 t_rx_data[3] <= 1'b0;
//                 t_rx_data[4] <= 1'b0;
//                 t_rx_data[5] <= 1'b0;
//                 t_rx_data[6] <= 1'b0;
//                 t_rx_data[7] <= 1'b0;
//             end
//             RECEIVER: begin 
//                 if(t_count_16 & i_stick) begin
//                     t_rx_data[index] <= i_rx_serial;
//                 end
//             end
//             default: begin
//                 t_rx_data[0] <= 1'b0;
//                 t_rx_data[1] <= 1'b0;
//                 t_rx_data[2] <= 1'b0;
//                 t_rx_data[3] <= 1'b0;
//                 t_rx_data[4] <= 1'b0;
//                 t_rx_data[5] <= 1'b0;
//                 t_rx_data[6] <= 1'b0;
//                 t_rx_data[7] <= 1'b0;
//             end
//         endcase
//     end
// end

// assign o_rx_data = {t_rx_data[7], t_rx_data[6], t_rx_data[5], t_rx_data[4], t_rx_data[3], t_rx_data[2], t_rx_data[1], t_rx_data[0]}; // output data;
// assign o_rx_done = (state == STOP_I) ? 1'b1 : 1'b0; // end signal
// endmodule

module Receiver #(
    parameter SIZE_DATA = 8,
    parameter OVER_SAMPLE = 16,
    parameter MID_SAMPLE = 8
)(
    input wire i_clk, // clock for CPU
    input wire i_rst_n, // active low reset
    input wire i_stick, // baud rate signal
    input wire i_rx_en, // enable signal for receiver
    input wire i_fifo_full, // FIFO full signal
    input wire i_rx_serial, // serial data to be received

    output reg [SIZE_DATA - 1 : 0] o_rx_data, // data to be received parallel
    output wire o_rx_done // end signal
);

localparam SIZE_STATUS = 3;
localparam [SIZE_STATUS-1:0] IDLE        = 3'b000,
                             START       = 3'b001,
                             TRANSMIT    = 3'b010,
                             //PARYTY      = 3'b011,
                             STOP_I      = 3'b100;
                             //STOP_II     = 3'b101;
reg [SIZE_STATUS-1:0] state, n_state;

localparam SIZE_COUNT = 5;// 1start bit + 8 data bits + 1 parity bit + 2 stop bits
reg [SIZE_COUNT-1:0] count, n_count; // counter for data bits

localparam SIZE_INDEX = 4;
reg [SIZE_INDEX-1:0] index, n_index; // counter for data bits

// localparam MID_SAMPLE = OVER_SAMPLE / 2; // Mid sample point
// localparam MID_SAMPLE = 8;
wire w_update_sample, w_update_mid_sample, w_update_data, w_update_idle, w_idata;
assign w_update_sample = (count == OVER_SAMPLE-1) ? 1'b1 : 1'b0;
assign w_update_mid_sample = (count == MID_SAMPLE-1) ? 1'b1 : 1'b0;
assign w_update_data = (index == SIZE_DATA) ? 1'b1 : 1'b0;
assign w_update_idle = (i_rx_en & ~i_fifo_full);
assign w_idata = i_rx_serial;

// wire w_start_signal;
// wire w_state_start; // start signal for baud rate generator
// detect_negedge dectect_negedge(
//     .i_clk          (i_clk),
//     .i_rst_n        (i_rst_n),

//     .i_rx_serial    (i_rx_serial),
//     .i_rx_en        (i_rx_en & ~i_fifo_full),

//     .o_start_signal (w_start_signal),
//     .o_rx_in        () 
// );

always_comb begin : proc_state
    case(state)
        IDLE: begin
            n_state = (~w_idata & i_stick & w_update_idle) ? START : IDLE; // phat hien canh xuong
            n_count = '0;
            n_index = '0;
        end
        START: begin
            // if(i_stick) begin
            //     if(w_update_mid_sample) begin
            //         n_state = i_rx_serial ? IDLE : TRANSMIT; // bit start = 0
            //     end else begin
            //         n_state = START;
            //     end
            
            // end else begin
            //     n_state = START;
            //     n_count = count;
            // end
            n_state = (w_update_mid_sample) ? ((w_idata) ? IDLE : TRANSMIT) : START;
            n_count = (w_update_mid_sample) ? '0 : ((i_stick) ? count + 1'b1 : count);
            n_index = '0;
        end
        TRANSMIT: begin
            // if(i_stick) begin
            //     n_state = (w_update_sample) ? STOP_I : TRANSMIT;
            //     n_count = (w_update_sample) ? '0 : count + 1;
            //     n_index = (w_update_sample) ? index + 1 : index;
            // end else begin
            //     n_state = TRANSMIT;
            //     n_count = count;
            //     n_index = index;
            // end
            n_state = (w_update_sample & w_update_data) ? STOP_I : TRANSMIT;
            n_count = (w_update_sample) ? '0 : (i_stick ? count + 1'b1 : count);
            n_index = w_update_data ? index : ((w_update_sample) ? index + 1'b1 : index);
        end
        STOP_I: begin
            // if(i_stick) begin
            //     n_state = (w_update_sample) ? IDLE : STOP_I;
            //     n_count = (w_update_sample) ? '0 : count + 1;
            //     n_index = index;
            // end else begin
            //     n_state = STOP_I;
            //     n_count = count;
            //     n_index = index;
            // end
            n_state = (w_update_sample) ? IDLE : STOP_I;
            n_count = (w_update_sample) ? '0 : (i_stick ? count + 1 : count);
            n_index = index;
        end
        default: begin
            n_state = IDLE;
            n_count = '0;
            n_index = '0;
        end
    endcase
end
always_ff @(posedge i_clk or negedge i_rst_n) begin : proc_state_update
    if(~i_rst_n) begin
        state   <= IDLE;
        count   <= '0;
        index   <= '0;
    end else begin
        state   <= n_state;
        count   <= n_count;
        index   <= n_index;
    end
end

// Output data
reg t_rx_data [SIZE_DATA - 1 : 0];
reg w_rx_done;
always_ff @(posedge i_clk or negedge i_rst_n) begin : proc_rx_out
    if(~i_rst_n) begin
        t_rx_data[0] <= 1'b0;
        t_rx_data[1] <= 1'b0;
        t_rx_data[2] <= 1'b0;
        t_rx_data[3] <= 1'b0;
        t_rx_data[4] <= 1'b0;
        t_rx_data[5] <= 1'b0;
        t_rx_data[6] <= 1'b0;
        t_rx_data[7] <= 1'b0;
    end else begin
        case(state)
            // IDLE, START: begin
            //     t_rx_data[0] <= 1'b0;
            //     t_rx_data[1] <= 1'b0;
            //     t_rx_data[2] <= 1'b0;
            //     t_rx_data[3] <= 1'b0;
            //     t_rx_data[4] <= 1'b0;
            //     t_rx_data[5] <= 1'b0;
            //     t_rx_data[6] <= 1'b0;
            //     t_rx_data[7] <= 1'b0;
            // end
            TRANSMIT: begin 
                // if(w_update_sample & i_stick) begin
                //     t_rx_data[index] <= i_rx_serial;
                // end
                t_rx_data[index[SIZE_INDEX-2:0]] <= w_idata;
            end
            STOP_I: begin
                t_rx_data[0] <= t_rx_data[0];
                t_rx_data[1] <= t_rx_data[1];
                t_rx_data[2] <= t_rx_data[2];
                t_rx_data[3] <= t_rx_data[3];
                t_rx_data[4] <= t_rx_data[4];
                t_rx_data[5] <= t_rx_data[5];
                t_rx_data[6] <= t_rx_data[6];
                t_rx_data[7] <= t_rx_data[7];
            end
            default: begin
                t_rx_data[0] <= 1'b0;
                t_rx_data[1] <= 1'b0;
                t_rx_data[2] <= 1'b0;
                t_rx_data[3] <= 1'b0;
                t_rx_data[4] <= 1'b0;
                t_rx_data[5] <= 1'b0;
                t_rx_data[6] <= 1'b0;
                t_rx_data[7] <= 1'b0;
            end
        endcase
    end
end
always_ff @(posedge i_clk or negedge i_rst_n) begin : proc_rx_done
    if(~i_rst_n) begin
        w_rx_done <= 1'b0;
    end else begin
        w_rx_done <= ((state==STOP_I) && (n_state==IDLE)) ? 1'b1 : 1'b0; // end signal
    end
end

assign o_rx_data = (w_rx_done) ? {t_rx_data[7], t_rx_data[6], t_rx_data[5], t_rx_data[4], t_rx_data[3], t_rx_data[2], t_rx_data[1], t_rx_data[0]} : o_rx_data; // output data;
assign o_rx_done = w_rx_done; // end signal
endmodule 
