###################################################################
# Project Configuration: 
# 
# Specify the name of the design (project), the Quartus II Settings
# File (.qsf), and the list of source files used.
###################################################################

PROJECT = top
SOURCE_FILES = ../hdl/defines.v ../hdl/cpu6_core.v \
		../hdl/cpu6_controller.v \
		../hdl/cpu6_maindec.v \
		../hdl/cpu6_aludec.v \
		../hdl/cpu6_datapath.v \
		../hdl/cpu6_dffs.v \
		../hdl/cpu6_adder.v \
		../hdl/cpu6_sl1.v \
		../hdl/cpu6_mux2.v \
		../hdl/cpu6_regfile.v \
		../hdl/cpu6_signext.v \
		../hdl/cpu6_alu.v \
		../hdl/cpu6_immdec.v \
		../hdl/cpu6_branchdec.v \
		../hdl/cpu6_pipelinereg_ifid.v \
		../hdl/cpu6_pipelinereg_idex.v \
		../hdl/cpu6_pipelinereg_exmem.v \
		../hdl/cpu6_pipelinereg_memwb.v \
		../hdl/cpu6_hazardcontrol.v \
		../hdl/cpu6_hazardunit.v \
		../hdl/top.v \
		../hdl/ram.v \
		../hdl/vga640x480.v \
		../hdl/vgaram.v \
		../testbenches/pseudo_icache.v

SOURCE_FILES_PARAMETER = $(addprefix --source=, $(SOURCE_FILES))
ASSIGNMENT_FILES = top.qpf top.qsf 

###################################################################
# Main Targets
#
# all: build everything
# clean: remove output files and database
###################################################################

all: smart.log $(PROJECT).asm.rpt $(PROJECT).sta.rpt 

clean:
	rm -rf *.rpt *.chg smart.log *.htm *.eqn *.pin *.sof *.pof db

map: smart.log $(PROJECT).map.rpt
fit: smart.log $(PROJECT).fit.rpt
asm: smart.log $(PROJECT).asm.rpt
sta: smart.log $(PROJECT).sta.rpt
smart: smart.log

###################################################################
# Executable Configuration
###################################################################

# Quartus 19.1 Prime lite doesn't support CycloneII
# To compile, put CycloneIV here
#MAP_ARGS = --family=CycloneII $(SOURCE_FILES_PARAMETER)
#FIT_ARGS = --part=EP2C5T144C8i
MAP_ARGS = --family=CycloneIV $(SOURCE_FILES_PARAMETER)
#FIT_ARGS = --part=EP4CE6E22C8
ASM_ARGS =
STA_ARGS =

###################################################################
# Target implementations
###################################################################

STAMP = echo done >

$(PROJECT).map.rpt: map.chg $(SOURCE_FILES) 
	quartus_map $(MAP_ARGS) $(PROJECT)
	$(STAMP) fit.chg

$(PROJECT).fit.rpt: fit.chg $(PROJECT).map.rpt
	quartus_fit $(FIT_ARGS) $(PROJECT)
	$(STAMP) asm.chg
	$(STAMP) sta.chg

$(PROJECT).asm.rpt: asm.chg $(PROJECT).fit.rpt
	quartus_asm $(ASM_ARGS) $(PROJECT)

$(PROJECT).sta.rpt: sta.chg $(PROJECT).fit.rpt
	quartus_sta $(STA_ARGS) $(PROJECT) 

smart.log: $(ASSIGNMENT_FILES)
	quartus_sh --determine_smart_action $(PROJECT) > smart.log

###################################################################
# Project initialization
###################################################################

$(ASSIGNMENT_FILES):
	quartus_sh --prepare $(PROJECT)

map.chg:
	$(STAMP) map.chg
fit.chg:
	$(STAMP) fit.chg
sta.chg:
	$(STAMP) sta.chg
asm.chg:
	$(STAMP) asm.chg
