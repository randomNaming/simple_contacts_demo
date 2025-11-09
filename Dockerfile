FROM nginx:alpine

# 复制构建好的 Web 文件到 nginx
# 注意：需要先在本地或 CI 中构建 uni-app Web 版本
# 构建产物应该在 unpackage/dist/build/web 目录下
COPY unpackage/dist/build/web /usr/share/nginx/html/

# 如果没有构建产物，创建一个简单的提示页面
RUN if [ ! -f /usr/share/nginx/html/index.html ]; then \
      echo '<!DOCTYPE html><html><head><title>构建中</title></head><body><h1>请先构建前端项目</h1><p>使用 HBuilderX 构建 Web 版本，构建产物应在: unpackage/dist/build/web</p></body></html>' > /usr/share/nginx/html/index.html; \
    fi

# 复制 nginx 配置
COPY nginx.conf /etc/nginx/conf.d/default.conf

# 暴露端口
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
