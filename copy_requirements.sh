

: ${BEELINE_FIRMWARE_REPO:=../beeline-firmware-nrf}


cp ${BEELINE_FIRMWARE_REPO}/.python-version requirements.python-version


(cd ${BEELINE_FIRMWARE_REPO} && uv export --locked --no-hashes --package honeypy --no-emit-package honeypy --no-dev -o ../beeline-firmware-build/requirements-honeypy.txt)