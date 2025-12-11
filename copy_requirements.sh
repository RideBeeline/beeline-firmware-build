

: ${BEELINE_FIRMWARE_REPO:=../beeline-firmware-nrf}


cp ${BEELINE_FIRMWARE_REPO}/.python-version requirements.python-version

# these need to be run 
(cd ${BEELINE_FIRMWARE_REPO} && uv export --locked --no-hashes --package buildpy --no-emit-package buildpy --no-dev -o ../beeline-firmware-build/requirements-buildpy.txt)
(cd ${BEELINE_FIRMWARE_REPO} && uv export --locked --no-hashes --package honeypy --no-emit-package honeypy --no-dev -o ../beeline-firmware-build/requirements-honeypy.txt)