#!/usr/bin/env python3
"""Supply the local Fleet container's credential directly to an MCP client."""

import json
import subprocess
import sys


def main() -> int:
    check_only = sys.argv[1:] == ["--check"]
    if (sys.argv[1:] and not check_only) or (sys.stdout.isatty() and not check_only):
        print(
            "Use --check to verify availability without exposing credentials.",
            file=sys.stderr,
        )
        return 2
    template = '{{range .Config.Env}}{{if eq (index (split . "=") 0) "FLEET_MCP_TOKEN"}}{{.}}{{end}}{{end}}'
    try:
        result = subprocess.run(
            [
                "docker",
                "--host",
                "unix:///var/run/docker.sock",
                "inspect",
                "--format",
                template,
                "agent-fleet-renovation-control-plane-1",
            ],
            capture_output=True,
            text=True,
            timeout=5,
            check=True,
        )
    except (OSError, subprocess.SubprocessError):
        print("Cannot access the local Fleet MCP credential.", file=sys.stderr)
        return 1
    name, separator, token = result.stdout.strip().partition("=")
    if (
        name != "FLEET_MCP_TOKEN"
        or not separator
        or not 32 <= len(token.encode()) <= 512
    ):
        print(
            "The local Control Plane has no configured MCP credential.", file=sys.stderr
        )
        return 1
    if check_only:
        print("Local Fleet MCP credential is available; value withheld.")
    else:
        json.dump({"Authorization": "Bearer " + token}, sys.stdout)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
