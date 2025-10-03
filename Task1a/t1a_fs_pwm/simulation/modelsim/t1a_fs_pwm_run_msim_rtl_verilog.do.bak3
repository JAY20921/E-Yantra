transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/acer/Desktop/EYantra/t1a_fs_pwm/code {C:/Users/acer/Desktop/EYantra/t1a_fs_pwm/code/t1a_fs_pwm_bdf.v}
vlog -vlog01compat -work work +incdir+C:/Users/acer/Desktop/EYantra/t1a_fs_pwm/code {C:/Users/acer/Desktop/EYantra/t1a_fs_pwm/code/pwm_generator.v}
vlog -vlog01compat -work work +incdir+C:/Users/acer/Desktop/EYantra/t1a_fs_pwm/code {C:/Users/acer/Desktop/EYantra/t1a_fs_pwm/code/frequency_scaling.v}

vlog -vlog01compat -work work +incdir+C:/Users/acer/Desktop/EYantra/t1a_fs_pwm/.test {C:/Users/acer/Desktop/EYantra/t1a_fs_pwm/.test/tb.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  tb

add wave *
view structure
view signals
run 100 us
