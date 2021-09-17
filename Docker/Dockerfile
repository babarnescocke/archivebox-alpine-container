FROM alpine:3 AS buildercontainer

RUN apk add -q --no-cache --update npm git py3-pip build-base py3-virtualenv python3-dev
WORKDIR /usr/src/npm
#installing everything at once saves 15 megabytes - so it stays
RUN npm install --quiet --production "git+https://github.com/postlight/mercury-parser.git" "github:ArchiveBox/readability-extractor" "git+https://github.com/gildas-lormeau/SingleFile.git"
WORKDIR /usr/src/
RUN python3 -m venv .venv &&\
    .venv/bin/pip install -q --no-cache-dir -U pip wheel &&\
    .venv/bin/pip install -q --no-cache-dir -U archivebox &&\
    .venv/bin/pip uninstall -q --no-cache-dir -y youtube-dl &&\
    find /usr/src/.venv \( -type d -a -name test -o -name tests \) -o \( -type f -a -name '*.pyc' -o -name '*.pyo' \) -exec rm -rf '{}' \+

FROM alpine:3
RUN apk add -q --update --no-cache curl \
 python3 \
 chromium \
 wget \
 git \
 nodejs \
 ripgrep \
 youtube-dl  &&\
 apk del -q apk-tools --no-cache
WORKDIR /usr/app
RUN adduser archivebox -D
COPY --chown=archivebox --from=buildercontainer /usr/src/npm/ ./
COPY --chown=archivebox --from=buildercontainer /usr/src/.venv ./archivebox
USER archivebox
ENV PATH="/usr/app/archivebox/bin:$PATH"
ENV SINGLEFILE_BINARY=/usr/app/node_modules/single-file/cli/single-file
ENV MERCURY_BINARY=/usr/app/node_modules/@postlight/mercury-parser/cli.js
ENV READABILITY_BINARY=/usr/app/node_modules/readability-extractor/readability-extractor
ENV YOUTUBEDL_BINARY=/usr/bin/youtube-dl
ENV CHROME_USER_DATA_DIR=/chrome_data
VOLUME /chrome_data /archivedir
EXPOSE 8000/tcp
WORKDIR /archivedir
ENTRYPOINT python3 /usr/app/archivebox/bin/archivebox server 0.0.0.0:8000
