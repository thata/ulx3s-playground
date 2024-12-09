all: ulx3s.bit

clean:
	rm -rf top.json ulx3s_out.config ulx3s.bit

ulx3s.bit: ulx3s_out.config
	ecppack ulx3s_out.config ulx3s.bit

ulx3s_out.config: top.json
	nextpnr-ecp5 --85k --json top.json --lpf ulx3s_v20.lpf --textcfg ulx3s_out.config

top.json: top.sv bram_controller.sv
	yosys -p "hierarchy -top top" -p "proc; opt" -p "synth_ecp5 -json top.json" top.sv bram_controller.sv

prog: ulx3s.bit
	fujprog ulx3s.bit
