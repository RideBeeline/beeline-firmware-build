Docker environments for [Beeline](https://beeline.co) firmware builds

To build and push the pylib-linux (emulator build):
```
echo $CR_PAT | docker login ghcr.io -u <GH USERNAME> --password-stdin
cd 
docker build -t ghcr.io/ridebeeline/fw-pylib-emulator:py313 .
docker push -t ghcr.io/ridebeeline/fw-pylib-emulator:py313
```

On Mac, for a multi architecture build:
```
docker buildx create --use
docker buildx build --platform linux/amd64,linux/arm64 -t ghcr.io/ridebeeline/fw-pylib-emulator:py313 --push .
```

```
cd ncs
docker buildx build --platform linux/amd64,linux/arm64 -t ghcr.io/ridebeeline/ncs-build:v3.1.1.a --push .