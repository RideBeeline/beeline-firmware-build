Docker environments for [Beeline](https://beeline.co) firmware builds

To build and push the pylib-linux (emulator build):
```
echo $CR_PAT | docker login ghcr.io -u <GH USERNAME> --password-stdin
```

## Local testing

On Mac, for a multi architecture build:


```
docker buildx create --use
docker buildx build --platform linux/arm64 --load -t bl-fw-local-pylib-emu -f ./pylib-emulator.dockerfile .
```
NB: can only use one platform at a time