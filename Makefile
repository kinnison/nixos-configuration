default: help

help:
	@echo Various targets which can be of use:
	@echo
	@echo "help -- this message"
	@echo "runvm -- Build the 'testvm' system and run it fresh (uses result link)"
	@echo "         Set BOOT=1 to use the vmWithBootLoader target instead of the vm target"

# Commands
RM?=rm -f

# VM

BOOT?=0
ifeq ($(BOOT),1)
VM=vmWithBootLoader
else
VM=vm
endif

runvm:
	nix build .\#nixosConfigurations.testvm.config.system.build.$(VM)
	$(RM) testvm.qcow2
	result/bin/run-testvm-vm
 