# Connection diagnostics

The skill guides judgment; the host supplies the MCP connection and tool
permissions. Diagnose these separately from Fleet's server-side delegation.

- **No Fleet tools discovered:** check the host's configured server entry. A
  newly installed skill does not register MCP. A running session may need to be
  reopened after the server entry is added. Do not fall back to human REST APIs.
- **Client approval denied:** the call may never have reached Fleet. Report the
  host policy failure; do not treat it as an empty queue or reduce its safeguards.
  Fleet's query tools should advertise `readOnlyHint: true`.
  `resolve_approval` is a write and must retain the host's approval requirements.
- **401:** the credential is missing/invalid or the server grant expired. Report
  this to the operator. Never print credentials or extend the grant yourself.
- **Resource outside delegation:** do not search through another identity.
- **Empty allowed decisions:** the connection works, but this request is not
  delegated to this session. Leave it with its existing decision owner.
- **Write tool without taskActions:** write tools are registered only for actions
  listed in `taskActions`. A host that still shows a write tool does not by
  itself authorize it. Read `fleet_overview` and treat an absent or empty
  `delegation.taskActions` as no write.
- **Queued command:** inspect the current approval again. A disconnected or old
  node can leave delivery pending; do not call that provider completion.

## This server's local Codex and Claude Code installation

The installed `fleet` entries in Codex and Claude Code point to the renovation
Control Plane at `http://127.0.0.1:18082/mcp`. This address works on the Fleet
server itself. A session on another machine needs its own operator-configured
route and credential; localhost is not a remote hostname.

`codex mcp get fleet` and `claude mcp get fleet` show the local entries. Codex's
`http_headers_helper` and Claude's `headersHelper` read the renovation Control
Plane's dedicated MCP token and pass it directly to the client. Client
configuration contains no token literal. The bundled diagnostic helper reads
the same container through `unix:///var/run/docker.sock`. Verify availability
without revealing the token:

```bash
#!/usr/bin/env bash
set -euo pipefail
python3 "${HOME}/dotfiles/config/claude/skills/fleet-approvals/scripts/local-mcp-headers.py" --check
```

Never invoke that helper without `--check` in a shell tool: its normal stdout is
an authentication header intended only for the MCP client's private pipe. It
requires Docker access to the local Control Plane container. This helper is
specific to this local deployment, not a prerequisite for Fleet MCP generally.

Read the effective scope and expiry with `fleet_overview`; do not assume a
previous session's grant still applies. Do not register servers, change client
policy, or change delegation merely because the skill was invoked. Setup and
deployment require a separate user request.
