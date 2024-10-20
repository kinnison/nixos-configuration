default: help

help:
	@echo Various targets which can be of use:
	@echo
	@echo "help -- this message"
	@echo "runvm -- Build the 'test' VM system and run it fresh (uses result link)"
	@echo "         Set BOOT=1 to use the vmWithBootLoader target instead of the vm target"
	@echo "         Set INSTALLER=1 to use the 'installer' system rather than the test system"
	@echo "installer -- Create an installation ISO image"

# Commands
RM?=rm -f

# VM

BOOT?=0
ifeq ($(BOOT),1)
VM=vmWithBootLoader
else
VM=vm
endif

INSTALLER?=0
ifeq ($(INSTALLER),1)
SYSTEM=installer
else
SYSTEM=test
endif

runvm:
	nix build .\#nixosConfigurations.$(SYSTEM).config.system.build.$(VM)
	$(RM) $(SYSTEM).qcow2
	result/bin/*-vm

installer:
	nix build .\#nixosConfigurations.installer.config.system.build.isoImage
