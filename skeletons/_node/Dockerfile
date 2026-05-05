FROM node:25-alpine AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

RUN npm install -g pnpm@latest

FROM base AS builder
WORKDIR /app
COPY pnpm-lock.yaml ./
RUN pnpm fetch --prod

COPY package.json ./
RUN pnpm install --prod --offline

# CONFIGURATION NOTE: If your project requires a build step (e.g., TypeScript),
# 1. Remove the '--prod' flag from 'pnpm fetch' and 'pnpm install' above to include devDependencies.
# 2. Add 'COPY . .' here.
# 3. Add 'RUN pnpm run build' here.

FROM base
WORKDIR /app
ENV NODE_ENV=production
COPY --from=builder /app/node_modules ./node_modules
COPY src/ ./src/

# CONFIGURATION NOTE: If you added a build step above:
# 1. Change 'COPY src/ ./src/' to 'COPY --from=builder /app/dist ./dist'.
# 2. Change the CMD below to 'node dist/index.js'.

USER node
CMD [ "node", "src/index.js" ]
