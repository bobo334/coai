# Author: ProgramZmh
# License: Apache-2.0
# Description: Optimized Dockerfile for chatnio

# Specify the platform directly if you are building for a specific architecture
# For ARM64, use FROM --platform=linux/arm64 golang:1.20-alpine AS backend
FROM --platform=linux/amd64 golang:1.20-alpine AS backend

WORKDIR /backend
COPY go.mod go.sum ./
RUN go mod download
COPY . .

# Set go proxy to https://goproxy.cn (open for vps in China Mainland)
# RUN go env -w GOPROXY=https://goproxy.cn,direct

# Install build dependencies and cross-compilation toolchain
RUN apk add --no-cache \
    gcc \
    musl-dev \
    g++ \
    make \
    linux-headers \
    && if [ "$TARGETARCH" = "arm64" ]; then \
    wget -q -O /tmp/cross.tgz https://musl.cc/aarch64-linux-musl-cross.tgz && \
    tar -xf /tmp/cross.tgz -C /usr/local && \
    rm /tmp/cross.tgz; \
    fi \
    && apk del gcc musl-dev g++ make linux-headers

# Build backend
RUN if [ "$TARGETARCH" = "arm64" ]; then \
    CC=/usr/local/aarch64-linux-musl-cross/bin/aarch64-linux-musl-gcc \
    CGO_ENABLED=1 \
    GOOS=linux \
    GOARCH=arm64 \
    go build -o chat -a -ldflags="-extldflags=-static" .; \
    else \
    go build -o chat -a -ldflags="-extldflags=-static" .; \
    fi

# For ARM64, use FROM --platform=linux/arm64 node:18-alpine AS frontend
FROM --platform=linux/amd64 node:18-alpine AS frontend

WORKDIR /app
COPY package.json pnpm-lock.yaml ./
RUN npm install -g pnpm && \
    pnpm install --prod
COPY . .

RUN pnpm run build && \
    rm -rf node_modules pnpm-lock.yaml package.json

FROM alpine:latest

# Install runtime dependencies
RUN apk add --no-cache \
    wget \
    ca-certificates \
    tzdata && \
    update-ca-certificates 2>/dev/null || true

# Set timezone
RUN echo "Asia/Shanghai" > /etc/timezone && \
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

WORKDIR /

# Copy built binaries and assets
COPY --from=backend /backend/chat /chat
COPY --from=backend /backend/config.example.yaml /config.example.yaml
COPY --from=backend /backend/utils/templates /utils/templates
COPY --from=backend /backend/addition/article/template.docx /addition/article/template.docx
COPY --from=frontend /app/dist /app/dist

# Volumes
VOLUME ["/config", "/logs", "/storage"]

# Expose port
EXPOSE 8094

# Run application
CMD ["./chat"]
