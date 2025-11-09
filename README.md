# 联系人管理系统 - 前端

uni-app 前端应用，提供联系人管理的用户界面。

## 📋 功能特性

- ✅ 联系人列表展示
- ✅ 添加/编辑/删除联系人
- ✅ 头像上传
- ✅ 联系人置顶
- ✅ 响应式设计

## 🚀 快速开始

### 开发环境

1. **下载 HBuilderX**
   - 访问：https://www.dcloud.io/hbuilderx.html
   - 下载并安装 HBuilderX

2. **打开项目**
   ```
   文件 -> 打开目录 -> 选择 contacts-frontend 文件夹
   ```

3. **运行项目**
   ```
   运行 -> 运行到浏览器 -> Chrome
   ```

### 安装依赖

```bash
npm install
```

## 📦 HBuilderX 打包方式

### 打包步骤

1. **配置 API 地址**
   - 编辑 `utils/api.js`
   - 将 API 地址改为你的服务器地址：
   ```javascript
   const API_BASE_URL = 'http://你的公网IP:3000';
   ```

2. **发行 Web 版本**
   ```
   发行 -> 网站-H5 -> 发行
   ```
   
   或者：
   ```
   发行 -> 原生App-云打包 -> 选择 Web 平台 -> 打包
   ```

3. **构建产物位置**
   ```
   unpackage/dist/build/web/
   ```

### 打包注意事项

⚠️ **重要提示**：

1. **API 地址配置**: 打包前必须修改 `utils/api.js` 中的 API 地址
2. **构建产物路径**: 构建产物必须在 `unpackage/dist/build/web/` 目录
3. **重新打包**: 修改代码后需要重新打包

## 🐳 Docker 部署

### 前置准备

1. **克隆后端仓库**
   ```bash
   # 在项目根目录的上一级目录
   git clone <后端仓库地址> contacts-backend
   ```

2. **构建前端**
   - 使用 HBuilderX 打包前端（见上方"HBuilderX 打包方式"）
   - 确保构建产物在 `unpackage/dist/build/web/` 目录

### 一键部署

```bash
# 运行部署脚本
chmod +x deploy.sh
./deploy.sh
```

部署脚本会自动：
- ✅ 检查并安装 Docker 和 Docker Compose
- ✅ 获取服务器公网 IP
- ✅ 配置环境变量
- ✅ 检查前端构建产物
- ✅ 检查后端仓库
- ✅ 构建并启动 Docker 容器

### 手动部署

```bash
# 1. 配置公网 IP
sed -i 's/YOUR_PUBLIC_IP/你的公网IP/g' docker-compose.yml

# 2. 确保后端仓库在正确位置
# 后端仓库应该在 ../contacts-backend

# 3. 构建并启动
docker compose build
docker compose up -d
```

### 访问地址

部署完成后：
- **前端**: `http://你的公网IP`
- **后端 API**: `http://你的公网IP:3000`

## 📁 项目结构

```
contacts-frontend/
├── pages/                  # 页面文件
│   ├── index/             # 首页（联系人列表）
│   └── add/               # 添加联系人页面
├── utils/                  # 工具函数
│   └── api.js             # API 配置
├── static/                 # 静态资源
├── unpackage/              # 构建产物目录
│   └── dist/
│       └── build/
│           └── web/       # Web 构建产物
├── Dockerfile              # Docker 构建配置
├── nginx.conf              # Nginx 配置
├── docker-compose.yml      # Docker Compose 配置
├── deploy.sh               # 一键部署脚本
└── manifest.json           # uni-app 配置
```

## 🔧 开发说明

### API 配置

API 地址配置在 `utils/api.js` 文件中：

```javascript
const API_BASE_URL = process.env.VUE_APP_API_BASE_URL || 
  (typeof window !== 'undefined' ? window.location.origin : 'http://localhost:3000');
```

### 环境变量

- `VUE_APP_API_BASE_URL`: API 基础 URL（构建时配置）

## 🛠️ 常用命令

### Docker 管理

```bash
# 查看服务状态
docker compose ps

# 查看日志
docker compose logs -f
docker compose logs backend
docker compose logs frontend

# 停止服务
docker compose down

# 重启服务
docker compose restart

# 重新构建并启动
docker compose down
docker compose build --no-cache
docker compose up -d
```

## ❓ 常见问题

### 1. 前端无法访问后端 API

**问题**: 浏览器控制台显示 `ERR_CONNECTION_REFUSED`

**解决**:
- 检查 `utils/api.js` 中的 API 地址是否正确
- 确保使用服务器的公网 IP，不是 `localhost`
- 重新打包前端并重新部署

### 2. 前端页面空白

**问题**: 访问前端页面显示空白

**解决**:
- 检查构建产物是否存在：`ls unpackage/dist/build/web`
- 如果没有构建产物，使用 HBuilderX 重新打包
- 检查 Docker 容器日志：`docker compose logs frontend`

### 3. Docker 构建失败

**问题**: `COPY unpackage/dist/build/web` 失败

**解决**:
- 确保已使用 HBuilderX 打包前端
- 检查 `.dockerignore` 是否忽略了 `unpackage` 目录
- 验证构建产物路径：`unpackage/dist/build/web`

## 🔗 相关项目

- [后端项目](../contacts-backend) - Node.js 后端服务

