"""Parse dockerfile to derive Docker image tag and set GitHub Actions output."""

import argparse
import os
import sys
from pathlib import Path


def main() -> int:
    parser = argparse.ArgumentParser(description="Derive Docker image tag from Dockerfile.")
    parser.add_argument("--name", required=True, help="Matrix name used to select the Dockerfile.")
    parser.add_argument("--ref-name", required=True, help="Git reference name (branch or tag).")
    parser.add_argument("--dockerfile", help="Optional explicit Dockerfile path.")
    args = parser.parse_args()

    dockerfile_path = Path(args.dockerfile or f"{args.name}.dockerfile")

    version = None
    with dockerfile_path.open(encoding="utf-8") as f:
        for raw_line in f:
            line = raw_line.strip()
            if line.startswith("ARG TOOLCHAIN_VERSION="):
                version = line.split("=", 1)[1].strip()
                break

    if not version:
        print(f"TOOLCHAIN_VERSION ARG missing in {dockerfile_path}", file=sys.stderr)
        return 1
    
    if version == "DESIRED_PYTHON_VERSION":
        # read from the requirements.python-version file from the same directory as the Dockerfile
        version_file = dockerfile_path.parent / "requirements.python-version"
        with version_file.open(encoding="utf-8") as vf:
            version = vf.read().strip()
        

    docker_tag = f"ghcr.io/ridebeeline/fw-build-{args.name}:{version}-{args.ref_name.replace('/', '_')}"
    print(f"Derived Docker tag: {docker_tag}")

    github_output = os.environ.get("GITHUB_OUTPUT")
    if not github_output:
        print("GITHUB_OUTPUT environment variable missing", file=sys.stderr)
        return 1

    with open(github_output, "a", encoding="utf-8") as output_file:
        output_file.write(f"docker_tag={docker_tag}\n")

    return 0


if __name__ == "__main__":
    sys.exit(main())