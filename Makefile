katana:
	katana --disable-fee --allowed-origins "*" --invoke-max-steps 4294967295

setup:
	@./scripts/setup.sh

deploy-slot:
	@./scripts/deploy_slot.sh $(PROFILE) $(ACTION)

deploy-sepolia:
	@./scripts/deploy_sepolia.sh $(ACTION)

generate-event-keys:
	@./scripts/generateEventKeys.sh

enviroment:
	@./scripts/enviroment.sh

# Define tasks that are not real files
.PHONY: deploy-slot deploy-sepolia katana setup torii generate-event-keys enviroment

# Catch-all rule for undefined commands
%:
	@echo "Error: Command '$(MAKECMDGOALS)' is not defined."
	@exit 1
