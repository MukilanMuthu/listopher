# 5. Data model

Date: 2026-10-10
Status: Accepted

## Context

Each item must record who asked for it (**requester**), who ticked it off (**checker**) and who bought it (**fulfiller**). These can be different people. For example, Asha ticks an item that Ravi bought.

There are no separate lists. Items live in **spaces**: every user has one **private** space, plus any number of **shared** spaces. All members of a shared space see the same items. (Revised 2026-10-10: this replaced lists and groups.)

## Decision

All IDs are UUIDs generated on the client, so records can be created offline.

```
user      id, display_name, server_account_id?   -- null = local-only profile
space     id, name, private, server_url?,         -- private = this phone only, never synced
          created_by, created_at                 -- server_url null = not shared yet
member    space_id, user_id, role (owner|member), joined_at
item      id, space_id, name, quantity?, unit?, note?,   -- "rice 1 kg", "soap 1", "milk"
          requested_by, requested_at,
          checked, checked_by?, checked_at?,
          fulfilled_by?,                         -- who bought it; defaults to checked_by
          deleted
op        id, space_id, item_id?, user_id,
          type, payload (json), client_time,
          server_seq?                            -- null = still in the outbox
```

### Op types

| type | payload |
|------|---------|
| `space.create` | `{name, private}` |
| `space.rename` | `{name}` |
| `item.add` | `{name, quantity?, unit?, note?, requested_by}` |
| `item.update` | `{name, quantity?, unit?, note?}` (full state: null = cleared) |
| `item.check` | `{fulfilled_by}` (defaults to the acting user) |
| `item.uncheck` | `{}` (clears `checked_by`, `checked_at` and `fulfilled_by`) |
| `item.delete` | `{}` |

- `quantity` is a decimal (`1.5` kg). `unit` is free text (`kg`, `L`, `pack`). Both are optional: "soap 1" has no unit, and "milk" has neither.
- `item` and `space` are **materialized views** of the op log (see [ADR 3](0003-operation-log-sync.md)). Widgets and notifications read these tables, never the op log.
- Blame for an item = its ops in order. Each op shows the user, the time and the change.
- The requester can be someone other than the person who adds the item ("Mum asked for eggs").
- The private space is created automatically together with the local user. It can't be shared.
- Dates come from items: `requested_at` gives the "by date" view.

### Dictation seam

- All item creation goes through one function: `addItems(spaceId, items[], requestedBy)`. Manual entry uses it too.
- Dictation is: on-device speech-to-text → `ItemParser.parse(text) → items[]` → `addItems`.
- There are two `ItemParser` implementations:
  - the LLM parser: hosted, or BYOK on self-hosted servers;
  - a local fallback that splits on commas and the locale's words for "and" (see [ADR 6](0006-multi-language.md)).

## Consequences

- One "add items" path keeps dictation a drop-in feature later.
- When a shared space first reaches a server, its ops are uploaded and `server_url` is set. The data needs no migration.
- A space is also the sync and membership unit, so groups no longer exist as a separate thing.
