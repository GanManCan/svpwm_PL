onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {System Signals}
add wave -noupdate /firing_time_generator_vunit_tb/clk
add wave -noupdate /firing_time_generator_vunit_tb/reset_n
add wave -noupdate -divider {Voltage Input}
add wave -noupdate -radix sfixed /firing_time_generator_vunit_tb/fp_v_alpha
add wave -noupdate -radix sfixed /firing_time_generator_vunit_tb/fp_v_beta
add wave -noupdate -divider Fire_signals
add wave -noupdate -radix sfixed /firing_time_generator_vunit_tb/fire_u
add wave -noupdate -radix sfixed /firing_time_generator_vunit_tb/fire_v
add wave -noupdate -radix sfixed /firing_time_generator_vunit_tb/fire_w
add wave -noupdate -divider Debug
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {103104 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 263
configure wave -valuecolwidth 62
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
configure wave -timelineunits us
update
WaveRestoreZoom {0 ps} {614400 ps}
