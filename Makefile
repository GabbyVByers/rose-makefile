
# make clean - deletes the build directory
# make build - builds the program
# make run   - builds and runs the program
# make start - cleans, builds, and runs (full rebuild)
#
# Build requires the Vulkan SDK (https://vulkan.lunarg.com)
# Including the optional "SDL libraries and headers" component

ifeq ($(VULKAN_SDK),)
    $(error Vulkan SDK is required: (see https://vulkan.lunarg.com))
endif

VULKAN_SDK_DIR := $(subst \,/,$(VULKAN_SDK))

ifeq ($(wildcard $(VULKAN_SDK_DIR)/Include/SDL3/SDL.h),)
    $(error SDL3 not found in the Vulkan SDK: install its "SDL libraries and headers" component)
endif

CC       := gcc
CPPFLAGS := -isystem $(VULKAN_SDK_DIR)/Include -isystem libraries/stb-master
CFLAGS   := -std=c17 -Wall -Wextra -Wpedantic -g -O0
LDFLAGS  := -L$(VULKAN_SDK_DIR)/Lib
LDLIBS   := -lSDL3

SRC_DIR    := source
SHADER_DIR := shaders
ASSET_DIR  := assets
BUILD_DIR  := build
TARGET     := app

ifeq ($(OS),Windows_NT)
    EXE := .exe
endif

SRCS := $(wildcard $(SRC_DIR)/*.c)
OBJS := $(SRCS:$(SRC_DIR)/%.c=$(BUILD_DIR)/obj/%.o)
DEPS := $(OBJS:.o=.d)
BIN  := $(BUILD_DIR)/$(TARGET)$(EXE)

GLSLC       := $(VULKAN_SDK_DIR)/Bin/glslc
SHADER_OUTS := $(BUILD_DIR)/shaders/vertex.spv $(BUILD_DIR)/shaders/fragment.spv

rwildcard = $(foreach d,$(wildcard $(1)/*),$(call rwildcard,$(d))$(filter-out $(wildcard $(d)/.),$(d)))

ASSETS     := $(call rwildcard,$(ASSET_DIR))
ASSET_OUTS := $(ASSETS:$(ASSET_DIR)/%=$(BUILD_DIR)/assets/%)

.PHONY: all build run clean start

all: build

build: $(BIN) $(SHADER_OUTS) $(ASSET_OUTS)

$(BIN): $(OBJS)
	$(CC) $(OBJS) $(LDFLAGS) $(LDLIBS) -o $@

$(BUILD_DIR)/obj/%.o: $(SRC_DIR)/%.c
	@mkdir -p $(@D)
	$(CC) $(CPPFLAGS) $(CFLAGS) -MMD -MP -c $< -o $@

$(BUILD_DIR)/shaders/vertex.spv: $(SHADER_DIR)/shader.vert
	@mkdir -p $(@D)
	$(GLSLC) $< -o $@

$(BUILD_DIR)/shaders/fragment.spv: $(SHADER_DIR)/shader.frag
	@mkdir -p $(@D)
	$(GLSLC) $< -o $@

$(BUILD_DIR)/assets/%: $(ASSET_DIR)/%
	@mkdir -p $(@D)
	cp $< $@

run: build
	cd $(BUILD_DIR) && ./$(TARGET)$(EXE)

clean:
	rm -rf $(BUILD_DIR)

-include $(DEPS)

start:
	$(MAKE) clean
	$(MAKE) run

