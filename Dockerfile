# Author: ProgramZmh
# License: Apache-2.0
# Description: Dockerfile for chatnio

# Specify the platform directly if you are building for a specific architecture
FROM --platform=linux/amd64 golang:1.20-alpine AS builder

WORKDIR /backend
COPY . .

# Set go proxy (uncomment if needed)
# RUN go env -w GOPROXY=https://goproxy.cn,direct

ARG TARGETARCH
ARG TARGETOS
ENV GOOS=$TARGETOS GOARCH=$TARGETARCH GO111MODULE=on CGO_ENABLED=1

# Install build dependencies and WebP development libraries
RUN apk add --no-cache \
    gcc \
    musl-dev \
    g++ \
    make \
    linux-headers \
    wget \
    tar \
    libwebp-dev

# Build backend
RUN go build -o chat -a -ldflags="-extldflags=-static" .

# Build frontend
FROM --platform=linux/amd64 node:18-alpine AS frontend

WORKDIR /app
COPY ./app .

RUN npm install -g pnpm && \
    pnpm install && \
    pnpm run build && \
    rm -rf node_modules src

# Final stage
FROM alpine:latest

# Install runtime dependencies
RUN apk add --no-cache \
    ca-certificates tzdata && \
    update-ca-certificates 2>/dev/null || true

# Set timezone
RUN echo "Asia/Shanghai" > /etc/timezone && \
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

WORKDIR /

# Copy built files
COPY --from=builder /backend/chat /chat
COPY --from=builder /backend/config.example.yaml /config.example.yaml
COPY --from=builder /backend/utils/templates /utils/templates
COPY --from=builder /backend/addition/article/template.docx /addition/article/template.docx
COPY --from=frontend /app/dist /app/dist

# Volumes
VOLUME ["/config", "/logs", "/storage"]

# Expose port
EXPOSE 8094

# Run application
CMD ["./chat"]
