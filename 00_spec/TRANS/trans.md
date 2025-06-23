# Module Transmitter

| Port | Size | Type | Function |
|------|------|------|----------|
| i_clk | 1 | input | Clock of system | 
| i_rst_n | 1 | input | Reset negedege |
| i_stick | 1 | input | Clock synchronize using module baud generator |
| i_tx_en | 1 | input | Enable module transmitter start |
| i_data | 9 | input | Max size bit module can send |
| i_parity_check | 2 | input | Choose mode add parity mode |
| i_frame_size | 3 | input | Choose mode size data send data in 1 frame |
| i_stop_bit | 1 | input | Select number of bit stop salary in the transmission frame |
| o_data_tx | 1 | output | Serial output bit |
| o_done_tx | 1 | output | Signal done when transmisstion input data |

# Module Receiver

| Port | Size | Type | Function |
|------|------|------|----------|
| i_clk | 1 | input | Clock of system | 
| i_rst_n | 1 | input | Reset negedege |
| i_stick | 1 | input | Clock synchronize using module baud generator |
| i_rx_en | 1 | input | Enable module receiver start |
| i_data | 1 | input | Serial input data |
| i_parity_check | 2 | input | Choose mode add parity mode |
| i_frame_size | 3 | input | Choose mode size data send data in 1 frame |
| i_stop_bit | 1 | input | Select number of bit stop salary in the transmission frame |
| o_data_rx | 9 | output | Max size data output bit receiver |
| o_done_rx | 1 | output | Signal done |
| o_error_overun | 1 | output | New data arrives before previous data is read from receive buffer |
| o_error_frame | 1 | output | Stop bit is not detected at expected time |
| o_error_parity | 1 | output | Received parity bit doesn't match calculated parity 



# Module FIFO in Transmitter

| Port | Size | Type | Function |
|------|------|------|----------|
| i_data | 16 | input | 2bit select mode parity + 1bit select number stop bit + 3bit resize data in frame + 9bit data |
| i_rd_en | 1 | input | Enable point reader |
| i_wr_en | 1 | input | Enable point writer | 
| o_data | 16 | output | 2bit select mode parity + 1bit select number stop bit + 3bit resize data in frame + 9bit data | 
| o_fifo_full | 1 | output | FIFO full data |
| o_fifo_empty | 1 | output | FIFO empty data |

# Module Baud Generator

| Port | Size | Type | Function |
|------|------|------|----------|
| i_clk | 1 | input | Clock of system |
| i_rst_n | 1 | input | Reset negedge |
| i_bdr_value | 24 | input | Value i_bdr_value = (FREQ)/(BAUDRATE*16)-1 |
| o_stick | 1 | output | Clock synchronize |

