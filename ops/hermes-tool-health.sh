#!/bin/bash
# hermes-tool-health.sh — read-only Hermes tooling preflight check
# Exits 0 if core tools present; exits 1 only on fatal missing dependencies.
# Does NOT print env values, tokens, keys, or secrets.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

PASS=0
WARN=0
FAIL=0

report() {
  local status="$1"
  local msg="$2"
  if [[ "$status" == "PASS" ]]; then
    echo "[PASS] $msg"
    PASS=$((PASS+1))
  elif [[ "$status" == "WARN" ]]; then
    echo "[WARN] $msg"
    WARN=$((WARN+1))
  else
    echo "[FAIL] $msg"
    FAIL=$((FAIL+1))
  fi
}

section() {
  echo ""
  echo "=== $* ==="
}

# ── Core runtime ──────────────────────────────────────────────────────────────
section "Core Runtime"
if command -v hermes &>/dev/null; then
  report PASS "hermes in PATH"
else
  report FAIL "hermes not found in PATH — install or add to PATH"
fi

if command -v python3 &>/dev/null; then
  report PASS "python3 in PATH: $(python3 -c 'import sys; print(sys.version.split()[0])')"
else
  report FAIL "python3 not found"
fi

# ── Model providers ────────────────────────────────────────────────────────────
section "Model Providers"

if [[ -n "${MINIMAX_API_KEY:-}" ]]; then
  report PASS "MINIMAX_API_KEY is set"
elif [[ -f ~/.hermes/.env ]] && grep -q "MINIMAX_API_KEY" ~/.hermes/.env 2>/dev/null; then
  report PASS "MINIMAX_API_KEY configured in ~/.hermes/.env"
else
  report WARN "MINIMAX_API_KEY not found — MiniMax calls will fail"
fi

# ── Development tools ─────────────────────────────────────────────────────────
section "Development Tools"

if command -v aider &>/dev/null; then
  report PASS "aider in PATH: $(aider --version 2>/dev/null | head -1 || echo 'unknown version')"
else
  report WARN "aider not found — optional; prefer isolated install: pipx install aider-chat"
fi

if command -v playwright &>/dev/null; then
  PLAYWRIGHT_VER=$(playwright --version 2>/dev/null || echo "unknown")
  report PASS "playwright in PATH: $PLAYWRIGHT_VER"
else
  report WARN "playwright not found — optional; install only in the target project/runtime"
fi

# ── Sandbox / environments ────────────────────────────────────────────────────
section "Sandbox / Execution Environments"

for tool in python3 node npm docker ssh; do
  if command -v "$tool" &>/dev/null; then
    report PASS "$tool in PATH"
  else
    report WARN "$tool not in PATH — some environment backends may not work"
  fi
done

# ── Observability ────────────────────────────────────────────────────────────
section "Observability"

LOGDIR="$HOME/.hermes/logs"
if [[ -d "$LOGDIR" ]]; then
  report PASS "Hermes log directory exists: $LOGDIR"
  if [[ -f "$LOGDIR/agent.log" ]]; then
    report PASS "agent.log present"
  else
    report WARN "agent.log not found"
  fi
else
  report WARN "Hermes log directory not found — logs may not be persisting"
fi

# ── Skills ────────────────────────────────────────────────────────────────────
section "In-Repo Skills"

SKILL_DIRS=(
  "skills/software-development/safe-code-worker-aider"
  "skills/dogfood/browser-qa-playwright"
  "skills/marketing/funnel-cro-review"
  "skills/marketing/lifecycle-marketing-klaviyo"
  "skills/devops/release-manager"
)

for skill in "${SKILL_DIRS[@]}"; do
  FULL="$REPO_ROOT/$skill/SKILL.md"
  if [[ -f "$FULL" ]]; then
    report PASS "$skill/SKILL.md present"
  else
    report WARN "$skill/SKILL.md missing"
  fi
done

# ── Memory / context engines ──────────────────────────────────────────────────
section "Memory / Context Engines"

for svc in honcho mem0 zep graphiti; do
  VAR="$(echo "${svc}_API_KEY" | tr '[:lower:]' '[:upper:]')"
  if [[ -n "${!VAR:-}" ]]; then
    report PASS "$svc configured (${VAR} set)"
  elif [[ -f ~/.hermes/.env ]] && grep -q "${VAR}" ~/.hermes/.env 2>/dev/null; then
    report PASS "$svc configured in ~/.hermes/.env"
  else
    report WARN "$svc not configured — using in-memory session only"
  fi
done

# ── Scheduler ────────────────────────────────────────────────────────────────
section "Scheduler"

if [[ -d "$REPO_ROOT/cron" ]]; then
  report PASS "cron/ directory present"
else
  report WARN "cron/ directory not found"
fi

if command -v trigger &>/dev/null; then
  report PASS "trigger CLI present"
else
  report WARN "trigger (Trigger.dev) not in PATH"
fi

if command -v temporal &>/dev/null; then
  report PASS "temporal CLI present"
else
  report WARN "temporal CLI not in PATH"
fi

# ── Summary ───────────────────────────────────────────────────────────────────
section "Summary"
echo ""
echo "Results: $PASS passed, $WARN warnings, $FAIL failures"

if [[ $FAIL -gt 0 ]]; then
  echo "FATAL: Missing required tool(s). Fix [FAIL] items before proceeding."
  exit 1
else
  echo "OK: Core tooling present. Some optional tools missing — see [WARN] items."
  exit 0
fi
