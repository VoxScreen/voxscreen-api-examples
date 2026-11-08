#!/usr/bin/env sh
# Check that your API key works. Prints the account name and plan.
set -eu
: "${VOXSCREEN_API_KEY:?Set VOXSCREEN_API_KEY first}"

curl -sS https://app.voxscreen.com/api/integrations/v1/me \
  -H "Authorization: Bearer $VOXSCREEN_API_KEY"
echo
