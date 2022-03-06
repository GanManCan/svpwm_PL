onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /open_loop_vunit_tb/clk
add wave -noupdate /open_loop_vunit_tb/reset_n
add wave -noupdate /open_loop_vunit_tb/en
add wave -noupdate /open_loop_vunit_tb/freq
add wave -noupdate /open_loop_vunit_tb/spy_state
add wave -noupdate -expand -group Output -label fp_v_alpha_open -radix decimal /open_loop_vunit_tb/fp_v_alpha_open
add wave -noupdate -expand -group Output -label fp_v_beta_open -radix decimal /open_loop_vunit_tb/fp_v_beta_open
add wave -noupdate -expand -group {Freq Counter} -label int_saved_freq /open_loop_vunit_tb/open_loop_ref_inst/int_saved_freq
add wave -noupdate -expand -group {Freq Counter} -label int_rtc_clk_setpoint -radix decimal /open_loop_vunit_tb/open_loop_ref_inst/int_rtc_clk_setpoint
add wave -noupdate -expand -group {Freq Counter} -label int_rtc_clk_counter -radix decimal /open_loop_vunit_tb/open_loop_ref_inst/int_rtc_clk_counter
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1251 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 204
configure wave -valuecolwidth 91
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
WaveRestoreZoom {200187327 ps} {200190124 ps}
