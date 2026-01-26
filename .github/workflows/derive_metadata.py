"""Parse dockerfile to derive Docker image tag and set GitHub Actions output.

This is used in CI - we scan the dockerfile for certain keywords and use that to determine the tag name.
"""

import argparse
import os
import sys
from pathlib import Path


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Derive Docker image tag from Dockerfile."
    )
    parser.add_argument(
        "--name", required=True, help="Matrix name used to select the Dockerfile."
    )
    parser.add_argument(
        "--ref-name", required=True, help="Git reference name (branch or tag)."
    )
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

    desired_python_version_file = dockerfile_path.parent / "requirements.python-version"
    desired_python_version = None
    with desired_python_version_file.open(encoding="utf-8") as vf:
        desired_python_version = vf.read().strip()

    assert desired_python_version is not None, (
        "Desired Python version could not be determined."
    )
    print(f"Derived python version: {desired_python_version}")

    if version == "use-desired-python-version":
        version = desired_python_version

    docker_tag = f"ghcr.io/ridebeeline/fw-build-{args.name}:{version}-{args.ref_name.replace('/', '_')}"
    print(f"Derived Docker tag: {docker_tag}")

    github_output = os.environ.get("GITHUB_OUTPUT")
    if not github_output:
        print("GITHUB_OUTPUT environment variable missing", file=sys.stderr)
        return 1

    with open(github_output, "a", encoding="utf-8") as output_file:
        output_file.write(f"docker_tag={docker_tag}\n")
        output_file.write(f"python_version={desired_python_version}\n")

    return 0


if __name__ == "__main__":
    sys.exit(main())
