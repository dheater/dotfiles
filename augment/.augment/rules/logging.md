# Logging

Structured queryable logs for control plane. Multi-line key=value. All events: `timestamp` + `event_id`.
Failures: `session_id` + full context. Success: minimal. Data plane: TRACE, compile-time disabled in release.

## Categories
| Category | Level | Fields |
|---|---|---|
| Control plane failure | ERROR/WARN | timestamp, event_id, session_id, error_code, full context |
| Control plane success | INFO | timestamp, event_id only |
| Data plane | TRACE | simple string, debug builds only |
| Protocol messages | DEBUG | existing format |

## Event Format
Success:
```
EVENT_NAME
	timestamp=2026-01-08T15:23:45.123Z
	event_id=evt_abc123
```
Failure adds: `session_id`, `error_code`, identity, network, context fields.
Event names: `SCREAMING_SNAKE_CASE`

## Checklist
- [ ] SCREAMING_SNAKE_CASE event name?
- [ ] All events have timestamp, event_id?
- [ ] Failures have session_id, error_code, context?
- [ ] Success minimal (no session_id, duration_ms)?
- [ ] Data plane uses TRACE (debug only)?
