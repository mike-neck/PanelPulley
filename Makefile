CONFIGURATIONS := debug release

.PHONY: tasks
tasks:
	@echo $(@)
	@$(foreach config,$(CONFIGURATIONS), echo build-$(config);)

define BuildTask
.PHONY: build-$(1)
build-$(1):
	@echo $(@)
	@swift build --configuration $(1)

endef

$(foreach config,$(CONFIGURATIONS),$(eval $(call BuildTask,$(config))))

.PHONY: all
all: $(foreach config,$(CONFIGURATIONS),build-$(config))

.PHONY: clean
clean:
	@echo $(@)
	@rm -rf ./build
