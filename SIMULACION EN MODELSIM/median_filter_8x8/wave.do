onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /tb_top_filter/DUT/clk
add wave -noupdate -radix unsigned /tb_top_filter/DUT/rst
add wave -noupdate -radix unsigned /tb_top_filter/DUT/pixel_in
add wave -noupdate -radix unsigned /tb_top_filter/DUT/valid_in
add wave -noupdate -radix unsigned /tb_top_filter/DUT/pixel_out
add wave -noupdate -radix unsigned /tb_top_filter/DUT/valid_out
add wave -noupdate -radix unsigned /tb_top_filter/DUT/addr_pix
add wave -noupdate -radix unsigned /tb_top_filter/DUT/addr_row
add wave -noupdate -radix unsigned /tb_top_filter/DUT/addr_col
add wave -noupdate -radix unsigned /tb_top_filter/DUT/line0
add wave -noupdate -radix unsigned /tb_top_filter/DUT/line1
add wave -noupdate -radix unsigned /tb_top_filter/DUT/line2
add wave -noupdate -radix unsigned /tb_top_filter/DUT/w00
add wave -noupdate -radix unsigned /tb_top_filter/DUT/w01
add wave -noupdate -radix unsigned /tb_top_filter/DUT/w02
add wave -noupdate -radix unsigned /tb_top_filter/DUT/w10
add wave -noupdate -radix unsigned /tb_top_filter/DUT/w11
add wave -noupdate -radix unsigned /tb_top_filter/DUT/w12
add wave -noupdate -radix unsigned /tb_top_filter/DUT/w20
add wave -noupdate -radix unsigned /tb_top_filter/DUT/w21
add wave -noupdate -radix unsigned /tb_top_filter/DUT/w22
add wave -noupdate -radix unsigned /tb_top_filter/DUT/median_out
add wave -noupdate -radix unsigned /tb_top_filter/DUT/median_valid
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 189
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {1970176 ps}
