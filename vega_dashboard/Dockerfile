#
# Stage 1 - Build flutter app
#

FROM ghcr.io/cirruslabs/flutter:3.22.2 as build-env

ARG DEPLOY_USER_TOKEN
ARG FLUTTER_ARGS
ARG FLAVOR
ARG VERSION_NAME
ARG CI_PIPELINE_ID

RUN git config --global url."https://${DEPLOY_USER_TOKEN}@gitlab.vega.com/".insteadOf git@gitlab.vega.com:

# Copy the app files to the container
COPY . /usr/local/bin/app

# Set the working directory to the app files within the container
WORKDIR /usr/local/bin/app

RUN flutter pub get
#RUN sed -i "s/version: 1.0.0+1/version: $VERSION_NAME.0+$CI_PIPELINE_ID/g" pubspec.yaml
RUN flutter build web -t $FLUTTER_ARGS --build-name $VERSION_NAME --build-number $CI_PIPELINE_ID
#RUN sed -i "s/serviceWorkerVersion = null/serviceWorkerVersion = $CI_PIPELINE_ID/g" /usr/local/bin/app/build/web/index.html
#RUN sed -i "s/var flavor = null;/const flavor = '$FLAVOR';/g" /usr/local/bin/app/build/web/firebase-messaging-config.js

#
# Stage 2 - Create the run-time image
#

FROM nginx
COPY --from=build-env /usr/local/bin/app/build/web /usr/share/nginx/html

# eof
