#!/bin/sh
build0=$(buildah from alpine:3)
build1=$(buildah from alpine:3)
mounter0=$(buildah mount "$build0")
mounter1=$(buildah mount "$build1")
buildah run "$build0" sh -c 'apk add --no-cache -q --update npm \
  git \
  py3-pip \
  build-base \
  py3-virtualenv \
  python3-dev &&\
  mkdir -p /usr/src/npm/ &&\
  cd /usr/src/npm &&\
  npm install --silent --production "git+https://github.com/postlight/mercury-parser.git" "github:ArchiveBox/readability-extractor" "git+https://github.com/gildas-lormeau/SingleFile.git" &&\
  cd /usr/src/ &&\
  python3 -m venv .venv &&\
  .venv/bin/pip install -q --no-cache-dir -U pip wheel &&\
  .venv/bin/pip install -q --no-cache-dir -U archivebox &&\
  .venv/bin/pip uninstall -q --no-cache-dir -y youtube-dl'
buildah run "$build0" sh -c "find /usr/src/.venv \( -type d -a -name test -o -name tests \) -o \( -type f -a -name '*.pyc' -o -name '*.pyo' \) -exec rm -rf '{}' \+"

buildah run "$build1" sh -c 'apk add --no-cache -q --update curl \
  python3 \
  chromium \
  wget \
  git \
  nodejs \
  ripgrep \
  youtube-dl &&\
  apk del -q --no-cache apk-tools &&\
  mkdir -p /usr/app \
  /archivedir \
  /chrome_data &&\
  adduser archivebox -D &&\
  chown -R archivebox /archivedir'
cp -r "$mounter0"/usr/src/npm "$mounter1"/usr/app
cp -r "$mounter0"/usr/src/.venv "$mounter1"/usr/app/archivebox/
buildah config --entrypoint '["python3", "/usr/app/archivebox/bin/archivebox", "server", "0.0.0.0:8000"]' \
  --env PATH="/usr/app/archivebox/bin:$PATH" \
  --env SINGLEFILE_BINARY=/usr/app/node_modules/single-file/cli/single-file \
  --env MERCURY_BINARY=/usr/app/node_modules/@postlight/mercury-parser/cli.js \
  --env READABILITY_BINARY=/usr/app/node_modules/readability-extractor/readability-extractor \
  --env YOUTUBEDL_BINARY=/usr/bin/youtube-dl \
  --env CHROME_USER_DATA_DIR=/chrome_data \
  --workingdir /archivedir \
  --user archivebox \
  --port 8000 \
  --volume /chrome_data \
  --volume /archivedir "$build1"
buildah unmount "$mounter0"
buildah unmount "$mounter1"
buildah rm "$build0"
buildah commit  --rm "$build1" archivebox-alpine-container
