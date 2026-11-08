# VoxScreen API examples

Small, copy-paste examples for the [VoxScreen](https://voxscreen.com) public API: invite
candidates to a one-way video interview from your own systems, and get the AI-scored
results back by webhook.

The full reference, with every endpoint, payload and event, is at
**https://voxscreen.com/docs/api**.

## Before you start

1. Create an API key in VoxScreen under **Settings → Integrations**. The key is shown
   once, so copy it before you close the dialog. Every plan has API access, the free one
   included.
2. Export it so the scripts can read it:

   ```sh
   export VOXSCREEN_API_KEY="vs_live_..."
   ```

Base URL: `https://app.voxscreen.com/api/integrations/v1`

## What's here

| Path | What it does |
|---|---|
| [`curl/me.sh`](curl/me.sh) | Checks the key works and shows which account it belongs to |
| [`curl/list-jobs.sh`](curl/list-jobs.sh) | Lists your active jobs, to find a `job_id` |
| [`curl/invite-candidate.sh`](curl/invite-candidate.sh) | Invites one candidate to a job. They get the invitation email straight away |
| [`curl/list-submissions.sh`](curl/list-submissions.sh) | Polls for scored submissions since a given time |
| [`curl/subscribe-webhook.sh`](curl/subscribe-webhook.sh) | Subscribes a URL to `submission.scored` and prints the signing secret |
| [`webhooks/python/receiver.py`](webhooks/python/receiver.py) | A webhook receiver that verifies the signature (Python, standard library only) |
| [`webhooks/node/receiver.js`](webhooks/node/receiver.js) | The same receiver in Node.js, no dependencies |

## Webhooks in one paragraph

Each delivery is a `POST` with a JSON body and these headers: `X-VoxScreen-Event`,
`X-VoxScreen-Delivery` (unique per attempt, handy in your logs) and
`X-VoxScreen-Signature` (`sha256=` plus the HMAC-SHA256 of the raw body, keyed with
your subscription secret). Verify against the bytes you received, not a re-serialised
object. Respond 2xx within 10 seconds. Any other response is retried five times with
exponential backoff, and `410 Gone` unsubscribes the endpoint. A retry repeats the
payload, and a retake sends `submission.scored` again for the same `submission_id` with
new scores, so store results by `submission_id` and let the latest delivery win.

Events: `submission.scored`, `submission.completed`, `candidate.invited`.

## Errors and limits

Errors return `{"detail": "..."}`. A `401` means the key is missing or revoked, a `402`
means the subscription has lapsed (never that the plan is too small), and a `404` covers
both "doesn't exist" and "belongs to another account". The rate limit is 120 requests per
minute, per key, per endpoint.

## Help

Questions about the API: support@voxscreen.com.

## License

MIT. See [LICENSE](LICENSE).
