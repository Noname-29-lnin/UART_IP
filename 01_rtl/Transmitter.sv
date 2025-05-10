// module Transmitter #(
//     parameter SIZE_DATA = 8//,
//     // parameter OVER_SAMPLE = 16 // oversampling
// )(
//     input wire i_clk, // clock for CPU
//     input wire i_rst_n, // active low reset
//     input wire i_stick, // baud rate signal
//     input wire i_tx_go, // start signal
//     input wire [SIZE_DATA - 1 : 0] i_tx_data, // data to be transmitted parallel
//     output reg o_tx_serial, 
//     output wire o_tx_done // end signal
// );

//     // localparam MID_SAMPLE = OVER_SAMPLE / 2; // Mid sample point

//     localparam SIZE_STATUS = 3;
//     localparam [SIZE_STATUS-1:0] IDLE        = 3'b000,
//                                  START       = 3'b001,
//                                  TRANSMIT    = 3'b010,
//                                  //PARYTY      = 3'b011,
//                                  STOP_I      = 3'b100;
//                                  //STOP_II     = 3'b101;
//     reg [SIZE_STATUS-1:0] state, n_state;
    
//     localparam SIZE_COUNT = 4;// 1start bit + 8 data bits + 1 parity bit + 2 stop bits
//     reg [SIZE_COUNT-1:0] count, n_count; // counter for baud rate
    
//     localparam SIZE_INDEX = 3; // 8bits
//     reg [SIZE_INDEX-1:0] index, n_index; // counter for data bits

//     always_comb begin : proc_state
//         case(state)
//             IDLE: begin
//                 n_state = i_tx_go ? START : IDLE;
//                 n_count = '0;
//                 n_index = '0;
//                 o_tx_done = 1'b0;
//             end
//             START: begin
//                 n_state = (i_stick) ? TRANSMIT : START;
//                 n_count = '0;
//                 n_index = '0;
//                 o_tx_done = 1'b0;
//             end
//             TRANSMIT: begin
//                 n_state = (count == SIZE_DATA-1) ? STOP_I : TRANSMIT;
//                 n_count = (i_stick) ? count + 1 : count;
//                 n_index = (i_stick) ? index + 1 : index;
//                 o_tx_done = 1'b0;
//             end
//             // PARYTY: begin
//             //     n_state = STOP_I;
//             //     n_count = '0;
//             //     n_index = index;
//             //     o_tx_done = 1'b0;
//             // end
//             STOP_I: begin
//                 n_state = (i_stick) ? IDLE : STOP_I;
//                 n_count = '0;
//                 n_index = index;
//                 o_tx_done = 1'b0;
//             end
//             // STOP_II: begin
//             //     n_state = IDLE;
//             //     n_count = '0;
//             //     n_index = index;
//             //     o_tx_done = 1'b1;
//             // end
//             default: begin
//                 n_state = IDLE;
//                 n_count = '0;
//                 n_index = '0;
//                 o_tx_done = 1'b0;
//             end
//         endcase         
//     end
//     always_ff @( posedge i_clk or negedge i_rst_n ) begin : proc_state_update
//         if(~i_rst_n) begin
//             state   <= IDLE;
//             count   <= '0;
//             index   <= '0;
//         end else begin
//             state   <= n_state;
//             count   <= n_count;
//             index   <= n_index;
//         end
        
//     end
//     always_ff @( posedge i_clk or negedge i_rst_n ) begin : proc_tx_out
//         if(~i_rst_n) begin
//             o_tx_serial <= 1'b1; // idle state is HIGH
//         end else begin
//             case(state)
//                 IDLE       : o_tx_serial <= 1'b1; // idle state is HIGH
//                 START      : o_tx_serial <= 1'b0; // start bit is LOW
//                 TRANSMIT   : o_tx_serial <= i_tx_data[index]; // data bits
//                 // PARYTY     : o_tx_serial <= 1'b0; // parity bit
//                 STOP_I     : o_tx_serial <= 1'b1; // stop bit I
//                 // STOP_II    : o_tx_serial <= 1'b1; // stop bit II
//                 default    : o_tx_serial <= 1'b1;
//             endcase
//         end
//     end

// endmodule


