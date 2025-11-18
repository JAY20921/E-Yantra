transcript on
if {[file exists gate_work]} {
	vdel -lib gate_work -all
}
vlib gate_work
vmap work gate_work

vlog -vlog01compat -work work +incdir+. {t2c_maze_explorer.vo}

vlog -vlog01compat -work work +incdir+D:/E-Yantra/mb_4683_task2c/t2c_maze_explorer/.test {D:/E-Yantra/mb_4683_task2c/t2c_maze_explorer/.test/tb.v}

vsim -t 1ps -L altera_ver -L cycloneive_ver -L gate_work -L work -voptargs="+acc"  tb

add wave *
view structure
view signals
run -all
