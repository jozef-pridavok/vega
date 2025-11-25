FROM dart:3.4.3 AS build

ARG DEPLOY_USER_TOKEN

RUN git config --global url."https://${DEPLOY_USER_TOKEN}@gitlab.vega.com/".insteadOf git@gitlab.vega.com:

# Resolve app dependencies.
WORKDIR /app
COPY pubspec.* ./
COPY config.yaml ./
RUN dart pub get

# Copy app source code (except anything in .dockerignore) and AOT compile app.
COPY . .
RUN dart compile exe bin/main.dart -o bin/server

# Build minimal serving image from AOT-compiled `/server`
# and the pre-built AOT-runtime in the `/runtime/` directory of the base image.
FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /app/config.yaml /app/
COPY --from=build /app/apn_api_key.p8 /app/
COPY --from=build /app/bin/server /app/bin/
COPY --from=build /app/langs/ /app/langs/
COPY --from=build /app/static/ /app/static/

# Start server.
EXPOSE 8080

CMD ["/app/bin/server", "/app/config.yaml"]

# eof
