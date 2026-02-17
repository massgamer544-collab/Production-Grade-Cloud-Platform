
.PHONY: fmt validate up down

urls:
	@echo "Gateway: http://localhost"
	@echo "Traefik dashboard: http://localhost:8080"

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