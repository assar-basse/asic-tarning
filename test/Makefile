# Makefile
# See https://docs.cocotb.org/en/stable/quickstart.html for more info

# Check if were are on a Muxen PC or not
ifeq ($(shell test -e /usr/bin/iverilog && echo -n yes),yes)
LIU_PC ?= no
else
LIU_PC ?= yes
endif

# defaults
SRC_DIR = $(PWD)/../src

ifeq ($(LIU_PC),yes)
SIM ?= modelsim
TOPLEVEL_LANG ?= vhdl
PROJECT_SOURCES = project.vhdl
else
SIM ?= icarus
TOPLEVEL_LANG ?= verilog
PROJECT_SOURCES = generated/project.v
endif

ifneq ($(GATES),yes)

# RTL simulation:
SIM_BUILD				= sim_build/rtl

ifeq ($(LIU_PC),yes)
VHDL_SOURCES += $(addprefix $(SRC_DIR)/,$(PROJECT_SOURCES))
else
VERILOG_SOURCES += $(addprefix $(SRC_DIR)/,$(PROJECT_SOURCES))
COMPILE_ARGS 		+= -I$(SRC_DIR)
endif

else

# Gate level simulation:
SIM_BUILD				= sim_build/gl
COMPILE_ARGS    += -DGL_TEST
COMPILE_ARGS    += -DFUNCTIONAL
COMPILE_ARGS    += -DUSE_POWER_PINS
COMPILE_ARGS    += -DSIM
COMPILE_ARGS    += -DUNIT_DELAY=\#1
VERILOG_SOURCES += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/primitives.v
VERILOG_SOURCES += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd.v

# this gets copied in by the GDS action workflow
VERILOG_SOURCES += $(PWD)/gate_level_netlist.v

endif

# MODULE is the basename of the Python test file
MODULE = test

ifeq ($(LIU_PC),yes)
# Name of the top module 
TOPLEVEL = tt_um_example
GUI ?= 0 # Set to 1 to open the Modelsim GUI automatically
else
# Leave these alone
VERILOG_SOURCES += $(PWD)/tb.v
TOPLEVEL = tb
endif

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim
