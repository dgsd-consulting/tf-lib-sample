ifndef WORKDIR
  override WORKDIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
endif

ifndef ENVIRONMENT
  override ENVIRONMENT=dev
endif

.PHONY: apply destroy init outputs plan taint

taint:
	@start="`date`"; \
	terraform taint $(EXTRA_ARGS); \
	echo ; \
	echo "Started taint at  : $$start"; \
	echo "Finished taint at : `date`"; \
	echo

init:
	@rm -rf .terraform/modules;
	@start="`date`"; \
	terraform init -backend-config=beconf.tfvars ; \
	echo ; \
	echo "Started init at  : $$start"; \
	echo "Finished init at : `date`"; \
	echo

plan:
	@if [ "$(ENVIRONMENT)" != "$$(terraform workspace show)" ]; then echo "\nError: Workspace ($$(terraform workspace show)) and Environment ($(ENVIRONMENT)) do not match.\n"; exit 1; fi
	@start="`date`"; \
	terraform plan \
		-input=false \
		-out=$(ENVIRONMENT)-run \
		-var-file=$(ENVIRONMENT).tfvars \
		-var-file=credentials.secret\
		${EXTRA_ARGS}; \
	echo ; \
	echo "Started plan at  : $$start"; \
	echo "Finished plan at : `date`"; \
	echo

apply:
	@if [ "$(ENVIRONMENT)" != "$$(terraform workspace show)" ]; then echo "\nError: Workspace ($$(terraform workspace show)) and Environment ($(ENVIRONMENT)) do not match.\n"; exit 1; fi
	@start="`date`"; \
	terraform apply \
		-input=false \
		$(ENVIRONMENT)-run; \
	echo ; \
	echo "Started apply at  : $$start"; \
	echo "Finished apply at : `date`"; \
	echo

outputs:
	@start="`date`"; \
	echo ; \
	terraform output; \
	echo ; \
	echo "Started output at  : $$start"; \
	echo "Finished output at : `date`"; \
	echo

destroy:
	@if [ "$(ENVIRONMENT)" != "$$(terraform workspace show)" ]; then echo "\nError: Workspace ($$(terraform workspace show)) and Environment ($(ENVIRONMENT)) do not match.\n"; exit 1; fi
	@start="`date`"; \
	terraform destroy \
	    $(EXTRA_ARGS) \
		-var-file=$(ENVIRONMENT).tfvars \
		-var-file=credentials.secret; \
	echo ; \
	echo "Started destroy at  : $$start"; \
	echo "Finished destroy at : `date`"; \
	echo
