FROM node:20-alpine AS builder

WORKDIR /app

# Install pnpm
RUN corepack enable && corepack prepare pnpm@latest --activate

# Copy root configurations
COPY package.json pnpm-workspace.yaml turbo.json ./
COPY packages ./packages
COPY apps/backend-api ./apps/backend-api

# Install dependencies
RUN pnpm install --frozen-lockfile

# Build the app
RUN pnpm --filter backend-api build

FROM node:20-alpine AS runner
WORKDIR /app
COPY --from=builder /app/apps/backend-api/dist ./dist
COPY --from=builder /app/node_modules ./node_modules

EXPOSE 3000
CMD ["node", "dist/main.js"]
