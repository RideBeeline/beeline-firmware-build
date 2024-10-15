Docker environments for [Beeline](https://beeline.co) firmware builds

To build and push the emulator build:
```
echo $CR_PAT | docker login ghcr.io -u <GH USERNAME> --password-stdin
cd emulator
docker build -t ghcr.io/ridebeeline/fw-emulator-build:py310 .
docker push ghcr.io/ridebeeline/fw-emulator-build:py310
```

On Mac, for a multi architecture build:
```
docker buildx create --use
docker buildx build --platform linux/amd64,linux/arm64 -t ghcr.io/ridebeeline/fw-emulator-build:py310 --push .
```
