SHELL := /bin/sh
PROFILES_FILE ?= profiles.yml
PROFILE ?= software-engineer
OUT_DIR ?= build
OUTPUT ?= $(OUT_DIR)/$(PROFILE).pdf
TYPST ?= typst
PROFILES ?= $(shell awk '\
  $$0 ~ /^profiles:[[:space:]]*$$/ { in_profiles = 1; next } \
  in_profiles && $$0 ~ /^[^[:space:]]/ { in_profiles = 0 } \
  in_profiles && $$0 ~ /^  [A-Za-z0-9._-]+:[[:space:]]*$$/ { \
    key = $$1; sub(/:$$/, "", key); print key \
  } \
' $(PROFILES_FILE))
ACTIVE_PROFILES ?= $(PROFILES)
PREVIEW_OUTPUT ?= assets/resume-preview.png

.PHONY: compile watch all watch-all profiles preview style-warn style-check check check-all clean

compile:
	@mkdir -p $(OUT_DIR)
	$(TYPST) compile main.typ $(OUTPUT) --input profile=$(PROFILE)

watch:
	@mkdir -p $(OUT_DIR)
	$(TYPST) watch main.typ $(OUTPUT) --input profile=$(PROFILE)

all:
	@set -e; \
	for p in $(ACTIVE_PROFILES); do \
		$(MAKE) compile PROFILE=$$p; \
	done

watch-all:
	@mkdir -p $(OUT_DIR)
	@set -e; \
	pids=""; \
	for p in $(ACTIVE_PROFILES); do \
		echo "watching $$p -> $(OUT_DIR)/$$p.pdf"; \
		$(TYPST) watch main.typ $(OUT_DIR)/$$p.pdf --input profile=$$p & \
		pids="$$pids $$!"; \
	done; \
	trap 'kill $$pids 2>/dev/null || true' INT TERM; \
	wait

profiles:
	@for p in $(PROFILES); do echo $$p; done

preview:
	@mkdir -p $(OUT_DIR)
	@$(MAKE) compile PROFILE=$(PROFILE)
	@./scripts/generate-preview.sh "$(OUTPUT)" "$(PREVIEW_OUTPUT)"

style-warn:
	@./scripts/style-check.sh warn

style-check:
	@./scripts/style-check.sh assert

check:
	@$(MAKE) style-check
	@$(MAKE) compile PROFILE=$(PROFILE)
	@pages=""; \
	if command -v pdfinfo >/dev/null 2>&1; then \
		pages=$$(pdfinfo "$(OUTPUT)" 2>/dev/null | awk '/Pages:/ {print $$2}'); \
	fi; \
	if [ -z "$$pages" ] && command -v file >/dev/null 2>&1; then \
		pages=$$(file "$(OUTPUT)" | sed -n 's/.*PDF document, version [^,]*, \([0-9][0-9]*\) pages/\1/p'); \
	fi; \
	if [ -n "$$pages" ]; then \
		echo "$(PROFILE): $$pages page(s) -> $(OUTPUT)"; \
		test "$$pages" = "1"; \
	else \
		echo "$(PROFILE): compiled -> $(OUTPUT) (page count check skipped: no supported tool)"; \
	fi

check-all:
	@for p in $(ACTIVE_PROFILES); do \
		$(MAKE) check PROFILE=$$p || exit 1; \
	done

clean:
	rm -rf $(OUT_DIR)
