onerror {resume}
quietly virtual signal -install /svpwm_vunit_tb { (context /svpwm_vunit_tb )(gate_u & gate_u_l )} Gate_U_both
quietly virtual signal -install /svpwm_vunit_tb { (context /svpwm_vunit_tb )(gate_u & gate_u_l )} Gate_U_comb
quietly virtual signal -install /svpwm_vunit_tb { (context /svpwm_vunit_tb )(gate_v & gate_v_l )} Gate_c_comb
quietly virtual signal -install /svpwm_vunit_tb { (context /svpwm_vunit_tb )(gate_v & gate_v_l )} Gate_V_comb
quietly virtual signal -install /svpwm_vunit_tb { (context /svpwm_vunit_tb )(gate_w & gate_w_l )} Gate_W_comb
quietly virtual signal -install /svpwm_vunit_tb { (context /svpwm_vunit_tb )(gate_u & gate_u_l )} Gate_U_temp
quietly virtual signal -install /svpwm_vunit_tb { (context /svpwm_vunit_tb )(gate_u & temp_read_gate_u )} GateU
quietly virtual signal -install /svpwm_vunit_tb { (context /svpwm_vunit_tb )(gate_u_l & temp_read_gate_u_l )} GateUL
quietly WaveActivateNextPane {} 0
add wave -noupdate /svpwm_vunit_tb/clk
add wave -noupdate -format Literal /svpwm_vunit_tb/reset_n
add wave -noupdate -divider {System Signals}
add wave -noupdate -expand -group {Fire Signals} -radix decimal -childformat {{/svpwm_vunit_tb/fire_u(31) -radix decimal} {/svpwm_vunit_tb/fire_u(30) -radix decimal} {/svpwm_vunit_tb/fire_u(29) -radix decimal} {/svpwm_vunit_tb/fire_u(28) -radix decimal} {/svpwm_vunit_tb/fire_u(27) -radix decimal} {/svpwm_vunit_tb/fire_u(26) -radix decimal} {/svpwm_vunit_tb/fire_u(25) -radix decimal} {/svpwm_vunit_tb/fire_u(24) -radix decimal} {/svpwm_vunit_tb/fire_u(23) -radix decimal} {/svpwm_vunit_tb/fire_u(22) -radix decimal} {/svpwm_vunit_tb/fire_u(21) -radix decimal} {/svpwm_vunit_tb/fire_u(20) -radix decimal} {/svpwm_vunit_tb/fire_u(19) -radix decimal} {/svpwm_vunit_tb/fire_u(18) -radix decimal} {/svpwm_vunit_tb/fire_u(17) -radix decimal} {/svpwm_vunit_tb/fire_u(16) -radix decimal} {/svpwm_vunit_tb/fire_u(15) -radix decimal} {/svpwm_vunit_tb/fire_u(14) -radix decimal} {/svpwm_vunit_tb/fire_u(13) -radix decimal} {/svpwm_vunit_tb/fire_u(12) -radix decimal} {/svpwm_vunit_tb/fire_u(11) -radix decimal} {/svpwm_vunit_tb/fire_u(10) -radix decimal} {/svpwm_vunit_tb/fire_u(9) -radix decimal} {/svpwm_vunit_tb/fire_u(8) -radix decimal} {/svpwm_vunit_tb/fire_u(7) -radix decimal} {/svpwm_vunit_tb/fire_u(6) -radix decimal} {/svpwm_vunit_tb/fire_u(5) -radix decimal} {/svpwm_vunit_tb/fire_u(4) -radix decimal} {/svpwm_vunit_tb/fire_u(3) -radix decimal} {/svpwm_vunit_tb/fire_u(2) -radix decimal} {/svpwm_vunit_tb/fire_u(1) -radix decimal} {/svpwm_vunit_tb/fire_u(0) -radix decimal}} -subitemconfig {/svpwm_vunit_tb/fire_u(31) {-height 15 -radix decimal} /svpwm_vunit_tb/fire_u(30) {-height 15 -radix decimal} /svpwm_vunit_tb/fire_u(29) {-height 15 -radix decimal} /svpwm_vunit_tb/fire_u(28) {-height 15 -radix decimal} /svpwm_vunit_tb/fire_u(27) {-height 15 -radix decimal} /svpwm_vunit_tb/fire_u(26) {-height 15 -radix decimal} /svpwm_vunit_tb/fire_u(25) {-height 15 -radix decimal} /svpwm_vunit_tb/fire_u(24) {-height 15 -radix decimal} /svpwm_vunit_tb/fire_u(23) {-height 15 -radix decimal} /svpwm_vunit_tb/fire_u(22) {-height 15 -radix decimal} /svpwm_vunit_tb/fire_u(21) {-height 15 -radix decimal} /svpwm_vunit_tb/fire_u(20) {-height 15 -radix decimal} /svpwm_vunit_tb/fire_u(19) {-height 15 -radix decimal} /svpwm_vunit_tb/fire_u(18) {-height 15 -radix decimal} /svpwm_vunit_tb/fire_u(17) {-height 15 -radix decimal} /svpwm_vunit_tb/fire_u(16) {-height 15 -radix decimal} /svpwm_vunit_tb/fire_u(15) {-height 15 -radix decimal} /svpwm_vunit_tb/fire_u(14) {-height 15 -radix decimal} /svpwm_vunit_tb/fire_u(13) {-height 15 -radix decimal} /svpwm_vunit_tb/fire_u(12) {-height 15 -radix decimal} /svpwm_vunit_tb/fire_u(11) {-height 15 -radix decimal} /svpwm_vunit_tb/fire_u(10) {-height 15 -radix decimal} /svpwm_vunit_tb/fire_u(9) {-height 15 -radix decimal} /svpwm_vunit_tb/fire_u(8) {-height 15 -radix decimal} /svpwm_vunit_tb/fire_u(7) {-height 15 -radix decimal} /svpwm_vunit_tb/fire_u(6) {-height 15 -radix decimal} /svpwm_vunit_tb/fire_u(5) {-height 15 -radix decimal} /svpwm_vunit_tb/fire_u(4) {-height 15 -radix decimal} /svpwm_vunit_tb/fire_u(3) {-height 15 -radix decimal} /svpwm_vunit_tb/fire_u(2) {-height 15 -radix decimal} /svpwm_vunit_tb/fire_u(1) {-height 15 -radix decimal} /svpwm_vunit_tb/fire_u(0) {-height 15 -radix decimal}} /svpwm_vunit_tb/fire_u
add wave -noupdate -expand -group {Fire Signals} -radix decimal /svpwm_vunit_tb/fire_v
add wave -noupdate -expand -group {Fire Signals} -radix decimal -childformat {{/svpwm_vunit_tb/fire_w(31) -radix decimal} {/svpwm_vunit_tb/fire_w(30) -radix decimal} {/svpwm_vunit_tb/fire_w(29) -radix decimal} {/svpwm_vunit_tb/fire_w(28) -radix decimal} {/svpwm_vunit_tb/fire_w(27) -radix decimal} {/svpwm_vunit_tb/fire_w(26) -radix decimal} {/svpwm_vunit_tb/fire_w(25) -radix decimal} {/svpwm_vunit_tb/fire_w(24) -radix decimal} {/svpwm_vunit_tb/fire_w(23) -radix decimal} {/svpwm_vunit_tb/fire_w(22) -radix decimal} {/svpwm_vunit_tb/fire_w(21) -radix decimal} {/svpwm_vunit_tb/fire_w(20) -radix decimal} {/svpwm_vunit_tb/fire_w(19) -radix decimal} {/svpwm_vunit_tb/fire_w(18) -radix decimal} {/svpwm_vunit_tb/fire_w(17) -radix decimal} {/svpwm_vunit_tb/fire_w(16) -radix decimal} {/svpwm_vunit_tb/fire_w(15) -radix decimal} {/svpwm_vunit_tb/fire_w(14) -radix decimal} {/svpwm_vunit_tb/fire_w(13) -radix decimal} {/svpwm_vunit_tb/fire_w(12) -radix decimal} {/svpwm_vunit_tb/fire_w(11) -radix decimal} {/svpwm_vunit_tb/fire_w(10) -radix decimal} {/svpwm_vunit_tb/fire_w(9) -radix decimal} {/svpwm_vunit_tb/fire_w(8) -radix decimal} {/svpwm_vunit_tb/fire_w(7) -radix decimal} {/svpwm_vunit_tb/fire_w(6) -radix decimal} {/svpwm_vunit_tb/fire_w(5) -radix decimal} {/svpwm_vunit_tb/fire_w(4) -radix decimal} {/svpwm_vunit_tb/fire_w(3) -radix decimal} {/svpwm_vunit_tb/fire_w(2) -radix decimal} {/svpwm_vunit_tb/fire_w(1) -radix decimal} {/svpwm_vunit_tb/fire_w(0) -radix decimal}} -subitemconfig {/svpwm_vunit_tb/fire_w(31) {-height 15 -radix decimal} /svpwm_vunit_tb/fire_w(30) {-height 15 -radix decimal} /svpwm_vunit_tb/fire_w(29) {-height 15 -radix decimal} /svpwm_vunit_tb/fire_w(28) {-height 15 -radix decimal} /svpwm_vunit_tb/fire_w(27) {-height 15 -radix decimal} /svpwm_vunit_tb/fire_w(26) {-height 15 -radix decimal} /svpwm_vunit_tb/fire_w(25) {-height 15 -radix decimal} /svpwm_vunit_tb/fire_w(24) {-height 15 -radix decimal} /svpwm_vunit_tb/fire_w(23) {-height 15 -radix decimal} /svpwm_vunit_tb/fire_w(22) {-height 15 -radix decimal} /svpwm_vunit_tb/fire_w(21) {-height 15 -radix decimal} /svpwm_vunit_tb/fire_w(20) {-height 15 -radix decimal} /svpwm_vunit_tb/fire_w(19) {-height 15 -radix decimal} /svpwm_vunit_tb/fire_w(18) {-height 15 -radix decimal} /svpwm_vunit_tb/fire_w(17) {-height 15 -radix decimal} /svpwm_vunit_tb/fire_w(16) {-height 15 -radix decimal} /svpwm_vunit_tb/fire_w(15) {-height 15 -radix decimal} /svpwm_vunit_tb/fire_w(14) {-height 15 -radix decimal} /svpwm_vunit_tb/fire_w(13) {-height 15 -radix decimal} /svpwm_vunit_tb/fire_w(12) {-height 15 -radix decimal} /svpwm_vunit_tb/fire_w(11) {-height 15 -radix decimal} /svpwm_vunit_tb/fire_w(10) {-height 15 -radix decimal} /svpwm_vunit_tb/fire_w(9) {-height 15 -radix decimal} /svpwm_vunit_tb/fire_w(8) {-height 15 -radix decimal} /svpwm_vunit_tb/fire_w(7) {-height 15 -radix decimal} /svpwm_vunit_tb/fire_w(6) {-height 15 -radix decimal} /svpwm_vunit_tb/fire_w(5) {-height 15 -radix decimal} /svpwm_vunit_tb/fire_w(4) {-height 15 -radix decimal} /svpwm_vunit_tb/fire_w(3) {-height 15 -radix decimal} /svpwm_vunit_tb/fire_w(2) {-height 15 -radix decimal} /svpwm_vunit_tb/fire_w(1) {-height 15 -radix decimal} /svpwm_vunit_tb/fire_w(0) {-height 15 -radix decimal}} /svpwm_vunit_tb/fire_w
add wave -noupdate -expand -group {Locked Fire Signals} -radix decimal /svpwm_vunit_tb/svpwm_tb_inst/lock_fire_u
add wave -noupdate -expand -group {Locked Fire Signals} -radix decimal /svpwm_vunit_tb/svpwm_tb_inst/lock_fire_v
add wave -noupdate -expand -group {Locked Fire Signals} -radix decimal /svpwm_vunit_tb/svpwm_tb_inst/lock_fire_w
add wave -noupdate -expand -group {Gate Signals} /svpwm_vunit_tb/Gate_U_comb
add wave -noupdate -expand -group {Gate Signals} /svpwm_vunit_tb/Gate_V_comb
add wave -noupdate -expand -group {Gate Signals} /svpwm_vunit_tb/Gate_W_comb
add wave -noupdate -expand -group {Gate Signals High} /svpwm_vunit_tb/gate_u
add wave -noupdate -expand -group {Gate Signals High} /svpwm_vunit_tb/gate_v
add wave -noupdate -expand -group {Gate Signals High} /svpwm_vunit_tb/gate_w
add wave -noupdate -expand -group {Counter Signals} /svpwm_vunit_tb/spy_counter
add wave -noupdate -expand -group {Counter Signals} /svpwm_vunit_tb/sim_counter
add wave -noupdate /svpwm_vunit_tb/GateU
add wave -noupdate /svpwm_vunit_tb/GateUL
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {82705 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 244
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
WaveRestoreZoom {2482877 ps} {2890378 ps}
