include ../../make.rules

all: cpu mmx

cpu:
	$(FPC) $(FPCOPT) -Fu../units/i386-fpos -FU../units/i386-fpos cpu.pp

mmx:
	$(FPC) $(FPCOPT) -Fu../units/i386-fpos -FU../units/i386-fpos mmx.pp
