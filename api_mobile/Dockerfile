# https://hub.docker.com/_/dart/tags

FROM dart:3.4.3 AS build

ARG DEPLOY_USER_TOKEN

RUN git config --global url."https://${DEPLOY_USER_TOKEN}@gitlab.vega.com/".insteadOf git@gitlab.vega.com:

# Resolve app dependencies.
WORKDIR /app
COPY pubspec.* ./
COPY config.yaml ./
COPY langs/ ./langs/
COPY static/ ./static/
RUN dart pub get

# Copy app source code (except anything in .dockerignore) and AOT compile app.
COPY . .
RUN dart compile exe bin/main.dart -o bin/server

# Build minimal serving image from AOT-compiled `/server`
# and the pre-built AOT-runtime in the `/runtime/` directory of the base image.
FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /app/config.yaml /app/
COPY --from=build /app/bin/server /app/bin/
COPY --from=build /app/langs/ /app/langs/
COPY --from=build /app/static/ /app/static/

# Include files in the /public directory to enable static asset handling
# COPY --from=build /app/public/ /public

# Start server.
EXPOSE 8080
CMD ["/app/bin/server", "/app/config.yaml"]

# eof
