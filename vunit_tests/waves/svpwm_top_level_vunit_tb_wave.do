onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /svpwm_top_level_vunit_tb/clk
add wave -noupdate /svpwm_top_level_vunit_tb/reset_n
add wave -noupdate -divider {Gate Signals}
add wave -noupdate /svpwm_top_level_vunit_tb/gate_u
add wave -noupdate /svpwm_top_level_vunit_tb/gate_u_l
add wave -noupdate /svpwm_top_level_vunit_tb/gate_v
add wave -noupdate /svpwm_top_level_vunit_tb/gate_v_l
add wave -noupdate /svpwm_top_level_vunit_tb/gate_w
add wave -noupdate /svpwm_top_level_vunit_tb/gate_w_l
add wave -noupdate -divider {Spy Signals}
add wave -noupdate -max 4294967283.0 -radix unsigned /svpwm_top_level_vunit_tb/spy_fp_v_alpha
add wave -noupdate -max 4294967283.0 -radix unsigned /svpwm_top_level_vunit_tb/spy_fp_v_beta
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {4195074849 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 278
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
configure wave -timelineunits us
update
WaveRestoreZoom {0 ps} {555376437 ps}
