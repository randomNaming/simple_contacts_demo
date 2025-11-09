#!/bin/bash

# 联系人管理系统一键部署脚本
# 适用于 Ubuntu 22.04
# 注意：后端仓库应该在 ../contacts-backend

set -e

echo "=========================================="
echo "联系人管理系统 Docker 部署脚本"
echo "=========================================="

# 检查后端仓库是否存在
if [ ! -d "../contacts-backend" ]; then
    echo "错误: 未找到后端仓库"
    echo "请确保后端仓库在 ../contacts-backend 目录"
    echo ""
    echo "克隆后端仓库："
    echo "  cd .."
    echo "  git clone <后端仓库地址> contacts-backend"
    echo "  cd contacts-frontend"
    exit 1
fi

# 检查 Docker 是否安装
if ! command -v docker &> /dev/null; then
    echo "正在安装 Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
    echo "Docker 安装完成，请重新登录或运行: newgrp docker"
    exit 0
fi

# 检查 Docker Compose 是否安装（V2 版本作为 Docker 插件）
if ! docker compose version &> /dev/null; then
    echo "Docker Compose 未安装或不可用"
    echo "Docker Compose V2 通常随 Docker 一起安装"
    echo "如果未安装，请运行: sudo apt-get update && sudo apt-get install docker-compose-plugin"
    read -p "是否继续？(y/n): " continue_install
    if [ "$continue_install" != "y" ] && [ "$continue_install" != "Y" ]; then
        exit 1
    fi
fi

# 获取公网 IP
echo "正在获取服务器公网 IP..."
PUBLIC_IP=$(curl -s ifconfig.me || curl -s ipinfo.io/ip || echo "localhost")

if [ -z "$PUBLIC_IP" ] || [ "$PUBLIC_IP" == "localhost" ]; then
    read -p "无法自动获取公网 IP，请输入服务器公网 IP 地址: " PUBLIC_IP
fi

echo "检测到的公网 IP: $PUBLIC_IP"
read -p "确认使用此 IP 吗？(y/n): " confirm

if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    read -p "请输入正确的公网 IP 地址: " PUBLIC_IP
fi

# 更新 docker-compose.yml 中的 IP
echo "正在配置环境变量..."
sed -i "s|YOUR_PUBLIC_IP|$PUBLIC_IP|g" docker-compose.yml

# 创建后端必要的目录
echo "正在创建后端数据目录..."
mkdir -p ../contacts-backend/data
mkdir -p ../contacts-backend/uploads

# 初始化后端数据文件（如果不存在）
if [ ! -f "../contacts-backend/data/contacts.json" ]; then
    echo "[]" > ../contacts-backend/data/contacts.json
    echo "后端数据文件已创建"
fi

# 检查前端是否已构建
if [ ! -d "unpackage/dist/build/web" ]; then
    echo "警告: 前端未构建，正在尝试构建..."
    if [ -f "build-frontend.sh" ]; then
        chmod +x build-frontend.sh
        ./build-frontend.sh "http://$PUBLIC_IP:3000"
    else
        echo "请先使用 HBuilderX 构建 Web 版本"
        echo "构建产物应放在: unpackage/dist/build/web"
        read -p "是否继续部署？(y/n): " continue_deploy
        if [ "$continue_deploy" != "y" ] && [ "$continue_deploy" != "Y" ]; then
            echo "部署已取消"
            exit 1
        fi
    fi
fi

# 构建并启动容器
echo "正在构建 Docker 镜像..."
docker compose build

echo "正在启动服务..."
docker compose up -d

# 等待服务启动
echo "等待服务启动..."
sleep 5

# 检查服务状态
echo "=========================================="
echo "部署完成！"
echo "=========================================="
echo "前端访问地址: http://$PUBLIC_IP"
echo "后端 API 地址: http://$PUBLIC_IP:3000"
echo ""
echo "查看服务状态: docker compose ps"
echo "查看日志: docker compose logs -f"
echo "停止服务: docker compose down"
echo "=========================================="

