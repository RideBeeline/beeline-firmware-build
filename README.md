Docker environments for [Beeline](https://beeline.co) firmware builds

## Python version locking

Run copy_requirements.sh to copy the locked python dependencies and python version for the beeline repo.

Ideally we would just use uv run but keep the venv folder persistent. We can do that for most platforms but not all, because 
the sdk15 runs on old ubunto with a gcc no longer supported by numpy. So for now we need to keep copying the buildpy requirements.

Assuming beeline-firmware-repo is next to current one:
```
./copy_requirements.sh ../beeline-firmware-nrf
```

## Mac multiarch
On Mac, for a multi architecture build you need to use buildx
NB: can only use one platform at a time if you do local builds

```
docker buildx create --use
docker buildx build --platform linux/arm64 --load --build-arg DESIRED_PYTHON_VERSION=$(cat requirements.python-version) -t bl-fw-local-pylib-emu -f ./pylib-emulator.dockerfile .
```

To run and load fw repo:
```
docker run --rm -it -v "/Users/mark/Beeline/fw/beeline-firmware-nrf":/beeline -v venv:/beeline/.venv -w /beeline bl-fw-local-pylib-emu bash
```

## CI and publish
The workflow will run on every push but will only upload to the registery on releases. So make a release in GH!

## Manually publish
```
docker buildx create --use
docker buildx build --platform linux/arm64,linux/amd64 --build-arg DESIRED_PYTHON_VERSION=$(cat requirements.python-version) --push -t ghcr.io/ridebeeline/bl-fw-test-emu:a1 -f ./pylib-emulator.dockerfile .
```