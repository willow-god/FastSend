# 构建阶段
FROM node:20-alpine AS builder

WORKDIR /app

COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

COPY . .
RUN yarn build

# 生产阶段
FROM node:20-alpine

WORKDIR /app

# 从构建阶段复制构建后的文件
COPY --from=builder /app/.output /app

# 暴露端口
EXPOSE 3000

# 启动应用
CMD ["node", "server/index.mjs"]
