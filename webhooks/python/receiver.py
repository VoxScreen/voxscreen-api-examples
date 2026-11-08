"""A minimal VoxScreen webhook receiver. Python 3.8+, standard library only.

Run:
    VOXSCREEN_WEBHOOK_SECRET=... python receiver.py

It listens on port 8000, verifies X-VoxScreen-Signature against the raw body,
and prints each verified event. Put it behind https before subscribing it:
VoxScreen only delivers to https URLs.
"""

import hashlib
import hmac
import json
import os
from functools import partial
from http.server import BaseHTTPRequestHandler, HTTPServer

print = partial(print, flush=True)  # show events as they arrive

SECRET = os.environ["VOXSCREEN_WEBHOOK_SECRET"]
PORT = int(os.environ.get("PORT", "8000"))

# Latest result per submission. A retry repeats the same payload, and a retake sends
# submission.scored again for the same submission_id with new scores, so store by
# submission_id and let the latest delivery win.
latest_by_submission = {}


def is_valid(secret: str, raw_body: bytes, signature_header: str) -> bool:
    expected = "sha256=" + hmac.new(secret.encode(), raw_body, hashlib.sha256).hexdigest()
    return hmac.compare_digest(expected, signature_header)


class Handler(BaseHTTPRequestHandler):
    def do_POST(self):
        length = int(self.headers.get("Content-Length", "0"))
        raw_body = self.rfile.read(length)  # verify these exact bytes
        signature = self.headers.get("X-VoxScreen-Signature", "")

        if not is_valid(SECRET, raw_body, signature):
            self.send_response(401)
            self.end_headers()
            return

        # Answer 2xx fast. Deliveries time out after 10 seconds, so do slow work
        # (ATS updates, Slack messages) in a queue, not here.
        self.send_response(204)
        self.end_headers()

        event = json.loads(raw_body)
        data = event.get("data", {})
        if event.get("event") == "submission.scored":
            latest_by_submission[data.get("submission_id")] = data
            candidate = data.get("candidate", {})
            print(
                f"{candidate.get('full_name')} scored {data.get('overall_score')} "
                f"for {data.get('job', {}).get('title')}: {data.get('results_url')}"
            )
        else:
            print(f"{event.get('event')}: {json.dumps(data)}")


if __name__ == "__main__":
    print(f"Listening on :{PORT}")
    HTTPServer(("", PORT), Handler).serve_forever()
