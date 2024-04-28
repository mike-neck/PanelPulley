CONFIGURATIONS := debug release
SWIFT_FORMAT := $(shell which swift-format)
BUILD_DIR := .build
BUILD := build
CACHE_DIRS := repositories checkouts
TEST_REPORT := $(BUILD)/test-report.xml

ALL_SCRIPTS := $(wildcard scripts/*)
SCRIPTS := $(subst scripts/,,$(ALL_SCRIPTS))

ARCH := $(shell uname -m)
OS_NAME := $(shell uname -s)

.PHONY: tasks
tasks:
	@echo $(@)
	@$(foreach config,$(CONFIGURATIONS), echo build-$(config);)
	@echo $(BUILD)
	@echo all
	@echo build-dir
	@echo clean
	@echo format
	@echo test
	@echo next-version
	@$(foreach script,$(SCRIPTS), echo $(script);)

.PHONY: version.txt
version.txt:
	@echo $(@)
	@(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0") > Sources/$(@)

define BuildTask
.PHONY: build-$(1)
build-$(1): version.txt
	@echo $(1)
	@swift build --configuration $(1)

endef

$(foreach config,$(CONFIGURATIONS),$(eval $(call BuildTask,$(config))))

.PHONY: all $(BUILD) build-dir
all: $(foreach config,$(CONFIGURATIONS),build-$(config))

build-dir:
	@mkdir -p $(BUILD)

$(BUILD): all
	@test -d $(@) || mkdir $(@)
	@$(foreach config,$(CONFIGURATIONS),mkdir -p $(BUILD)/$(config) ;)
	@$(foreach config,$(CONFIGURATIONS),find -H $(BUILD_DIR)/$(config) -type f -perm 0755 -exec cp "{}" "$(BUILD)/$(config)/" \; ;)
	@$(foreach config,$(CONFIGURATIONS),find $(BUILD)/$(config) -type f -perm 0755 -exec zip --junk-paths "$(BUILD)/$(OS_NAME)-$(config)-$(ARCH).zip" "{}" \; ;)

.PHONY: clean
clean:
	@echo $(@)
	@rm -rf $(BUILD)
	@find $(BUILD_DIR) -mindepth 1 -maxdepth 1 $(foreach cache,$(CACHE_DIRS),! -name "$(cache)") ! -name '*.json' -print -exec rm -rf {} \;

ifneq "$(SWIFT_FORMAT)" ""
.PHONY: format
format:
	@echo $(@)
	@$(SWIFT_FORMAT) --recursive --parallel --in-place --ignore-unparsable-files Sources
	@$(SWIFT_FORMAT) --recursive --parallel --in-place --ignore-unparsable-files Tests

endif

.PHONY: test
test: build-dir
test:
	@echo $(@)
	@swift test --parallel --xunit-output $(TEST_REPORT) --enable-code-coverage | tee "$(BUILD)/test-execution.log"
	@cp "$$(swift test --show-coverage-path)" "$(BUILD)/test-coverage.json"

ifneq "$(NEXT)" ""
.PHONY: next-version
next-version:
	@echo $(@)
	@$(PWD)/new-version.sh "$(NEXT)" | while read -r version; do git tag -a "$${version}" -m "$${version}" ; done

endif

.PHONY: $(SCRIPTS)
$(SCRIPTS):
	@./scripts/$(@)
