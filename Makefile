SKILLS_SRC = processing-tools/skills
SKILLS_DST = instance/my-config/agent/skills

.PHONY: build sync-skills clean

build: sync-skills ## Build the runner image
	git submodule update --init --recursive
	docker build -f dev-bot/Dockerfile.runner -t ctibor-bot:local .

sync-skills: ## Copy shared skills from processing-tools submodule
	@git submodule update --init processing-tools
	@for skill in $(SKILLS_SRC)/*/; do \
		name=$$(basename "$$skill"); \
		echo "  Syncing skill: $$name"; \
		rm -rf $(SKILLS_DST)/$$name; \
		cp -r "$$skill" $(SKILLS_DST)/$$name; \
		find $(SKILLS_DST)/$$name -type l ! -exec test -e {} \; -delete 2>/dev/null; \
	done
	@echo "Skills synced from processing-tools."

clean: ## Remove synced skills
	@for skill in $(SKILLS_SRC)/*/; do \
		name=$$(basename "$$skill"); \
		rm -rf $(SKILLS_DST)/$$name; \
	done