module Transmitter #(
    parameter SIZE_DATA = 8,
    parameter OVER_SAMPLE = 16 // oversampling
)(
    input wire i_clk                        , // clock for CPU
    input wire i_rst_n                      , // active low reset
    input wire i_stick                      , // baud rate signal
    input wire i_tx_en                      , // start signal
    input wire i_fifo_empty                 , // FIFO empty signal
    input wire [SIZE_DATA - 1 : 0] i_tx_data, // data to be transmitted parallel
    output reg o_tx_serial                  , // serial data output 
    output wire o_tx_done                     // end signal
);

localparam SIZE_STATUS = 3;
localparam [SIZE_STATUS-1:0] IDLE        = 3'b000,
                             START       = 3'b001,
                             TRANSMIT    = 3'b010,
                             //PARYTY      = 3'b011,
                             STOP_I      = 3'b100;
                             //STOP_II     = 3'b101;
reg [SIZE_STATUS-1:0] state, n_state;

localparam SIZE_INDEX = 4; // 8bits
reg [SIZE_INDEX-1:0] index, n_index; // counter for data bits
wire w_update_data;
assign w_update_data = (index == SIZE_DATA-1) ? 1'b1 : 1'b0;

localparam SIZE_COUNT = 5;// 1start bit + 8 data bits + 1stop bit
reg [SIZE_COUNT-1:0] count, n_count; // counter for data bits
wire w_update_sample;
assign w_update_sample = (count == OVER_SAMPLE-1) ? 1'b1 : 1'b0;

wire w_update_start;
assign w_update_start = i_tx_en & ~i_fifo_empty; 

always_comb begin : proc_state
    case(state) 
        IDLE: begin
            n_state = w_update_start ? START : IDLE;
            n_count = '0;
            n_index = '0;
        end
        START: begin
            // if(i_stick) begin
            //     n_state = (w_update_sample) ? TRANSMIT : START;
            //     n_count = (w_update_sample) ? '0 : count + 1;
            // end else begin
            //     n_state = START;
            //     n_count = count;
            // end
            n_state = (w_update_sample) ? TRANSMIT : START;
            n_count = (w_update_sample) ? '0 : (i_stick ? count + 1'b1 : count);
            n_index = '0;
        end
        TRANSMIT: begin
            // if(i_stick) begin
            //     n_state = (w_update_sample) ? TRANSMIT : TRANSMIT;
            //     n_count = (w_update_sample) ? '0 : count + 1;
            //     n_index = (w_update_sample) ? index + 1 : index;
            // end else begin
            //     n_state = TRANSMIT;
            //     n_count = count;
            //     n_index = index;
            // end
            // n_state = (i_stick) ? ((w_update_sample & w_update_data) ? STOP_I : TRANSMIT) : TRANSMIT;
            n_state = (w_update_sample & w_update_data) ? STOP_I : TRANSMIT;
            n_count = (w_update_sample) ? '0 : (i_stick ? count + 1'b1 : count);
            n_index = (w_update_data) ? index : (w_update_sample ? index + 1'b1 : index);
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
            n_count = (w_update_sample) ? '0 : (i_stick ? count + 1'b1 : count);
            n_index = index;
        end
        default: begin
            n_state = IDLE;
            n_count = '0;
            n_index = '0;
        end
    endcase
end
always_ff @( posedge i_clk or negedge i_rst_n ) begin : proc_state_update
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

reg w_tx_done;
always_ff @( posedge i_clk or negedge i_rst_n ) begin : proc_tx_out
    if(~i_rst_n) begin
        o_tx_serial <= 1'b1; // idle state is HIGH
        w_tx_done <= 1'b0;
    end else begin
        case(state)
            IDLE : begin 
                o_tx_serial <= 1'b1; // idle state is HIGH
            end
            START: begin
                o_tx_serial <= 1'b0; // start bit is LOW
            end
            TRANSMIT: begin
                o_tx_serial <= i_tx_data[index[SIZE_INDEX-2:0]]; // data bits
            end
            STOP_I: begin
                o_tx_serial <= 1'b1; // stop bit I
            end
            default: begin
                o_tx_serial <= 1'b1; // idle state is HIGH
            end
        endcase
    end
end
always_ff @( posedge i_clk or negedge i_rst_n ) begin : proc_tx_done
    if(~i_rst_n) begin
        w_tx_done <= 1'b0;
    end else begin
        case(state)
            STOP_I: begin
                w_tx_done <= ((state==STOP_I) && (n_state==IDLE)) ? 1'b1 : 1'b0; // stop bit I
            end
            default: begin
                w_tx_done <= 1'b0;
            end
        endcase
    end
end
assign o_tx_done = w_tx_done;

endmodule 
