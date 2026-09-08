# Copyright (c) 2020 Tailscale Inc & AUTHORS All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# ============================================================================
# 简化版 Makefile
# 本文件已移除对定制 Go 编译器 (tailscale_go) 的依赖，改用标准 Go 1.24+。
# 构建产物为 libtailscale.aar，供 Android 应用集成。
# ============================================================================

# 从 gradle.properties 读取 Android API 级别
ANDROID_API_LEVEL := $(shell grep '^androidApiLevel=' android/gradle.properties | cut -d'=' -f2)
ifeq ($(ANDROID_API_LEVEL),)
$(error androidApiLevel missing from android/gradle.properties)
endif

# 从 gradle.properties 读取 Build Tools 版本
ANDROID_BUILD_TOOLS_VERSION := $(shell grep '^androidBuildToolsVersion=' android/gradle.properties | cut -d'=' -f2)

# 输出文件路径
LIBTAILSCALE_AAR := android/libs/libtailscale.aar
DEBUG_APK := tailscale-debug.apk
RELEASE_AAB := tailscale-release.aab

# Go 构建标签：禁用 netmap 缓存（Android 缺乏调试 UI 支持）
GOMOBILE_BUILD_TAGS := ts_omit_cachenetmap

# 版本号基数：以分钟为单位的时间戳 * 10，末位保留给平台标识（0=手机/平板，1=Android TV）
ifndef VERSION_CODE_BASE
VERSION_CODE_BASE := $(shell echo $$(( $$(date +%s) / 60 * 10 )))
endif
export VERSION_CODE_BASE

# ============================================================================
# 默认目标
# ============================================================================

.PHONY: all
all: aar

# ============================================================================
# 主要构建目标
# ============================================================================

# 生成 libtailscale.aar（使用独立脚本）
.PHONY: aar
aar:
	@echo "==> 生成 libtailscale.aar（标准 Go 1.24+ / NDK 26+）"
	@./scripts/build_aar.sh

# 生成调试 APK
.PHONY: apk
apk: aar
	@echo "==> 构建调试 APK"
	@cd android && ./gradlew assembleDebug
	@cp android/build/outputs/apk/debug/android-debug.apk $(DEBUG_APK)
	@echo "==> APK 已生成: $(DEBUG_APK)"

# 生成发布 AAB
.PHONY: aab
aab: aar
	@echo "==> 构建发布 AAB"
	@cd android && ./gradlew bundleRelease
	@cp android/build/outputs/bundle/release/android-release.aab $(RELEASE_AAB)
	@echo "==> AAB 已生成: $(RELEASE_AAB)"

# 清理构建产物
.PHONY: clean
clean:
	@rm -f $(LIBTAILSCALE_AAR) $(DEBUG_APK) $(RELEASE_AAB)
	@cd android && ./gradlew clean 2>/dev/null || true
	@echo "==> 清理完成"

# ============================================================================
# 环境准备目标
# ============================================================================

# 安装 Android SDK 组件（通过 sdkmanager）
.PHONY: androidsdk
androidsdk:
	@echo "==> 安装 Android SDK 组件..."
	@if [ -z "$$ANDROID_HOME" ] && [ -z "$$ANDROID_SDK_ROOT" ]; then \
		echo "错误: 请设置 ANDROID_HOME 或 ANDROID_SDK_ROOT"; \
		exit 1; \
	fi
	@yes | sdkmanager --licenses >/dev/null 2>&1 || true
	@sdkmanager "platforms;android-$(ANDROID_API_LEVEL)" \
	           "build-tools;$(ANDROID_BUILD_TOOLS_VERSION)" \
	           "ndk;26.3.11579264" \
	           "cmdline-tools;latest"
	@echo "==> SDK 组件安装完成"

# 显示帮助信息
.PHONY: help
help:
	@echo "Tailscale Android 构建命令（简化版）"
	@echo ""
	@echo "  make aar        - 生成 libtailscale.aar"
	@echo "  make apk        - 生成调试 APK"
	@echo "  make aab        - 生成发布 AAB"
	@echo "  make clean      - 清理构建产物"
	@echo "  make androidsdk - 安装 Android SDK 组件"
	@echo "  make help       - 显示此帮助"

.DEFAULT_GOAL := help
