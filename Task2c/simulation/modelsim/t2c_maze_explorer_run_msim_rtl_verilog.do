transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+D:/E-Yantra/mb_4683_task2c/t2c_maze_explorer/code {D:/E-Yantra/mb_4683_task2c/t2c_maze_explorer/code/t2c_maze_explorer.v}

vlog -vlog01compat -work work +incdir+D:/E-Yantra/mb_4683_task2c/t2c_maze_explorer/.test {D:/E-Yantra/mb_4683_task2c/t2c_maze_explorer/.test/tb.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  tb

add wave *
view structure
view signals
run -all
