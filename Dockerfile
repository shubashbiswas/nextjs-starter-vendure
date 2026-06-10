FROM node:22-alpine AS builder

WORKDIR /usr/src/app
ARG VENDURE_SHOP_API_URL=http://placeholder.local
ARG NEXT_PUBLIC_SITE_URL=http://placeholder.local

ENV VENDURE_SHOP_API_URL=$VENDURE_SHOP_API_URL
ENV NEXT_PUBLIC_SITE_URL=$NEXT_PUBLIC_SITE_URL
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build
RUN npm prune --omit=dev

FROM node:22-alpine AS runtime

WORKDIR /usr/src/app
ENV NODE_ENV=production

COPY --from=builder /usr/src/app/package*.json ./
COPY --from=builder /usr/src/app/node_modules ./node_modules
COPY --from=builder /usr/src/app/next.config.ts ./
COPY --from=builder /usr/src/app/messages ./messages
COPY --from=builder /usr/src/app/public ./public
COPY --from=builder /usr/src/app/.next ./.next

CMD ["npm", "run", "start"]