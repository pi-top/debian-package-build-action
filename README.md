# pi-top Debian packaging base Docker image

Instructions are taken from here:
https://docs.docker.com/docker-for-mac/multi-arch/

```sh
DOCKER_USER="pitop"
DOCKER_REPO="deb-build"
DOCKER_LABEL="latest"

# Set up builder
docker buildx create --name mybuilder --use
docker buildx inspect --bootstrap

tag="${DOCKER_USER}/${DOCKER_REPO}:${DOCKER_LABEL}"

# Build for multiple architectures and push to Registry
docker buildx build \
  --platform linux/amd64,linux/arm64,linux/arm/v7 \
  -t "${tag}" \
  --push .

# Check that there are multiple architectures for the build
docker buildx imagetools inspect "${tag}"
```
