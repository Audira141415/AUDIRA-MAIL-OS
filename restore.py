import os

apps = {
    'backend-api': (4000, 'start:prod'),
    'mail-engine': (3001, 'start'),
    'ai-engine': (4002, 'start'),
    'worker-engine': (4003, 'start'),
    'notification-engine': (4004, 'start'),
    'frontend-web': (3310, 'start')
}

template = """FROM node:22-alpine AS builder
WORKDIR /app
RUN npm install -g pnpm@8.15.0 turbo
COPY . .
RUN turbo prune --scope={app} --docker

FROM node:22-alpine AS installer
WORKDIR /app
RUN npm install -g pnpm@8.15.0
COPY --from=builder /app/out/json/ .
COPY --from=builder /app/out/pnpm-lock.yaml ./pnpm-lock.yaml
RUN pnpm install --frozen-lockfile

COPY --from=builder /app/out/full/ .
RUN cd packages/database && pnpm exec prisma generate || true
RUN pnpm turbo run build --filter={app}...

FROM node:22-alpine AS runner
WORKDIR /app
RUN npm install -g pnpm@8.15.0
COPY --from=installer /app .
EXPOSE {port}
CMD ["pnpm", "--filter", "{app}", "{cmd}"]
"""

for app, info in apps.items():
    port, cmd = info
    os.makedirs(f'apps/{app}', exist_ok=True)
    with open(f'apps/{app}/Dockerfile', 'w') as f:
        f.write(template.format(app=app, port=port, cmd=cmd))

print("Dockerfiles restored and updated with pnpm@8.15.0")
