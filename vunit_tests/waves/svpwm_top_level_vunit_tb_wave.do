onerror {resume}
quietly virtual signal -install /svpwm_top_level_vunit_tb { (context /svpwm_top_level_vunit_tb )(gate_u & gate_u_l )} gate_u_comb
quietly virtual signal -install /svpwm_top_level_vunit_tb { (context /svpwm_top_level_vunit_tb )(gate_v & gate_v_l )} gate_v_comb
quietly virtual signal -install /svpwm_top_level_vunit_tb { (context /svpwm_top_level_vunit_tb )(gate_w & gate_w_l )} gate_w_comb
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {System Signals}
add wave -noupdate /svpwm_top_level_vunit_tb/clk
add wave -noupdate -format Literal /svpwm_top_level_vunit_tb/reset_n
add wave -noupdate -label {state (top_level)} /svpwm_top_level_vunit_tb/svpwm_top_level_inst/state
add wave -noupdate -label {counter (top level)} -radix decimal /svpwm_top_level_vunit_tb/svpwm_top_level_inst/counter
add wave -noupdate -label fire_time_start /svpwm_top_level_vunit_tb/svpwm_top_level_inst/fire_time_start
add wave -noupdate -divider {Gate Signals}
add wave -noupdate -format Literal /svpwm_top_level_vunit_tb/gate_u
add wave -noupdate -format Literal /svpwm_top_level_vunit_tb/gate_v
add wave -noupdate -format Literal /svpwm_top_level_vunit_tb/gate_w
add wave -noupdate -divider {Combined Gate Signals}
add wave -noupdate -radix binary /svpwm_top_level_vunit_tb/gate_u_comb
add wave -noupdate -radix binary /svpwm_top_level_vunit_tb/gate_v_comb
add wave -noupdate -radix binary /svpwm_top_level_vunit_tb/gate_w_comb
add wave -noupdate -divider {Spy Signals}
add wave -noupdate -radix sfixed /svpwm_top_level_vunit_tb/spy_fp_v_alpha
add wave -noupdate -radix sfixed /svpwm_top_level_vunit_tb/spy_fp_v_beta
add wave -noupdate -divider Debug
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {12069372 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 248
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
WaveRestoreZoom {6587289 ps} {15067340 ps}
