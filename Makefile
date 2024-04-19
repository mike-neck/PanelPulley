CONFIGURATIONS := debug release
SWIFT_FORMAT := $(shell which swift-format)
BUILD_DIR := .build
BUILD := build
CACHE_DIRS := repositories checkouts

.PHONY: tasks
tasks:
	@echo $(@)
	@$(foreach config,$(CONFIGURATIONS), echo build-$(config);)

define BuildTask
.PHONY: build-$(1)
build-$(1):
	@echo $(1)
	@swift build --configuration $(1)

endef

$(foreach config,$(CONFIGURATIONS),$(eval $(call BuildTask,$(config))))

.PHONY: all $(BUILD)
all: $(foreach config,$(CONFIGURATIONS),build-$(config))

$(BUILD): all
	@test -d $(@) || mkdir $(@)
	@$(foreach config,$(CONFIGURATIONS),mkdir -p $(BUILD)/$(config) ;)
	@$(foreach config,$(CONFIGURATIONS),find -H $(BUILD_DIR)/$(config) -type f -perm 0755 -exec cp "{}" "$(BUILD)/$(config)/" \; ;)

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

endif
