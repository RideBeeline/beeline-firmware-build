Docker environments for [Beeline](https://beeline.co) firmware builds

To build and push the pylib-linux (emulator build):
```
echo $CR_PAT | docker login ghcr.io -u <GH USERNAME> --password-stdin
```

## Local testing

Copy uv lock file
```
cp ../beeline-firmware-nrf/uv.lock .
```

On Mac, for a multi architecture build:


```
docker buildx create --use
docker buildx build --platform linux/arm64 --load --build-arg DESIRED_PYTHON_VERSION=$(cat requirements.python-version) -t bl-fw-local-pylib-emu -f ./pylib-emulator.dockerfile .
```
NB: can only use one platform at a time

Run it and mount the fw repo as smth like
```
docker run --rm -it -v "/Users/mark/Beeline/fw/beeline-firmware-nrf":/beeline -v venv:/beeline/.venv -w /beeline bl-fw-local-pylib-emu bash


export using
```
uv export --locked --no-hashes --package build-tools --no-dev 
```

or better, copy uv.lock and run 

COPY fw-uv.lock uv.lock
COPY fw-pyproject.toml pyproject.toml

ENV UV_PROJECT_ENVIRONMENT=/opt/venv

# Build env from lock
RUN uv sync --locked --package honeypy --no-dev

# Keep a copy for debugging / diff, but move it away from project root
RUN mv uv.lock uv.lock.built