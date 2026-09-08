#!/bin/bash
# ============================================================================
# 独立 AAR 生成脚本
# 本脚本使用标准 Go 1.24+ 和 gomobile 生成 libtailscale.aar，
# 不依赖 Tailscale 定制 Go 编译器 (tailscale_go)。
# ============================================================================

set -e

echo "==> 开始生成 libtailscale.aar"

# ----------------------------------------------------------------------------
# 检查 Go 版本
# ----------------------------------------------------------------------------
GO_VERSION=$(go version | grep -o 'go[0-9]\+\.[0-9]\+' | head -1 | sed 's/go//')
if [ -z "$GO_VERSION" ]; then
    echo "错误: 未找到 Go，请安装 Go 1.24+"
    exit 1
fi
echo "==> 检测到 Go 版本: $GO_VERSION"

GO_MAJOR=$(echo "$GO_VERSION" | cut -d. -f1)
GO_MINOR=$(echo "$GO_VERSION" | cut -d. -f2)
if [ "$GO_MAJOR" -lt 1 ] || ([ "$GO_MAJOR" -eq 1 ] && [ "$GO_MINOR" -lt 24 ]); then
    echo "警告: Go 版本 $GO_VERSION 低于推荐版本 1.24，继续尝试构建..."
fi

# ----------------------------------------------------------------------------
# 设置环境变量
# ----------------------------------------------------------------------------
export GO111MODULE=on
export GOFLAGS="-mod=mod"

# ----------------------------------------------------------------------------
# 检测 Android SDK
# ----------------------------------------------------------------------------
if [ -n "$ANDROID_HOME" ]; then
    export ANDROID_HOME="$ANDROID_HOME"
elif [ -n "$ANDROID_SDK_ROOT" ]; then
    export ANDROID_HOME="$ANDROID_SDK_ROOT"
elif [ -d "$HOME/Android/Sdk" ]; then
    export ANDROID_HOME="$HOME/Android/Sdk"
else
    echo "错误: 未找到 Android SDK，请设置 ANDROID_HOME 或 ANDROID_SDK_ROOT"
    exit 1
fi
echo "==> 使用 Android SDK: $ANDROID_HOME"

# ----------------------------------------------------------------------------
# 检测 NDK 版本（要求 NDK 26+）
# ----------------------------------------------------------------------------
NDK_PATH=""
NDK_DIR="$ANDROID_HOME/ndk"
if [ -d "$NDK_DIR" ]; then
    # 优先使用 NDK 26.3.11579264，其次使用任意 26+ 版本
    if [ -d "$NDK_DIR/26.3.11579264" ]; then
        NDK_PATH="$NDK_DIR/26.3.11579264"
    else
        NDK_VERSION=$(ls "$NDK_DIR" | grep -E '^2[6-9]' | sort -V | tail -1)
        if [ -n "$NDK_VERSION" ]; then
            NDK_PATH="$NDK_DIR/$NDK_VERSION"
        fi
    fi
fi

if [ -n "$NDK_PATH" ]; then
    echo "==> 使用 NDK: $NDK_PATH"
else
    echo "警告: 未找到 NDK 26+，请通过 sdkmanager 安装: ndk;26.3.11579264"
    echo "提示: 某些 gomobile 功能可能需要 NDK 支持，继续尝试构建..."
fi

# ----------------------------------------------------------------------------
# 安装 / 更新 gomobile
# ----------------------------------------------------------------------------
echo "==> 安装 gomobile..."
go install golang.org/x/mobile/cmd/gomobile@latest
gomobile init

# ----------------------------------------------------------------------------
# 执行 gomobile bind
# ----------------------------------------------------------------------------
mkdir -p android/libs

echo "==> 执行 gomobile bind（目标 API 21，Android 5.0+）..."
gomobile bind \
    -target=android \
    -androidapi=21 \
    -tags=tailscale_go \
    -o ./android/libs/libtailscale.aar \
    ./libtailscale

# ----------------------------------------------------------------------------
# 验证生成结果
# ----------------------------------------------------------------------------
if [ -f "./android/libs/libtailscale.aar" ]; then
    FILE_SIZE=$(du -h "./android/libs/libtailscale.aar" | cut -f1)
    echo "==> 成功生成 AAR: ./android/libs/libtailscale.aar（大小: $FILE_SIZE）"
else
    echo "==> 错误: AAR 生成失败"
    exit 1
fi
