module trans #(
    parameter SIZE_DATA     = 9     ,
    parameter OVER_SAMPLING = 16
)(
    input logic                     i_clk       ,
    input logic                     i_rst_n     ,
    input logic                     i_stick     ,
    input logic                     i_tx_en     ,
    input logic [2:0]               i_size_frame,
    input logic [1:0]               i_parity_bit,
    input logic                     i_stop_bit  ,
    input logic [SIZE_DATA-1:0]     i_data      ,
    output logic                    o_data_tx   ,
    output logic                    o_done_tx
);

parameter [1:0] PARITY_NONE     = 2'b00 ,
                PARITY_ODD      = 2'b01 ,
                PARITY_EVEN     = 2'b10 ;
logic w_update_parity;
assign w_update_parity = (i_parity_bit == PARITY_NONE) ? 1'b0 : 1'b1;

logic w_parity_data;
always @(*) begin
    case(i_parity_bit)
        PARITY_ODD:
            w_parity_data = ~^i_data;
        PARITY_EVEN:
            w_parity_data = ^i_data;
        default:
            w_parity_data = '0;
    endcase
end 

parameter [2:0] FRAME_5bit      = 3'b000    ,
                FRAME_6bit      = 3'b001    ,
                FRAME_7bit      = 3'b010    ,
                FRAME_8bit      = 3'b011    ,
                FRAME_9bit      = 3'b100    ;

parameter SIZE_INDEX = 5;
logic w_update_index;
logic [SIZE_INDEX-1:0] index, nindex; // using count data in dataframe
assign w_update_index = (index == (check_index-2)) ? 1'b1 : 1'b0;
logic [SIZE_INDEX-1:0] check_index;
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
logic [SIZE_COUNT-1:0] count, ncount; // using count oversampling
logic w_update_sampling;
assign w_update_sampling = (count == (OVER_SAMPLING-1));
// parameter       STOP_1bit       = 1'b0      ,
//                 STOP_2bit       = 1'b1      ;

parameter SIZE_STATE = 3;
parameter [SIZE_STATE-1:0]  STATE_IDLE   = 3'b000    ,
                            STATE_START  = 3'b001    ,
                            STATE_TRANS  = 3'b010    ,
                            STATE_PARITY = 3'b011    ,
                            STATE_STOP_1 = 3'b100    ,
                            STATE_STOP_2 = 3'b101    ,
                            STATE_DONE   = 3'b110    ;
logic [SIZE_STATE-1:0] state, nstate;

logic w_stop_bit;
assign w_stop_bit = i_stop_bit;

always @(*) begin : proc_n_count
    case(state)
        STATE_START, STATE_TRANS, STATE_STOP_1, STATE_STOP_2: 
            ncount = (w_update_sampling) ? '0 : ((i_stick) ? count + 1'b1 : count);
        default: // STATE_IDLE, STATE_DONE 
            ncount = '0;
    endcase 
end 

always @(*) begin : proc_n_index
    case(state)
        STATE_TRANS:
            nindex = (w_update_index) ? index : (w_update_sampling ? index + 1'b1 : index);
        STATE_STOP_1, STATE_STOP_2, STATE_DONE:
            nindex = index;
        default: // STATE_IDLE, STATE_START
            nindex = '0;
    endcase 
end 

always @(*) begin : proc_n_state
    case(state)
        STATE_IDLE:
            nstate = i_tx_en ? STATE_START : STATE_IDLE;
        STATE_START:
            nstate = (w_update_sampling) ? STATE_TRANS : STATE_START;
        STATE_TRANS:
            nstate = (w_update_sampling & w_update_index) ? (w_update_parity ? STATE_PARITY : STATE_STOP_1) : STATE_TRANS;
        STATE_PARITY:
            nstate = (w_update_sampling) ? STATE_STOP_1 : STATE_PARITY;
        STATE_STOP_1:
            nstate = (w_update_sampling) ? (w_stop_bit ? STATE_STOP_2 : STATE_DONE) : (STATE_STOP_1);
        STATE_STOP_2:
            nstate = (w_update_sampling) ? STATE_DONE : STATE_STOP_2;
        STATE_DONE:
            nstate = STATE_IDLE;
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

always_ff @(posedge i_clk or negedge i_rst_n) begin : proc_odate
    if(~i_rst_n)
        o_data_tx <= 1;
    else begin
        case(state)
            STATE_START:
                o_data_tx <= '0;
            STATE_TRANS:
                o_data_tx <= i_data[index[SIZE_INDEX-1:0]];
            STATE_PARITY:
                o_data_tx <= w_parity_data;
            STATE_STOP_1:
                o_data_tx <= 1;
            STATE_STOP_2:
                o_data_tx <= 1;
            default:
                o_data_tx <= 1;
        endcase
    end 
end 

logic w_tx_done;
assign w_tx_done = (state == STATE_DONE) ? 1'b1 : 1'b0;
assign o_done_tx = w_tx_done;

endmodule

