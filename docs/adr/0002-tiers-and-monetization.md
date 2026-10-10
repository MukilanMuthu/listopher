# 2. Tiers and monetization

Date: 2026-10-10
Status: Accepted

## Context

The app and the server are open source. Money should come from convenience only, not from locking features away.

## Decision

| Tier | Storage | Sharing | Push | LLM (dictation parsing) |
|------|---------|---------|------|-------------------------|
| Free | Local only | No | — | No |
| Paid (hosted) | Local + hosted server | Yes | Yes | Yes, our key |
| Self-hosted | Local + own server | Yes | No (see [ADR 4](0004-push-hosted-only.md)) | BYOK: the operator sets their own LLM API key in the server config |

- Users have a local profile only. An account is created on a server when they first share a list.
- Self-hosters get sharing for free. That is intended: what we sell is hosting and the LLM.

## Consequences

- The server must make the LLM provider and key configurable, with nothing hardcoded to our account.
- LLM features must degrade cleanly when no key is configured. Dictation still works, using the fallback parser (see [ADR 5](0005-data-model.md#dictation-seam)).
