#!/usr/bin/env sh
# List active jobs, newest first. Use an "id" from here as JOB_ID when inviting.
set -eu
: "${VOXSCREEN_API_KEY:?Set VOXSCREEN_API_KEY first}"

curl -sS "https://app.voxscreen.com/api/integrations/v1/jobs?status=active&limit=20" \
  -H "Authorization: Bearer $VOXSCREEN_API_KEY"
echo
