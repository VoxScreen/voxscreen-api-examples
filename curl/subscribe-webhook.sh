#!/usr/bin/env sh
# Subscribe an https URL to submission.scored.
# The response contains the signing "secret". It is shown here and nowhere else,
# so store it: the receivers in ../webhooks need it to verify deliveries.
# Subscribing the same URL to the same event twice returns the existing subscription.
#
# Usage: ./subscribe-webhook.sh https://example.com/webhooks/voxscreen
set -eu
: "${VOXSCREEN_API_KEY:?Set VOXSCREEN_API_KEY first}"
TARGET_URL="${1:?Pass your https endpoint as the first argument}"

curl -sS -X POST https://app.voxscreen.com/api/integrations/v1/hooks \
  -H "Authorization: Bearer $VOXSCREEN_API_KEY" \
  -H "Content-Type: application/json" \
  -d "{\"event\": \"submission.scored\", \"target_url\": \"$TARGET_URL\"}"
echo
