module rec #(
    parameter SIZE_DATA     = 9 ,
    parameter OVER_SAMPLING = 16
)(
    input logic                     i_clk   ,
    input logic                     i_rst_n ,
    input logic                     i_stick ,
    input logic                     i_rx_en ,
    input logic [2:0]               i_size_frame    ,
    input logic [1:0]               i_parity_bit    ,
    input logic                     i_stop_bit      ,
    input logic                     i_data          ,
    output logic [SIZE_DATA-1:0]    o_data          ,
    output logic                    o_done_rx       ,
    output logic                    o_error_overun  ,
    output logic                    o_error_frame   ,
    output logic                    o_error_parity   
);

parameter int SIZE_STATE = 3;
typedef enum logic [SIZE_STATE-1:0] {
    STATE_IDLE  = 3'h000,
    STATE_START ,
    STATE_REC   ,
    STATE_PARITY ,
    STATE_STOP_1,
    STATE_STOP_2,
    STATE_DONE  
} state_e;
state_e state, nstate;

parameter [1:0] PARITY_NONE     = 2'b00 ,
                PARITY_ODD      = 2'b01 ,
                PARITY_EVEN     = 2'b10 ;
logic w_update_parity;
// assign w_update_parity = (i_parity_bit == PARITY_EVEN || i_parity_bit == PARITY_ODD) ? 1'b1 : 1'b0;
assign w_update_parity = (i_parity_bit == PARITY_NONE) ? 1'b0 : 1'b1;

parameter [2:0] FRAME_5bit      = 3'b000    ,
                FRAME_6bit      = 3'b001    ,
                FRAME_7bit      = 3'b010    ,
                FRAME_8bit      = 3'b011    ,
                FRAME_9bit      = 3'b100    ;

parameter SIZE_INDEX = 5;
logic w_update_index;
logic [SIZE_INDEX-1:0] index, nindex;
logic [SIZE_INDEX-1:0] check_index;
assign w_update_index = (index == (check_index-2)) ? 1'b1 : 1'b0;
always @(*) begin
    case(i_size_frame)
        FRAME_5bit: check_index = 5;
        FRAME_6bit: check_index = 6;
        FRAME_7bit: check_index = 7;
        FRAME_8bit: check_index = 8;
        FRAME_9bit: check_index = 9;
        default:    check_index = 8;
    endcase
end 

parameter SIZE_COUNT = 32;
logic [SIZE_COUNT-1:0] count, ncount;

logic w_update_mid_sampling, w_update_sampling;
assign w_update_sampling = (count == (OVER_SAMPLING-1)) ? 1'b1 : 1'b0;
assign w_update_mid_sampling = (count == ((OVER_SAMPLING/2)-1)) ? 1'b1 : 1'b0;

always @(*) begin : proc_ncount
    case(state)
        STATE_START:
            ncount = (w_update_mid_sampling) ? '0 : (i_stick ? count + 1'b1 : count);
        STATE_REC, STATE_STOP_1, STATE_STOP_2:
            ncount = (w_update_sampling) ? '0 : (i_stick ? count + 1'b1 : count);
        default: // STATE_IDLE, STATE_DONE
            ncount = '0;
    endcase 
end 

always @(*) begin : proc_nindex
    case(state)
       STATE_REC:
            nindex = w_update_index ? index : ((w_update_sampling) ? index + 1'b1 : index);
        STATE_STOP_1, STATE_STOP_2, STATE_DONE:
            nindex = index;
        default:
            nindex = '0;
    endcase
end 

always @(*) begin : proc_nstate
    case(state)
        STATE_IDLE:
            nstate = (~i_data & i_rx_en & i_stick) ? STATE_START : STATE_IDLE;
        STATE_START:
            nstate = (w_update_mid_sampling) ? (i_data ? STATE_IDLE : STATE_REC) : STATE_START;
        STATE_REC:
            nstate = (w_update_sampling & w_update_index) ? (w_update_parity ? STATE_PARITY : STATE_STOP_1) : STATE_REC;
        STATE_PARITY:
            nstate = (w_update_sampling) ? STATE_STOP_1 : STATE_PARITY;
        STATE_STOP_1:
            nstate = (w_update_sampling) ? (i_stop_bit ? STATE_STOP_2 : STATE_DONE) : STATE_STOP_1;
        STATE_STOP_2:
            nstate = (w_update_sampling) ? STATE_DONE : STATE_STOP_2;
        default:
            nstate = STATE_IDLE;
    endcase
end

always_ff @(posedge i_clk or negedge i_rst_n) begin : proc_flip_flop
    if(~i_rst_n) begin
        state   <= STATE_IDLE;
        count   <= '0;
        index   <= '0;
    end else begin
        state   <= nstate;
        count   <= ncount;
        index   <= nindex;
    end
end

logic [SIZE_DATA-1:0] w_data_send;
always_ff @(posedge i_clk or negedge i_rst_n) begin : proc_output_data
    if (~i_rst_n) begin
        w_data_send <= '0;
        o_data <= '0;
    end else begin
        case (state)
            STATE_REC: begin
                w_data_send[index] <= i_data;
            end
            STATE_DONE: begin
                o_data <= w_data_send;
                w_data_send <= '0;
            end
            default: begin
                w_data_send <= w_data_send;
                o_data <= o_data;
            end
        endcase
    end
end

logic w_parity_send;
always_ff @( posedge i_clk or negedge i_rst_n ) begin : proc_check_parity
    if(~i_rst_n) begin
        w_parity_send <= 1'b0;
    end else begin
        case (state)
            STATE_PARITY:
                w_parity_send <= i_data;
            STATE_STOP_1, STATE_STOP_2, STATE_DONE:
                w_parity_send <= w_parity_send; 
            default: 
                w_parity_send <= 1'b0;
        endcase
    end
end
logic w_parity_check;
always @(*) begin : proc_output_error_parity
    case (i_parity_bit)
        PARITY_ODD:
            w_parity_check = ~^w_data_send;
        PARITY_EVEN:
            w_parity_check = ^w_data_send;
        default: 
            w_parity_check = 1'b0; 
    endcase
end

assign o_error_parity = (w_update_parity) ? (~(w_parity_check ^ w_parity_check)) : 1'b0;

logic w_error_overun, w_error_frame;
always_ff @(posedge i_clk or negedge i_rst_n) begin : proc_error_flags
    if (~i_rst_n) begin
        w_error_overun <= 1'b0;
        w_error_frame <= 1'b0;
    end else begin
        // Overrun error: New frame starts while previous data is not read
        if (state == STATE_START && w_update_mid_sampling && o_done_rx) begin
            w_error_overun <= 1'b1;
        end else if (state == STATE_DONE) begin
            w_error_overun <= 1'b0; // Clear on successful reception
        end

        // Frame error: Stop bit(s) not high
        if (state == STATE_STOP_1 && w_update_sampling && ~i_data) begin
            w_error_frame <= 1'b1;
        end else if (state == STATE_STOP_2 && w_update_sampling && ~i_data) begin
            w_error_frame <= 1'b1;
        end else if (state == STATE_DONE) begin
            w_error_frame <= 1'b0; // Clear on successful reception
        end
    end
end
assign o_error_frame = w_error_frame;
assign o_error_overun = w_error_overun;

logic w_done_rx;
assign w_done_rx = (state == STATE_DONE) ? 1'b1 : 1'b0;
assign o_done_rx = w_done_rx;


endmodule

