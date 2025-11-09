#!/bin/bash

# 前端构建脚本
# 用于在部署前构建 uni-app Web 版本

# 不使用 set -e，以便更好地处理构建失败的情况

echo "=========================================="
echo "前端项目构建脚本"
echo "=========================================="

# 检查 Node.js 和 npm 是否安装
if ! command -v node &> /dev/null; then
    echo "错误: 未检测到 Node.js"
    echo ""
    echo "请先安装 Node.js 和 npm："
    echo ""
    echo "方法 1: 使用 nvm (推荐)"
    echo "  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash"
    echo "  source ~/.bashrc"
    echo "  nvm install 18"
    echo "  nvm use 18"
    echo ""
    echo "方法 2: 使用 apt (Ubuntu/Debian)"
    echo "  curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -"
    echo "  sudo apt-get install -y nodejs"
    echo ""
    exit 1
fi

if ! command -v npm &> /dev/null; then
    echo "错误: 未检测到 npm"
    echo "npm 应该随 Node.js 一起安装，请检查 Node.js 安装是否正确"
    exit 1
fi

echo "Node.js 版本: $(node --version)"
echo "npm 版本: $(npm --version)"
echo ""

# 检查是否安装了依赖
if [ ! -d "node_modules" ]; then
    echo "正在安装依赖..."
    npm install
fi

# 检查是否有 uni 命令（uni-app CLI）
# 注意：uni-app 通常使用 HBuilderX 构建，命令行构建需要完整配置
if ! command -v uni &> /dev/null; then
    echo "警告: 未检测到 uni 命令"
    echo ""
    echo "uni-app 项目通常使用 HBuilderX IDE 构建，命令行构建需要完整配置。"
    echo ""
    echo "推荐方式：使用 HBuilderX 构建"
    echo "  1. 下载并安装 HBuilderX: https://www.dcloud.io/hbuilderx.html"
    echo "  2. 在 HBuilderX 中打开当前项目目录"
    echo "  3. 运行 -> 运行到浏览器 -> Chrome (开发)"
    echo "  4. 发行 -> 原生App-云打包 -> 选择 Web 平台"
    echo "  5. 构建产物在: unpackage/dist/build/web"
    echo ""
    read -p "是否继续尝试命令行构建？(y/n): " continue_build
    if [ "$continue_build" != "y" ] && [ "$continue_build" != "Y" ]; then
        echo "已取消构建，请使用 HBuilderX 构建后重新运行部署脚本"
        exit 0
    fi
    echo ""
    echo "尝试安装 uni-app 构建依赖..."
    # uni-app 命令行构建需要安装相关依赖
    # 这里不强制安装，让用户知道需要配置
fi

# 配置 API 地址
if [ -n "$1" ]; then
    API_BASE_URL=$1
else
    read -p "请输入后端 API 地址 (例如: http://your-ip:3000): " API_BASE_URL
fi

echo "配置 API 地址: $API_BASE_URL"

# 更新 API 配置文件
if [ -f "utils/api.js" ]; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s|const API_BASE_URL = .*|const API_BASE_URL = '$API_BASE_URL';|" utils/api.js
    else
        # Linux
        sed -i "s|const API_BASE_URL = .*|const API_BASE_URL = '$API_BASE_URL';|" utils/api.js
    fi
fi

# 检查 package.json 中是否有 build:h5 脚本
if ! grep -q "build:h5" package.json 2>/dev/null; then
    echo "警告: package.json 中未找到 build:h5 脚本"
    echo ""
    echo "uni-app 项目通常需要使用 HBuilderX 构建，或者需要配置完整的构建环境。"
    echo ""
    echo "请使用以下方式之一构建："
    echo ""
    echo "方式 1: 使用 HBuilderX（推荐）"
    echo "  1. 下载 HBuilderX: https://www.dcloud.io/hbuilderx.html"
    echo "  2. 打开当前项目目录"
    echo "  3. 发行 -> 原生App-云打包 -> 选择 Web 平台"
    echo "  4. 构建产物在: unpackage/dist/build/web"
    echo ""
    echo "方式 2: 手动创建构建产物目录"
    echo "  mkdir -p unpackage/dist/build/web"
    echo "  # 然后复制必要的文件或使用其他构建工具"
    echo ""
    read -p "是否继续尝试使用 npm run build？(y/n): " try_build
    if [ "$try_build" != "y" ] && [ "$try_build" != "Y" ]; then
        echo "已取消构建"
        exit 0
    fi
fi

# 尝试构建 Web 版本
echo "正在尝试构建 Web 版本..."

BUILD_SUCCESS=false

# 尝试使用 build:h5 脚本
if grep -q "build:h5" package.json 2>/dev/null; then
    echo "尝试运行: npm run build:h5"
    if npm run build:h5; then
        BUILD_SUCCESS=true
        echo "构建成功！"
    fi
fi

# 如果 build:h5 失败，尝试使用 build 脚本
if [ "$BUILD_SUCCESS" = false ]; then
    if grep -q '"build"' package.json 2>/dev/null; then
        echo "尝试运行: npm run build"
        if npm run build; then
            BUILD_SUCCESS=true
            echo "使用 build 脚本构建成功！"
        fi
    fi
fi

# 检查构建产物是否存在
if [ "$BUILD_SUCCESS" = false ]; then
    if [ -d "unpackage/dist/build/web" ] && [ -n "$(ls -A unpackage/dist/build/web 2>/dev/null)" ]; then
        echo "检测到已有构建产物在 unpackage/dist/build/web 目录"
        BUILD_SUCCESS=true
    fi
fi

if [ "$BUILD_SUCCESS" = false ]; then
    echo ""
    echo "构建失败，这可能是因为 uni-app 需要 HBuilderX 或完整的构建配置。"
    echo ""
    echo "请使用 HBuilderX 构建："
    echo "  1. 下载 HBuilderX: https://www.dcloud.io/hbuilderx.html"
    echo "  2. 打开项目目录: $(pwd)"
    echo "  3. 发行 -> 原生App-云打包 -> 选择 Web 平台"
    echo "  4. 构建产物应该在: unpackage/dist/build/web"
    echo ""
    echo "或者，如果已有构建产物，请确保在以下目录："
    echo "  $(pwd)/unpackage/dist/build/web"
    echo ""
    exit 1
fi

echo "构建完成！构建产物在: unpackage/dist/build/web"
echo "现在可以运行 docker compose build 来构建 Docker 镜像"

