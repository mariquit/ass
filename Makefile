SKILLS := adr de-slop deconstruct frontend pre-flight regression-test tech-writer terse triage
CLAUDE_SKILLS_DIR ?= $(HOME)/.claude/skills
OPENCODE_SKILLS_DIR ?= $(HOME)/.config/opencode/skills

.DEFAULT_GOAL := deploy

.PHONY: deploy deploy-skill

deploy: deploy-skill

deploy-skill:
	@set -eu; \
	for skill in $(SKILLS); do \
		for destination in "$(CLAUDE_SKILLS_DIR)" "$(OPENCODE_SKILLS_DIR)"; do \
			mkdir -p "$$destination/$$skill"; \
			cp "$$skill.md" "$$destination/$$skill/SKILL.md"; \
		done; \
	done
