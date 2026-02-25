#!/usr/bin/env bash
set -euo pipefail

# Cloud Run provides PORT for the externally reachable service.
export AGENT_HOST="${AGENT_HOST:-127.0.0.1}"
export POLICY_AGENT_PORT="${POLICY_AGENT_PORT:-9999}"
export RESEARCH_AGENT_PORT="${RESEARCH_AGENT_PORT:-9998}"
export PROVIDER_AGENT_PORT="${PROVIDER_AGENT_PORT:-9997}"
export HEALTHCARE_AGENT_PORT="${HEALTHCARE_AGENT_PORT:-${PORT:-8080}}"

echo "Starting agents with:"
echo "  AGENT_HOST=${AGENT_HOST}"
echo "  POLICY_AGENT_PORT=${POLICY_AGENT_PORT}"
echo "  RESEARCH_AGENT_PORT=${RESEARCH_AGENT_PORT}"
echo "  PROVIDER_AGENT_PORT=${PROVIDER_AGENT_PORT}"
echo "  HEALTHCARE_AGENT_PORT=${HEALTHCARE_AGENT_PORT}"

python -u a2a_policy_agent.py &
PID_POLICY=$!

python -u a2a_research_agent.py &
PID_RESEARCH=$!

python -u a2a_provider_agent.py &
PID_PROVIDER=$!

cleanup() {
  kill "${PID_POLICY}" "${PID_RESEARCH}" "${PID_PROVIDER}" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

# Run orchestrator in foreground so Cloud Run health/lifecycle tracks it.
python -u a2a_healthcare_agent.py
