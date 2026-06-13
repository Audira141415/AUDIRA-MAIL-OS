FROM node:22-alpine AS builder
WORKDIR /app
RUN npm install -g pnpm@9.15.0 turbo
COPY . .
RUN turbo prune --scope=ai-engine --docker

FROM node:22-alpine AS installer
WORKDIR /app
RUN npm install -g pnpm@9.15.0
COPY --from=builder /app/out/json/ .
COPY --from=builder /app/out/pnpm-lock.yaml ./pnpm-lock.yaml
RUN pnpm install --frozen-lockfile

COPY --from=builder /app/out/full/ .
RUN cd packages/database && pnpm exec prisma generate || true
RUN pnpm turbo run build --filter=ai-engine...

FROM node:22-alpine AS runner
WORKDIR /app
RUN npm install -g pnpm@9.15.0
COPY --from=installer /app .
EXPOSE 4002
CMD ["pnpm", "--filter", "ai-engine", "start"]
