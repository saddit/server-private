FROM node:22.17.0-slim@sha256:b2fa526a10dad3c5ab4b3779eca81607ed05a96160ef5497c36cd4ebed68803d AS base

WORKDIR /app

FROM base AS build

COPY . ./

RUN npm i -g corepack &&\
  corepack enable &&\
  corepack prepare --activate &&\
  npm pkg delete scripts.prepare &&\
  pnpm install --frozen-lockfile &&\
  pnpm run build &&\
  pnpm install --prod --frozen-lockfile


FROM base AS temp

COPY --from=build /app/node_modules /app/node_modules
COPY --from=build /app/dist /app/dist
COPY . ./

FROM gcr.io/distroless/nodejs22-debian12@sha256:fd90468f47e91d0d3c9bc055c8c09edbf0c225c3c795d0c266e2ca94b3ba17e3

WORKDIR /app

ENTRYPOINT ["/nodejs/bin/node", "--enable-source-maps"]

ENV NODE_ENV=production

COPY --from=temp /app/ /app/

ARG ARG_REF
ENV REF=$ARG_REF
