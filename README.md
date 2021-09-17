# archivebox-alpine-container

[Archivebox](https://github.com/ArchiveBox/ArchiveBox) in an Alpine OCI Container

# What is it

This is a minimal image, to be deployed with podman. As of this writing it is less than 50% of the size of official archivebox docker image.

# How to run

`podman run --rm -p 8000:8000/tcp --name=archivebox -v $(pwd)/downloads:/archivedir -v $(pwd)/chrome_data:/chrome_data --tz=local --entrypoint python3 /usr/app/archivebox/bin/archivebox init ghcr.io/40da63260/archivebox-alpine-container`
`podman run --rm -p 8000:8000/tcp --name=archivebox -v $(pwd)/downloads:/archivedir -v $(pwd)/chrome_data:/chrome_data --tz=local ghcr.io/40da63260/archivebox-alpine-container`

if you don't want to specify a chrome_data dir, -e CHROME_USER_DATA_DIR='' must be added.
