default: help

help:
	@echo Various targets which can be of use:
	@echo
	@echo "help -- this message"
	@echo "runvm -- Build the 'test' VM system and run it fresh (uses result link)"
	@echo "         Set BOOT=1 to use the vmWithBootLoader target instead of the vm target"
	@ehco "installer -- Create an installation ISO image"

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
	nix build .\#nixosConfigurations.test.config.system.build.$(VM)
	$(RM) test.qcow2
	result/bin/run-test-vm

installer:
	nix build .\#nixosConfigurations.installer.config.system.build.isoImage
