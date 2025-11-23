# Terraform helper Makefile for ArenaVerse infra
#
# NOTE: Destroy targets will delete real GCP resources in the projects.
# - destroy-dev/staging/prod/shared: destroy env + shared infra
# - destroy-org: destroys the GCP projects (arenaverse-*)
# - destroy-all: destroys shared + env stacks ONLY (projects stay)
#
# Only run destroy-org if you're OK deleting the projects themselves.

# Directories with Terraform configs used for validation
TF_DIRS = bootstrap org stacks/dev stacks/staging stacks/prod stacks/shared

.PHONY: fmt validate \
        apply-bootstrap apply-org apply-shared apply-dev apply-staging apply-prod apply-all \
        destroy-dev destroy-staging destroy-prod destroy-shared destroy-org destroy-all

fmt:
	@echo "Running terraform fmt recursively..."
	@terraform fmt -recursive

validate:
	@for d in $(TF_DIRS); do \
	  echo "Validating $$d..."; \
	  cd $$d && terraform init -backend=false -upgrade >/dev/null 2>&1 && terraform validate || exit 1; \
	  cd - >/dev/null 2>&1; \
	done
	@echo "All directories validated successfully."

# -------- Apply targets (create / update infra) --------

apply-bootstrap:
	@echo "=== Applying bootstrap stack (bootstrap) ==="
	@cd bootstrap && terraform init && terraform apply -auto-approve

apply-org:
	@echo "=== Applying org stack (org: projects, SAs, IAM) ==="
	@cd org && terraform init && terraform apply -auto-approve

apply-shared:
	@echo "=== Applying shared stack (stacks/shared: VPC, subnets, NAT, firewall) ==="
	@cd stacks/shared && terraform init && terraform apply -auto-approve

apply-dev:
	@echo "=== Applying dev stack (stacks/dev) ==="
	@cd stacks/dev && terraform init && terraform apply -auto-approve

apply-staging:
	@echo "=== Applying staging stack (stacks/staging) ==="
	@cd stacks/staging && terraform init && terraform apply -auto-approve

apply-prod:
	@echo "=== Applying prod stack (stacks/prod) ==="
	@cd stacks/prod && terraform init && terraform apply -auto-approve

apply-all:
	@echo "=== Applying ALL stacks in order: bootstrap -> org -> shared -> dev -> staging -> prod ==="
	@$(MAKE) apply-bootstrap
	@$(MAKE) apply-org
	@$(MAKE) apply-shared
	@$(MAKE) apply-dev
	@$(MAKE) apply-staging
	@$(MAKE) apply-prod
	@echo "=== apply-all complete ==="

# -------- Destroy targets (tear down infra) --------

destroy-dev:
	@echo "=== Destroying dev stack (stacks/dev) ==="
	@cd stacks/dev && terraform init >/dev/null && terraform destroy -auto-approve || echo "destroy-dev: nothing to destroy or failed."

destroy-staging:
	@echo "=== Destroying staging stack (stacks/staging) ==="
	@cd stacks/staging && terraform init >/dev/null && terraform destroy -auto-approve || echo "destroy-staging: nothing to destroy or failed."

destroy-prod:
	@echo "=== Destroying prod stack (stacks/prod) ==="
	@cd stacks/prod && terraform init >/dev/null && terraform destroy -auto-approve || echo "destroy-prod: nothing to destroy or failed."

destroy-shared:
	@echo "=== Destroying shared stack (stacks/shared) ==="
	@cd stacks/shared && terraform init >/dev/null && terraform destroy -auto-approve || echo "destroy-shared: nothing to destroy or failed."

destroy-org:
	@echo "=== Destroying org stack (org) ==="
	@echo "WARNING: This will attempt to delete the arenaverse-* projects managed by Terraform."
	@cd org && terraform init >/dev/null && terraform destroy -auto-approve || echo "destroy-org: nothing to destroy or failed (projects may be protected by deletion_policy)."

destroy-all:
	@echo "=== Destroying shared + env stacks (dev, staging, prod, shared) ==="
	@$(MAKE) destroy-dev || true
	@$(MAKE) destroy-staging || true
	@$(MAKE) destroy-prod || true
	@$(MAKE) destroy-shared || true
	@echo "=== destroy-all complete (projects still exist; run 'make destroy-org' ONLY if you really want to delete them) ==="
