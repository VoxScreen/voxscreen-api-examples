// A minimal VoxScreen webhook receiver. Node.js 18+, no dependencies.
//
// Run:
//   VOXSCREEN_WEBHOOK_SECRET=... node receiver.js
//
// It listens on port 8000, verifies X-VoxScreen-Signature against the raw body,
// and logs each verified event. Put it behind https before subscribing it:
// VoxScreen only delivers to https URLs.

const crypto = require("crypto");
const http = require("http");

const SECRET = process.env.VOXSCREEN_WEBHOOK_SECRET;
const PORT = Number(process.env.PORT || 8000);
if (!SECRET) throw new Error("Set VOXSCREEN_WEBHOOK_SECRET first");

// Latest result per submission. A retry repeats the same payload, and a retake sends
// submission.scored again for the same submission_id with new scores, so store by
// submission_id and let the latest delivery win.
const latestBySubmission = new Map();

function isValid(secret, rawBody, signatureHeader) {
  const expected =
    "sha256=" + crypto.createHmac("sha256", secret).update(rawBody).digest("hex");
  const a = Buffer.from(expected);
  const b = Buffer.from(signatureHeader || "");
  return a.length === b.length && crypto.timingSafeEqual(a, b);
}

http
  .createServer((req, res) => {
    if (req.method !== "POST") {
      res.writeHead(405).end();
      return;
    }
    const chunks = [];
    req.on("data", (chunk) => chunks.push(chunk));
    req.on("end", () => {
      const rawBody = Buffer.concat(chunks); // verify these exact bytes

      if (!isValid(SECRET, rawBody, req.headers["x-voxscreen-signature"])) {
        res.writeHead(401).end();
        return;
      }

      // Answer 2xx fast. Deliveries time out after 10 seconds, so do slow work
      // (ATS updates, Slack messages) in a queue, not here.
      res.writeHead(204).end();

      const event = JSON.parse(rawBody.toString("utf8"));
      const data = event.data || {};
      if (event.event === "submission.scored") {
        latestBySubmission.set(data.submission_id, data);
        console.log(
          `${data.candidate?.full_name} scored ${data.overall_score} ` +
            `for ${data.job?.title}: ${data.results_url}`
        );
      } else {
        console.log(`${event.event}: ${JSON.stringify(data)}`);
      }
    });
  })
  .listen(PORT, () => console.log(`Listening on :${PORT}`));
