#!/usr/bin/env sh
# Invite one candidate to a job. The candidate gets the invitation email straight away,
# and the invite counts against your monthly candidate quota.
# Re-running with the same email reuses the existing candidate, so retries are safe.
#
# Usage: JOB_ID=... ./invite-candidate.sh alex.silva@example.com "Alex Silva"
set -eu
: "${VOXSCREEN_API_KEY:?Set VOXSCREEN_API_KEY first}"
: "${JOB_ID:?Set JOB_ID to an active job id (see list-jobs.sh)}"
EMAIL="${1:?Pass the candidate email as the first argument}"
NAME="${2:?Pass the candidate full name as the second argument}"

curl -sS -X POST https://app.voxscreen.com/api/integrations/v1/candidates/invite \
  -H "Authorization: Bearer $VOXSCREEN_API_KEY" \
  -H "Content-Type: application/json" \
  -d "{\"job_id\": \"$JOB_ID\", \"email\": \"$EMAIL\", \"full_name\": \"$NAME\"}"
echo
