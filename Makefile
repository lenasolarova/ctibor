SKILLS_SRC = processing-tools/skills

INSTANCE_CONFIGS = my-config backlog-groomer

.PHONY: build sync-skills clean

build: sync-skills ## Build the runner image
	git submodule update --init --recursive
	docker build -f dev-bot/Dockerfile.runner -t ctibor-bot:local .

sync-skills: ## Copy shared skills from processing-tools submodule
	@git submodule update --init processing-tools
	@for config in $(INSTANCE_CONFIGS); do \
		dst="instance/$$config/agent/skills"; \
		mkdir -p "$$dst"; \
		for skill in $(SKILLS_SRC)/*/; do \
			name=$$(basename "$$skill"); \
			echo "  [$$config] Syncing skill: $$name"; \
			rm -rf "$$dst/$$name"; \
			cp -r "$$skill" "$$dst/$$name"; \
			find "$$dst/$$name" -type l ! -exec test -e {} \; -delete 2>/dev/null; \
		done; \
	done
	@echo "Skills synced from processing-tools."

clean: ## Remove synced skills
	@for config in $(INSTANCE_CONFIGS); do \
		dst="instance/$$config/agent/skills"; \
		for skill in $(SKILLS_SRC)/*/; do \
			name=$$(basename "$$skill"); \
			rm -rf "$$dst/$$name"; \
		done; \
	done
