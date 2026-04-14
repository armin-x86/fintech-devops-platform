# Makefile

# Use printf, not echo: POSIX echo does not interpret \e (macOS prints "\e" literally).
BLUE := $(shell printf '\033[1;34m')
DEF  := $(shell printf '\033[0m')
# TARGET =: -target module.my_module

ifndef TF_PLAN_FILE
TF_PLAN_FILE := ./plan.out
endif

plan:
	$(info $(BLUE)# terraform initializing $(DEF))
	@terraform init -input=false
	$(info $(BLUE)# terraform making plan $(DEF))

	@# don't want to print command not to reveal password
	@terraform plan -input=false -out=$(TF_PLAN_FILE) $(TARGET)

apply:
	$(info $(BLUE)# terraform applying changes $(DEF))
	@terraform apply $(TF_PLAN_FILE)

clean:
	@rm -rf .terraform terraform.tfstate $(TF_PLAN_FILE)

.PHONY: clean plan apply
