.PHONY: dev check doctor hosts certs up down tf-init tf-apply tf-destroy fmt validate

TF_DIR=infra/envs/local
CERT_DIR=infra/modules/docker_fastapi_platform/certs

# ------------- High level -------------
dev: doctor hosts certs up
	@echo ""
	@echo "✅ Dev environment ready:"
	@echo "   https://api.localhost/docs"
	@echo "   https://api.localhost/health"
	@echo "   https://traefik.localhost"
	@echo ""

check:
	@echo "==> Running checks (terraform + pytest)..."
	@if command -v bash >/dev/null 2>&1; then \
		bash scripts/check.sh; \
	else \
		powershell -ExecutionPolicy Bypass -File scripts/check.ps1; \
	fi

doctor:
	@echo "==> Running doctor..."
	@if command -v bash >/dev/null 2>&1; then \
		bash scripts/doctor.sh; \
	else \
		powershell -ExecutionPolicy Bypass -File scripts/doctor.ps1; \
	fi

# ------------- Hosts -------------
hosts:
	@echo "==> Updating hosts entries..."
	@if command -v bash >/dev/null 2>&1; then \
		bash scripts/bootstrap-hosts.sh; \
	else \
		powershell -ExecutionPolicy Bypass -File scripts/bootstrap-hosts.ps1; \
	fi

# ------------- TLS Certs -------------
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

# ------------- Terraform -------------
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
	cd $(TF_DIR) && terraform init -backend=false
	cd $(TF_DIR) && terraform validate
