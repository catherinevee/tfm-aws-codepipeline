# ==============================================================================
# Makefile for AWS CodePipeline CI/CD Terraform Module
# ==============================================================================

.PHONY: help init plan apply destroy validate fmt lint clean test examples

# Default target
help:
	@echo "Available targets:"
	@echo "  init      - Initialize Terraform"
	@echo "  plan      - Create Terraform plan"
	@echo "  apply     - Apply Terraform configuration"
	@echo "  destroy   - Destroy Terraform resources"
	@echo "  validate  - Validate Terraform configuration"
	@echo "  fmt       - Format Terraform code"
	@echo "  lint      - Lint Terraform code"
	@echo "  clean     - Clean up temporary files"
	@echo "  test      - Run tests"
	@echo "  examples  - Deploy examples"

# Initialize Terraform
init:
	@echo "Initializing Terraform..."
	terraform init

# Create Terraform plan
plan:
	@echo "Creating Terraform plan..."
	terraform plan -out=tfplan

# Apply Terraform configuration
apply:
	@echo "Applying Terraform configuration..."
	terraform apply tfplan

# Destroy Terraform resources
destroy:
	@echo "Destroying Terraform resources..."
	terraform destroy

# Validate Terraform configuration
validate:
	@echo "Validating Terraform configuration..."
	terraform validate

# Format Terraform code
fmt:
	@echo "Formatting Terraform code..."
	terraform fmt -recursive

# Lint Terraform code (requires tflint)
lint:
	@echo "Linting Terraform code..."
	@if command -v tflint >/dev/null 2>&1; then \
		tflint --init; \
		tflint; \
	else \
		echo "tflint not found. Install with: go install github.com/terraform-linters/tflint/cmd/tflint@latest"; \
	fi

# Clean up temporary files
clean:
	@echo "Cleaning up temporary files..."
	rm -f tfplan
	rm -rf .terraform
	rm -rf .terraform.lock.hcl

# Run tests
test:
	@echo "Running tests..."
	@if [ -d "test" ]; then \
		cd test && terraform init && terraform plan; \
	else \
		echo "No test directory found"; \
	fi

# Deploy examples
examples: examples-basic examples-advanced

examples-basic:
	@echo "Deploying basic example..."
	cd examples/basic && terraform init && terraform plan

examples-advanced:
	@echo "Deploying advanced example..."
	cd examples/advanced && terraform init && terraform plan

# Security scan (requires terrascan)
security-scan:
	@echo "Running security scan..."
	@if command -v terrascan >/dev/null 2>&1; then \
		terrascan scan -i terraform; \
	else \
		echo "terrascan not found. Install with: go install github.com/tenable/terrascan/cmd/terrascan@latest"; \
	fi

# Documentation
docs:
	@echo "Generating documentation..."
	@if command -v terraform-docs >/dev/null 2>&1; then \
		terraform-docs markdown table . > README.md.tmp; \
		echo "Documentation generated in README.md.tmp"; \
	else \
		echo "terraform-docs not found. Install with: go install github.com/terraform-docs/terraform-docs@latest"; \
	fi

# Pre-commit checks
pre-commit: fmt validate lint
	@echo "Pre-commit checks completed successfully"

# Full deployment workflow
deploy: init validate fmt plan apply
	@echo "Deployment completed successfully"

# Development setup
dev-setup:
	@echo "Setting up development environment..."
	@if ! command -v terraform >/dev/null 2>&1; then \
		echo "Terraform not found. Please install Terraform first."; \
		exit 1; \
	fi
	@if ! command -v aws >/dev/null 2>&1; then \
		echo "AWS CLI not found. Please install AWS CLI first."; \
		exit 1; \
	fi
	@echo "Development environment setup completed"

# Show module outputs
outputs:
	@echo "Module outputs:"
	@terraform output

# Show module state
state:
	@echo "Terraform state:"
	@terraform show

# Cost estimation (requires infracost)
cost:
	@echo "Estimating costs..."
	@if command -v infracost >/dev/null 2>&1; then \
		infracost breakdown --path .; \
	else \
		echo "infracost not found. Install with: curl -fsSL https://raw.githubusercontent.com/infracost/infracost/master/scripts/install.sh | sh"; \
	fi 