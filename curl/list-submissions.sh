#!/usr/bin/env sh
# Poll for scored submissions completed at or after SINCE (ISO 8601).
# Results come newest first, so a poller can stop once it sees an id it already has.
#
# Usage: SINCE=2026-11-01T00:00:00Z ./list-submissions.sh
set -eu
: "${VOXSCREEN_API_KEY:?Set VOXSCREEN_API_KEY first}"
SINCE="${SINCE:-1970-01-01T00:00:00Z}"

curl -sS -G https://app.voxscreen.com/api/integrations/v1/submissions \
  -H "Authorization: Bearer $VOXSCREEN_API_KEY" \
  --data-urlencode "status=scored" \
  --data-urlencode "since=$SINCE" \
  --data-urlencode "limit=50"
echo
