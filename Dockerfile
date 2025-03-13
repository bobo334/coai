# 使用一个基础镜像，包含 Go 和 Node.js 环境
FROM golang:1.20-alpine AS backend

# 安装 Node.js 和 npm
RUN apk add --no-cache nodejs npm

# 设置工作目录
WORKDIR /app

# 复制后端代码
COPY . .

# 设置 Go 代理
ENV GOPROXY=https://goproxy.cn,direct
ENV GO111MODULE=on
ENV CGO_ENABLED=1

# 安装 Go 依赖并构建后端
RUN go mod download
RUN go build -o chat

# 安装 Node.js 依赖并构建前端
RUN npm install -g pnpm
RUN pnpm install
RUN pnpm run build

# 清理不必要的文件
RUN rm -rf /app/node_modules

# 设置时区
RUN apk add --no-cache tzdata
RUN echo "Asia/Shanghai" > /etc/timezone
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# 暴露端口
EXPOSE 8094

# 运行应用
CMD ["./chat"]
