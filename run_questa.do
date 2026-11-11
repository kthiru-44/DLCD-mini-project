# QuestaSim/ModelSim run script:  vsim -do run_questa.do
quit -sim
if {[file exists work]} {vdel -lib work -all}
vlib work
vmap work work
vlog -work work pe.v systolic_array_2x2.v tb_systolic_array_2x2.v
# +acc keeps all signals visible; -onfinish stop keeps the GUI open after $finish
vsim -voptargs=+acc -onfinish stop work.tb_systolic_array_2x2

add wave -divider {Clock / Reset}
add wave -radix binary   /tb_systolic_array_2x2/clk
add wave -radix binary   /tb_systolic_array_2x2/rst
add wave -divider {Inputs}
add wave -radix unsigned /tb_systolic_array_2x2/a0_in /tb_systolic_array_2x2/a1_in
add wave -radix unsigned /tb_systolic_array_2x2/b0_in /tb_systolic_array_2x2/b1_in
add wave -divider {Outputs C}
add wave -radix unsigned /tb_systolic_array_2x2/c00 /tb_systolic_array_2x2/c01
add wave -radix unsigned /tb_systolic_array_2x2/c10 /tb_systolic_array_2x2/c11
add wave -divider {PE internals}
add wave -radix unsigned /tb_systolic_array_2x2/uut/PE00/*
add wave -radix unsigned /tb_systolic_array_2x2/uut/PE11/*

run -all
wave zoom full
