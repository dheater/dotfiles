# Metrics & SLOs

Always measure: latency (p50/p95/p99), throughput, memory, CPU.
Projects set thresholds per metric (0 = measure but no gate). Regressions beyond SLOs = release blockers.
Profile before architectural changes.

## Key Metrics
| Metric | Measure |
|---|---|
| Latency | p50/p95/p99 per critical op |
| Throughput | ops/sec or bytes/sec |
| Memory | steady-state + peak |
| CPU | utilization under load |

## Thresholds (document per project)
```yaml
latency: { connect_p95: 100ms }
throughput: { sustained_mbps: 1000 }
memory: { steady_state_mb: 50, peak_mb: 100 }
experimental_feature_p95: 0  # measure, no gate
```

## Rules
- Minimal overhead: atomic counters, low-overhead timers at seams. Expose via LibMetrics struct.
- Simple scripted benchmark <5 min. Avoid synthetic microbenchmarks.
- CI: publish `metrics-$GIT_SHA.json`. Compare against baseline.

## Checklist
- [ ] Profiled before change? Bottleneck identified?
- [ ] Baseline captured, improvement documented?
- [ ] No regressions in other metrics?
