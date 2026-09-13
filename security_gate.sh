#!/usr/bin/env bash
set -euo pipefail

log() { echo "[security_gate] $*"; }
die() { echo "[security_gate] ERROR: $*" >&2; exit 1; }

SEVERITY="${SEVERITY:-CRITICAL,HIGH}"
FAIL=0

log "Running hadolint..."
if hadolint Dockerfile; then
  log "hadolint: PASS"
else
  log "hadolint: FAIL"
  FAIL=1
fi

log "Running trivy config..."
if trivy config --exit-code 1 --severity "$SEVERITY" .; then
  log "trivy config: PASS"
else
  log "trivy config: FAIL"
  FAIL=1
fi

log "Running trivy fs (vuln + secret)..."
if trivy fs --scanners vuln,secret --skip-dirs .venv,.git --exit-code 1 --severity "$SEVERITY" .; then
  log "trivy fs: PASS"
else
  log "trivy fs: FAIL"
  FAIL=1
fi

if [ "$FAIL" -eq 0 ]; then
  log "OVERALL: PASS"
  exit 0
else
  die "OVERALL: FAIL"
fi