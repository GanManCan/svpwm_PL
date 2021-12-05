onerror {resume}
quietly virtual signal -install /svpwm_top_level_tb { (context /svpwm_top_level_tb )(gate_u & gate_v & gate_w )} gate_up
quietly virtual signal -install /svpwm_top_level_tb { (context /svpwm_top_level_tb )(gate_u_n & gate_v_n & gate_w_n )} gate_low
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Analog-Step -height 74 -max 8333.0 /svpwm_top_level_tb/uut/svpwm_1/counter
add wave -noupdate /svpwm_top_level_tb/clk
add wave -noupdate /svpwm_top_level_tb/reset_n
add wave -noupdate -radix sfixed /svpwm_top_level_tb/v_alpha
add wave -noupdate -radix sfixed /svpwm_top_level_tb/v_beta
add wave -noupdate -radix sfixed /svpwm_top_level_tb/uut/firing_time_generator_1/fp_v_alpha
add wave -noupdate -radix sfixed /svpwm_top_level_tb/uut/firing_time_generator_1/fp_v_beta
add wave -noupdate /svpwm_top_level_tb/gate_up
add wave -noupdate /svpwm_top_level_tb/gate_low
add wave -noupdate /svpwm_top_level_tb/clock_period
add wave -noupdate -radix decimal /svpwm_top_level_tb/uut/svpwm_1/fire_u
add wave -noupdate -radix decimal /svpwm_top_level_tb/uut/svpwm_1/fire_v
add wave -noupdate -radix decimal /svpwm_top_level_tb/uut/svpwm_1/fire_w
add wave -noupdate -radix decimal /svpwm_top_level_tb/uut/firing_time_generator_1/fp_t0
add wave -noupdate -radix sfixed /svpwm_top_level_tb/uut/fp_v_alpha
add wave -noupdate -radix sfixed /svpwm_top_level_tb/uut/fp_v_beta
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {43426581 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 237
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
WaveRestoreZoom {0 ps} {110990206 ps}
