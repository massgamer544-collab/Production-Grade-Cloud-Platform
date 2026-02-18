
.PHONY: dev host certs up down tf-init tf-apply tf-testroy

TF_DIR=infra/envs/local
CERT_DIR=infra/modules/docker_fastapi_platform/certs

dev:
	@echo "==> Starting dev environment..."
	@if command -v bash >/dev/null 2>&1; then \
		bash scripts/dev.sh; \
	else \
		powershell -ExecutionPolicy Bypass -File scripts/dev.ps1; \
	fi
	
check:
	@echo "==> Running checks (terraform + pytest)..."
	@if command -v bash >/dev/null 2>&1; then \
		bash scripts/check.sh; \
	else \
		powershell -ExecutionPolicy Bypass -File scripts/check.ps1; \
	fi

# ----- Host -------
hosts:
	@echo "==> Updating hosts entries..."
	@if [ "$$(uname -s 2>/dev/null || echo Windows)" = "Windows" ]; then \
		echo "Windows detected. Run in an elevated terminal (Admin)."; \
		powershell -ExecutionPolicy Bypass -File scripts/bootstrap-hosts.ps1; \
	else \
		bash scripts/bootstrap-hosts.sh; \
	fi

# ---- TLS Certs ----
certs:
@echo "==> Generating TLS certs (SAN: localhost, api.localhost, traefik.localhost)..."
	@mkdir -p $(CERT_DIR)
	@if [ ! -f "$(CERT_DIR)/localhost.key" ] || [ ! -f "$(CERT_DIR)/localhost.crt" ]; then \
		openssl req -x509 -newkey rsa:2048 -sha256 -days 365 -nodes \
		  -keyout $(CERT_DIR)/localhost.key \
		  -out $(CERT_DIR)/localhost.crt \
		  -config $(CERT_DIR)/openssl.cnf \
		  -extensions req_ext; \
	else \
		echo "Certs already exist. (Delete $(CERT_DIR)/localhost.* to regenerate)"; \
	fi

# ---- Terraform ----
tf-init:
	cd $(TF_DIR) && terraform init

tf-apply:
	cd $(TF_DIR) && terraform apply -auto-approve

tf-destroy:
	cd $(TF_DIR) && terraform destroy -auto-approve

up: tf-init tf-apply

down: tf-destroy

fmt: 
	cd infra && terraform fmt -recursive

validate:
	cd infra/envs/local && terraform init -backend=false
	cd infra/envs/local && terraform validate

up: 
	cd infra/envs/local && terraform init
	cd infra/envs/local && terraform apply -auto-approve

down:
	cd infra/envs/local && terraform destroy -auto-approve

bootstrap-windows:
	powershell -ExecutionPolicy Bypass -File scripts/bootstrap-hosts.ps1

bootstrap-linux:
	bash scripts/bootstrap-linux.sh
