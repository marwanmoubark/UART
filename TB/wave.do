onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /sys_top_tb/RST
add wave -noupdate -group CLOCKS /sys_top_tb/REF_CLK
add wave -noupdate -group CLOCKS /sys_top_tb/DUT/RX_CLK
add wave -noupdate -group CLOCKS /sys_top_tb/DUT/TX_CLK
add wave -noupdate -expand -group SYS_CTRL -color Cyan /sys_top_tb/DUT/Sync_RX_P_Data
add wave -noupdate -expand -group SYS_CTRL -color Cyan /sys_top_tb/DUT/Sync_RX_D_VLD
add wave -noupdate -expand -group SYS_CTRL -color Pink /sys_top_tb/DUT/SYS_TX_P_Data
add wave -noupdate -expand -group SYS_CTRL -color Pink /sys_top_tb/DUT/SYS_TX_D_VLD
add wave -noupdate -expand -group SYS_CTRL /sys_top_tb/DUT/u_Clock_Gating/CLK_EN
add wave -noupdate -expand -group SYS_CTRL /sys_top_tb/DUT/u_SYS_CTRL/CS
add wave -noupdate -expand -group SYS_CTRL /sys_top_tb/DUT/u_SYS_CTRL/NS
add wave -noupdate -expand -group UART -color {Light Steel Blue} /sys_top_tb/RX_IN
add wave -noupdate -expand -group UART -color Gold /sys_top_tb/TX_OUT
add wave -noupdate -expand -group UART -color Gold /sys_top_tb/DUT/uart_inst/busy
add wave -noupdate -expand -group UART -color {Indian Red} /sys_top_tb/PAR_ERR
add wave -noupdate -expand -group UART -color {Indian Red} /sys_top_tb/STP_ERR
add wave -noupdate -expand -group REG_FILE /sys_top_tb/DUT/u_RegFile/Address
add wave -noupdate -expand -group REG_FILE -color {Blue Violet} /sys_top_tb/DUT/RdData
add wave -noupdate -expand -group REG_FILE /sys_top_tb/DUT/u_RegFile/WrData
add wave -noupdate -expand -group REG_FILE -color {Blue Violet} /sys_top_tb/DUT/RdData_Valid
add wave -noupdate -expand -group REG_FILE /sys_top_tb/DUT/u_RegFile/REG0
add wave -noupdate -expand -group REG_FILE /sys_top_tb/DUT/u_RegFile/REG1
add wave -noupdate -expand -group REG_FILE /sys_top_tb/DUT/u_RegFile/REG2
add wave -noupdate -expand -group REG_FILE /sys_top_tb/DUT/u_RegFile/REG3
add wave -noupdate -expand -group REG_FILE /sys_top_tb/DUT/u_RegFile/reg_mem
add wave -noupdate -group ALU -color Turquoise /sys_top_tb/DUT/u_ALU/A
add wave -noupdate -group ALU -color Turquoise /sys_top_tb/DUT/u_ALU/B
add wave -noupdate -group ALU -color {Dark Orchid} /sys_top_tb/DUT/ALU_FUN
add wave -noupdate -group ALU -color {Dark Orchid} /sys_top_tb/DUT/ALU_OUT
add wave -noupdate -group ALU -color {Dark Orchid} /sys_top_tb/DUT/OUT_Valid
add wave -noupdate -group FIFO /sys_top_tb/DUT/u_ASYNC_FIFO/i_data
add wave -noupdate -group FIFO -color Violet /sys_top_tb/DUT/FIFO_FULL
add wave -noupdate -group FIFO -color Violet /sys_top_tb/DUT/FIFO_EMPTY
add wave -noupdate -group FIFO /sys_top_tb/DUT/u_ASYNC_FIFO/o_data
add wave -noupdate -group FIFO /sys_top_tb/DUT/u_ASYNC_FIFO/u_fifo_mem/fifo
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2687076233 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 139
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {2055972475 ps}
