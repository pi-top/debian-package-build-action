# pi-top Docker image for building pi-top Debian packages for Raspberry Pi

## How to use

### Enable experimental features on host machine
_(This only needs to be done once)_

```sh
echo -e "{\n  \"experimental\": true\n}" | sudo tee /etc/docker/daemon.json &> /dev/null
sudo service docker restart

```

### Start Docker container based on source code's architecture

The following snippet will use `amd64` for packages that do not require compilation, which will result in the fastest package building.
Packages that require compilation will be built in a container that is emulating ARM hardware (32 and 64 bit), which results in a slower build.
```sh
architectures=()
if [[ "$(grep "Architecture" debian/control | grep -v "all")" ]]; then
  # Requires hardware emulation
  docker run --privileged --rm docker/binfmt:a7996909642ee92942dcd6cff44b9b95f08dad64

  architectures+=("armhf")
  architectures+=("arm64")
else
  architectures+=("amd64")
fi

for architecture in ${architectures[@]}; do
  docker run --rm \
      --platform=${architecture} \
      --volume $(pwd):/src \
      pitop/deb-build:latest
done
```

## Featured Repositories

[pi-top Python SDK](https://github.com/pi-top/pi-top-Python-SDK)
