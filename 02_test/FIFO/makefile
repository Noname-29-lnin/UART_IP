# Configuration
TOPMODULE := fifo
RTL_DIR := ../../01_rtl
RTL_FILES := $(wildcard $(RTL_DIR)/*.v)  # Sử dụng wildcard của Make
VERILATOR_FLAGS := --binary --timing --trace --build -f flist.f
WARNING_IGNORE := -Wno-fatal -Wno-lint -Wno-style -Wno-width

# Targets
all: clean compile run

compile:
	@echo "-> Compiling design with Verilator (ignoring warnings)..."
	@verilator $(VERILATOR_FLAGS) $(WARNING_IGNORE)

run:
	@echo "-> Running simulation..."
	@./obj_dir/Vtb_$(TOPMODULE) | tee simulation.log
	@echo "Simulation completed. Log saved to simulation.log"

sim:
	@echo "-> Opening waveform viewer..."
	@gtkwave tb_$(TOPMODULE).vcd

check:
	@echo "-> Check syntax..."
	@verilator $(WARNING_IGNORE) --lint-only $(RTL_FILES) \
		--top-module $(TOPMODULE)
	@echo "-> Check completed."

clean:
	@echo "-> Cleaning project..."
	# @rm -rf *.vcd obj_dir *.log *.dmp
	@rm -rf obj_dir *.dmp

help:
	@echo "Makefile targets:"
	@echo "  all      : Clean, compile and run (default)"
	@echo "  compile  : Compile the design with Verilator"
	@echo "  run      : Run the simulation"
	@echo "  sim      : Open waveform viewer"
	@echo "  check    : Check syntax with Verilator"
	@echo "  clean    : Remove generated files"
	@echo "  help     : Show this help message"

.PHONY: all compile run sim clean help
