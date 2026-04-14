### Frontend (Next.js) Dockerfile
#
# - Multi-stage build (deps -> build -> runtime)
# - Runs as non-root
# - Minimal runtime image

FROM node:20-alpine AS base
RUN apk upgrade --no-cache
WORKDIR /app
ENV NODE_ENV=production

FROM base AS deps
ENV NODE_ENV=development
RUN apk add --no-cache libc6-compat
COPY frontend/package.json frontend/package-lock.json* ./
RUN if [ -f package-lock.json ]; then npm ci; else npm install; fi

FROM base AS builder
ENV NODE_ENV=production
COPY --from=deps /app/node_modules ./node_modules
COPY frontend/ ./
RUN npm run build
RUN npm prune --omit=dev

FROM base AS runtime
RUN addgroup -S nextjs && adduser -S nextjs -G nextjs
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/next.config.js ./next.config.js

USER nextjs
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD wget -qO- http://127.0.0.1:3000/ >/dev/null 2>&1 || exit 1

CMD ["npm", "run", "start", "--", "-p", "3000"]

FROM deps AS dev
ENV NODE_ENV=development
COPY frontend/ ./
EXPOSE 3000
CMD ["npm", "run", "dev", "--", "-p", "3000", "--hostname", "0.0.0.0"]
