# Observability (high level)

I keep this repository small on purpose,nothing here provisions Prometheus, Grafana, or CloudWatch in Terraform. The product context I have in mind is a **business logic of companyNM that we discussed in the initial interviews for the lending and borrowing platform**, with millions of events across applications, integrations, and async pipelines . Below is what I would instrument and document as I connect real backends to a lending platform—not as a guarantee of what ships in this demo repo.

## Metrics I would collect (and why)

| Area | What I would measure | Why it matters for this business |
|------|----------------------|----------------------------------|
| **HTTP / APIs** | Request rate, latency percentiles, error rate (by route and tenant/bank where possible) | SLOs between borrowers, banks, and our services; catch regressions before they hit repayment or onboarding flows. |
| **Event & stream processing** | Ingest throughput (events/sec), **end-to-end lag**, partition/queue depth, consumer group lag, retry rate | At millions of events, I care about **backpressure** and **staleness** e.g. credit decisions or disbursement signals must not silently fall behind. |
| **Dead-letter & failures** | DLQ depth, failed-event rate by **event type** (e.g. application submitted, offer accepted, repayment posted) | We need to spot systematic bugs or partner schema changes before they become compliance or customer-trust issues so we can trigger the responsible team.|
| **Downstream / bank integrations** | Latency and error rate to core banking or partner APIs, circuit-breaker open/close | Lending is only as reliable as the slowest critical dependency; I separate **our** errors from **partner** instability. |
| **Containers & data plane** | CPU, memory, pod restarts, DB/cache connection saturation | Capacity planning when traffic spikes (e.g. month-end, campaigns). |
| **Ingress / platform** | ALB/API Gateway 4xx/5xx, target health | Distinguish user mistakes (4xx) from platform faults (5xx). |
| **Product & risk (later)** | Web Vitals (RUM) if I add browser instrumentation | Borrower experience on onboarding and dashboards; complements server metrics. |

I would also define a small set of **signals** per critical journey (e.g. “loan application submitted → decision/outcome available”) and track **success rate and latency** of that journey even if it spans several services—a must when events fan out across systems.

## Alerting (rules and thresholds)

**I have not codified alerts in this repository** (no Alertmanager or CloudWatch alarm IaC here). Given the volume and regulated context, I would start with:

- sustained **5xx** or **p95 latency** vs baseline on APIs that gate borrowing or repayments.
- **consumer lag** or **queue depth** above a threshold for **N minutes**; **DLQ growth** not explained by a known deploy.
- **Data freshness**: alerts when materialized views or decision pipelines exceed acceptable delay (thresholds set per product SLO).
- **Infrastructure**: crashloops, unhealthy targets, synthetic checks against `/health` and a minimal **readiness** path.

I would tune thresholds per environment (sandbox vs production) and avoid paging on first breach of noisy metrics, like **multi-window** rules where possible.

## Dashboards (layout / panels)

**I did not ship dashboards in-repo.** If I were building an operator-facing view for this domain, I would lay out at least:

1. **Row: API health** — RPS, error rate, p95/p99 latency, top slow routes.
2. **Row: events & pipelines** — ingest rate, lag, DLQ size, retries by event type.
3. **Row: dependencies** — partner/bank integration latency and errors.
4. **Row: compute** — CPU/memory, restarts, autoscaler behavior.

I would add a **business or risk summary row** once I have trustworthy metrics (e.g. applications in flight, decisions per hour) never as a substitute for source-of-truth ledgers, but to correlate operational incidents with product impact.

## Log aggregation

- **in this repo** apps log to **stdout/stderr**; the backend emits **JSON** (`backend/app/main.py`) so I can parse and correlate fields in a log platform.
- **On Kubernetes:** I would run a **DaemonSet** collector (e.g. **Allow**) and ship to **CloudWatch Logs**, **Loki**, or **OpenSearch**, with retention and access policies that match **banking and privacy** expectations.
- **And as companyNM is a fintech at scale:** I think we are forced to treat logs as **audit-adjacent** and this is not our optional choice. I rely on structured fields (tenant, request or correlation id, event id) and avoid logging sensitive payloads verbatim. 
- **Next steps I would add:** **OpenTelemetry** (traces + metrics) [I had also pyroscope in previous firm].
