FROM node:22-alpine AS builder
RUN apk add --no-cache openssl ca-certificates
WORKDIR /app
RUN npm install -g pnpm@9.15.0 turbo
COPY . .
RUN turbo prune --scope=backend-api --docker

FROM node:22-alpine AS installer
RUN apk add --no-cache openssl ca-certificates
WORKDIR /app
RUN npm install -g pnpm@9.15.0
COPY --from=builder /app/out/json/ .
COPY --from=builder /app/out/pnpm-lock.yaml ./pnpm-lock.yaml
RUN pnpm install --frozen-lockfile

COPY --from=builder /app/out/full/ .
RUN cd packages/database && pnpm exec prisma generate || true
RUN pnpm turbo run build --filter=backend-api...

FROM node:22-alpine AS runner
RUN apk add --no-cache openssl ca-certificates
WORKDIR /app
RUN npm install -g pnpm@9.15.0
COPY --from=installer /app .
EXPOSE 4000
CMD ["pnpm", "--filter", "backend-api", "start:prod"]
