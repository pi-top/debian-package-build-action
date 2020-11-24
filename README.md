# pi-top Docker image for building Debian packages such as the [Python SDK](https://github.com/pi-top/pi-top-Python-SDK)

Instructions are taken from [here](https://docs.docker.com/docker-for-mac/multi-arch/).

### How to build and push to Docker Hub
```sh
# Set up builder (one time)
docker buildx create --name mybuilder --use
docker buildx inspect --bootstrap

# Define tag to use
tag="pitop/deb-build:latest"

# Build for multiple architectures and push to Registry
docker buildx build \
  --platform linux/amd64,linux/arm64,linux/arm/v7 \
  -t "${tag}" \
  --push .

# Check that there are multiple architectures for the build (optional)
docker buildx imagetools inspect "${tag}"
```
