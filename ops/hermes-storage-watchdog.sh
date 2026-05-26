#!/bin/bash
# hermes-storage-watchdog.sh — read-only Hermes storage watchdog
# Checks disk free space, HD mount presence, Docker VM symlink,
# Docker engine basics, and Hermes temp-write health.
# Does NOT print secrets, do cleanup, or schedule cron.

set -euo pipefail

# ── Configurable thresholds (env var overrides) ───────────────────────────────
HERMES_INTERNAL_MIN_GiB="${HERMES_INTERNAL_MIN_GiB:-30}"
HERMES_HD_MIN_GiB="${HERMES_HD_MIN_GiB:-40}"
HERMES_HD_MOUNT="${HERMES_HD_MOUNT:-/Volumes/HermesHD}"
DOCKER_VM_SYMLINK="${DOCKER_VM_SYMLINK:-/Users/bailey/Library/Containers/com.docker.docker/Data/vms}"
DOCKER_VM_TARGET="${DOCKER_VM_TARGET:-/Volumes/HermesHD/app-data/Docker/vms}"
HERMES_TEMP_DIR="${HERMES_TEMP_DIR:-$HOME/.hermes}"

# ── Counters ────────────────────────────────────────────────────────────────
PASS=0
WARN=0
FAIL=0

# ── Helpers ────────────────────────────────────────────────────────────────
report() {
  local status="$1"
  local msg="$2"
  case "$status" in
    PASS) echo "[PASS] $msg"; PASS=$((PASS+1)) ;;
    WARN) echo "[WARN] $msg"; WARN=$((WARN+1)) ;;
    FAIL) echo "[FAIL] $msg"; FAIL=$((FAIL+1)) ;;
  esac
}

section() {
  echo ""
  echo "=== $* ==="
}

gib_to_bytes() {
  echo $(( $1 * 1024 * 1024 * 1024 ))
}

# ── Internal disk ──────────────────────────────────────────────────────────
section "Internal Disk"
ROOT_FREE=$(df -k / 2>/dev/null | awk 'NR==2 {print $4}')
if [[ -n "$ROOT_FREE" ]]; then
  ROOT_FREE_GiB=$(( ROOT_FREE / 1024 / 1024 ))
  MIN_BYTES=$(gib_to_bytes "$HERMES_INTERNAL_MIN_GiB")
  if [[ $(( ROOT_FREE * 1024 )) -ge $MIN_BYTES ]]; then
    report PASS "Internal disk: ${ROOT_FREE_GiB}GiB free (min: ${HERMES_INTERNAL_MIN_GiB}GiB)"
  else
    report FAIL "Internal disk: ${ROOT_FREE_GiB}GiB free — below minimum ${HERMES_INTERNAL_MIN_GiB}GiB"
  fi
else
  report FAIL "Internal disk: cannot determine free space"
fi

# ── HermesHD mount ─────────────────────────────────────────────────────────
section "HermesHD Mount"

if mount | grep -q "on $HERMES_HD_MOUNT "; then
  report PASS "$HERMES_HD_MOUNT is mounted"
else
  report FAIL "$HERMES_HD_MOUNT is not mounted"
fi

if [[ -d "$HERMES_HD_MOUNT" ]]; then
  HERMESHD_FREE_K=$(df -k "$HERMES_HD_MOUNT" 2>/dev/null | awk 'NR==2 {print $4}')
  if [[ -n "$HERMESHD_FREE_K" ]]; then
    HERMESHD_FREE_B=$(( HERMESHD_FREE_K * 1024 ))
    HERMESHD_FREE_GiB=$(( HERMESHD_FREE_K / 1024 / 1024 ))
    MIN_BYTES=$(gib_to_bytes "$HERMES_HD_MIN_GiB")
    if [[ $HERMESHD_FREE_B -ge $MIN_BYTES ]]; then
      report PASS "HermesHD free space: ${HERMESHD_FREE_GiB}GiB free (min: ${HERMES_HD_MIN_GiB}GiB)"
    else
      report FAIL "HermesHD free space: ${HERMESHD_FREE_GiB}GiB free — below minimum ${HERMES_HD_MIN_GiB}GiB"
    fi
  else
    report FAIL "HermesHD: cannot determine free space"
  fi
else
  report FAIL "HermesHD: $HERMES_HD_MOUNT is not accessible"
fi

# ── Docker VM symlink ──────────────────────────────────────────────────────
section "Docker VM Symlink"

if [[ -L "$DOCKER_VM_SYMLINK" ]]; then
  SYMLINK_TARGET=$(readlink "$DOCKER_VM_SYMLINK" 2>/dev/null || echo "")
  if [[ "$SYMLINK_TARGET" == "$DOCKER_VM_TARGET" ]]; then
    report PASS "Docker VM symlink: $DOCKER_VM_SYMLINK -> $SYMLINK_TARGET"
  else
    report FAIL "Docker VM symlink: $DOCKER_VM_SYMLINK -> $SYMLINK_TARGET (expected: $DOCKER_VM_TARGET)"
  fi
elif [[ -e "$DOCKER_VM_SYMLINK" ]]; then
  report FAIL "Docker VM path exists but is not a symlink: $DOCKER_VM_SYMLINK"
else
  report FAIL "Docker VM symlink not found: $DOCKER_VM_SYMLINK"
fi

# ── Docker engine ──────────────────────────────────────────────────────────
section "Docker Engine"

if command -v docker &>/dev/null; then
  if docker info &>/dev/null; then
    DOCKER_VERSION=$(docker version --format '{{.Server.Version}}' 2>/dev/null || echo "unknown")
    DOCKER_CONTEXT=$(docker context show 2>/dev/null || echo "default")
    report PASS "Docker engine: running, version $DOCKER_VERSION, context: $DOCKER_CONTEXT"
  else
    report WARN "Docker CLI present but engine not reachable"
  fi
else
  report WARN "docker CLI not in PATH"
fi

# ── Hermes temp write ──────────────────────────────────────────────────────
section "Hermes Temp Write"

if [[ ! -d "$HERMES_TEMP_DIR" ]]; then
  report FAIL "Hermes temp dir not found: $HERMES_TEMP_DIR"
else
  TEMP_TEST=$(mktemp "$HERMES_TEMP_DIR/.watchdog-test-XXXXXX" 2>/dev/null || echo "")
  if [[ -n "$TEMP_TEST" && -f "$TEMP_TEST" ]]; then
    if rm "$TEMP_TEST" 2>/dev/null; then
      report PASS "Hermes temp write: $HERMES_TEMP_DIR is writable"
    else
      report FAIL "Hermes temp: created file but cannot remove $TEMP_TEST"
    fi
  else
    report FAIL "Hermes temp: cannot create test file in $HERMES_TEMP_DIR"
  fi
fi

# ── Summary ───────────────────────────────────────────────────────────────
section "Summary"
echo ""
echo "Results: $PASS passed, $WARN warnings, $FAIL failures"

if [[ $FAIL -gt 0 ]]; then
  echo "FAIL: $FAIL check(s) failed — fix before proceeding."
  exit 1
elif [[ $WARN -gt 0 ]]; then
  echo "WARN: Storage has warnings but no failures."
  exit 0
else
  echo "PASS: All storage checks OK."
  exit 0
fi