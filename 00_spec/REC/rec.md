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

