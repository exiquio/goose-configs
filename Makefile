.PHONY: validate test install check

# Validate agent profiles — structural checks only
validate:
	@echo "Validating agent profiles..."
	@for f in agents/*.md; do \
		if [ "$$f" = "agents/_policies.md" ]; then continue; fi; \
		echo "  Checking $$f..."; \
		head -1 "$$f" | grep -q '^---$$' || { echo "    ✗ Missing YAML frontmatter"; exit 1; }; \
		grep -q 'name:' "$$f" || { echo "    ✗ Missing name field"; exit 1; }; \
		grep -q 'model:' "$$f" || { echo "    ✗ Missing model field"; exit 1; }; \
		grep -q '## Output Format' "$$f" || { echo "    ✗ Missing Output Format section"; exit 1; }; \
		grep -q '## Summary' "$$f" || { echo "    ✗ Missing Summary in output format"; exit 1; }; \
		grep -q 'Diagnose before fixing' "$$f" || echo "    ⚠ Missing diagnose-before-fixing directive"; \
	done
	@echo "  ✓ All profiles pass validation"

# Test full pipeline (placeholder — expand with actual tests)
test:
	@echo "Running profile regression tests..."
	@$(MAKE) validate
	@echo "  ✓ All tests pass"

# Install symlinks for Goose discovery
install:
	@echo "Setting up symlinks..."
	@mkdir -p $(HOME)/.agents
	@ln -sfn $(CURDIR)/agents $(HOME)/.agents/agents
	@mkdir -p $(HOME)/.config/goose
	@ln -sfn $(CURDIR)/goosehints $(HOME)/.config/goose/goosehints
	@ln -sfn $(CURDIR)/config.yaml $(HOME)/.config/goose/config.yaml
	@echo "  ✓ Symlinks created"

# Pre-push check — run before pushing
check: validate
	@echo "Running pre-push checks..."
	@if git rev-parse --abbrev-ref HEAD | grep -q '^main$$'; then \
		echo "  ✗ DO NOT push directly to main. Use a feature branch."; \
		exit 1; \
	fi
	@echo "  ✓ Branch check passed"
	@echo "  ✓ All pre-push checks passed"
