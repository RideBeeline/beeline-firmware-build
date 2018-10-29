# Development environment for beeline nrf51 firmware

This is a docker environment file that builds on top of the existing beeline/firmware-build image.

**It requires a local image called *beeline-firmware-img* to exist on the local system.**


# Build instructions

Go to the repo parent directory
```
cd beeline-firmware-build
```

Build the docker base image which is used for compilation. It will be called *beeline-firmware-img*.
```
docker build -t beeline-firmware-img beeline-firmware-build
```

Now build the development image. It will be called *beeline-firmware-dev*
```
docker build -t beeline-firmware-dev beeline-firmware-build/Development
```

# Usage

The Build image is designed to be re-run for every build command. This ensures that the environment is always the same. Use it with
```
docker run -it --rm beeline-firmware-img [COMMAND]
```

The Development image on the other hand can be run in *detached* mode. So it can be used as a persistent and interactive environment. Run it with
```
docker run -d --name beeline-dev -it beeline-firmware-dev
```
then you can attach a shell
```
docker exec -it beeline-dev bash
```
or run other commands (see examples)

# Examples

## Build or Test
For a build / clean / test make command run
```
docker run -v [AbsolutePathHere]\beeline-firmware-nrf:/beeline -w /beeline -it --rm beeline-firmware-img make test
```
This will run the build image, mount the files, change directory to the route source directory /beeline and execute *make test*
--rm makes sure the image is deleted when it completes.

Just remove *test* or replace it with *clean* for other make commands.

## GDB debugging
For debugging tests fire up the container using
```
docker run -d --name beeline-dev --security-opt seccomp:unconfined -v [AbsolutePathHere]\beeline-firmware-nrf:/beeline -w /beeline -it --rm beeline-firmware-dev
```
This will run the development image in a detached container, mount the files, change directory to the route source directory /beeline.

Now you can run gdb using
```
docker exec -it beeline-env sh -c "gdb /beeline/app/_build/tests"
```
or integrate an appropriate command into your IDE for convenient debugging.

## Build scripts

Other build scripts and tools like those dependent on nodejs can be run by using something like
```
docker exec beeline-env sh -c "cd /beeline/path/to/tools && npm install && ./main.js --commands"
```

or by attaching a bash shell like above.
