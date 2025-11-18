transcript on
if {[file exists gate_work]} {
	vdel -lib gate_work -all
}
vlib gate_work
vmap work gate_work

vlog -vlog01compat -work work +incdir+. {uart_rx.vo}

vlog -vlog01compat -work work +incdir+D:/t2b_uart/uart_rx/.test {D:/t2b_uart/uart_rx/.test/tb.v}

vsim -t 1ps -L altera_ver -L cycloneive_ver -L gate_work -L work -voptargs="+acc"  tb

add wave *
view structure
view signals
run 1000 us
