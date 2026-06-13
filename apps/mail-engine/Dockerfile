FROM node:22-alpine AS builder
WORKDIR /app
RUN npm install -g pnpm@9.15.0 turbo
COPY . .
RUN turbo prune --scope=mail-engine --docker

FROM node:22-alpine AS installer
WORKDIR /app
RUN npm install -g pnpm@9.15.0
COPY --from=builder /app/out/json/ .
COPY --from=builder /app/out/pnpm-lock.yaml ./pnpm-lock.yaml
RUN pnpm install --frozen-lockfile

COPY --from=builder /app/out/full/ .
RUN cd packages/database && pnpm exec prisma generate || true
RUN pnpm turbo run build --filter=mail-engine...

FROM node:22-alpine AS runner
WORKDIR /app
RUN npm install -g pnpm@9.15.0
COPY --from=installer /app .
EXPOSE 3001
CMD ["pnpm", "--filter", "mail-engine", "start"]
