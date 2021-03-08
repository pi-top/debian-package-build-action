# pi-top Docker image for building pi-top Debian packages

## Featured Repositories

[pi-top Python SDK](https://github.com/pi-top/pi-top-Python-SDK)

## How to use
Enable experimental features:
```sh
echo -e "{\n  \"experimental\": true\n}" | sudo tee /etc/docker/daemon.json &> /dev/null
sudo service docker restart

```

Enable architecture emulation:
```sh
docker run --privileged --rm docker/binfmt:a7996909642ee92942dcd6cff44b9b95f08dad64
```

Build:
```sh
docker run --rm \
    --platform=armhf \
    --volume /tmp:/src \
    pitop/deb-build:latest
```