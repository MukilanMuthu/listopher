# 5. Data model

Date: 2026-10-10
Status: Accepted

## Context

Each item must record who asked for it (**requester**), who ticked it off (**checker**) and who bought it (**fulfiller**). These can be different people. For example, Asha ticks an item that Ravi bought. Lists are organised by date.

## Decision

All IDs are UUIDs generated on the client, so records can be created offline.

```
user      id, display_name, server_account_id?   -- null = local-only profile
group     id, name, server_url                   -- free tier: no groups
member    group_id, user_id, role (owner|member), joined_at
list      id, group_id?, name, date?, created_by, created_at   -- group_id null = local-only
item      id, list_id, name, quantity?, unit?, note?,   -- "rice 1 kg", "soap 1", "milk"
          requested_by, requested_at,
          checked, checked_by?, checked_at?,
          fulfilled_by?,                         -- who bought it; defaults to checked_by
          deleted
op        id, group_id?, list_id, item_id?, user_id,
          type, payload (json), client_time,
          server_seq?                            -- null = still in the outbox
```

### Op types

| type | payload |
|------|---------|
| `list.create` | `{name, date?}` |
| `list.update` | `{name?, date?}` |
| `item.add` | `{name, quantity?, unit?, note?, requested_by}` |
| `item.update` | `{name?, quantity?, unit?, note?}` |
| `item.check` | `{fulfilled_by}` (defaults to the acting user) |
| `item.uncheck` | `{}` (clears `checked_by`, `checked_at` and `fulfilled_by`) |
| `item.delete` | `{}` |

- `quantity` is a decimal (`1.5` kg). `unit` is free text (`kg`, `L`, `pack`). Both are optional: "soap 1" has no unit, and "milk" has neither.
- `item` and `list` are **materialized views** of the op log (see [ADR 3](0003-operation-log-sync.md)). Widgets and notifications read these tables, never the op log.
- Blame for an item = its ops in order. Each op shows the user, the time and the change.
- The requester can be someone other than the person who adds the item ("Mum asked for eggs").
- `list.date` gives the "lists by date" view. The UI groups and sorts lists by `date`, falling back to `created_at`.

### Dictation seam

- All item creation goes through one function: `addItems(listId, items[], requestedBy)`. Manual entry uses it too.
- Dictation is: on-device speech-to-text → `ItemParser.parse(text) → items[]` → `addItems`.
- There are two `ItemParser` implementations:
  - the LLM parser: hosted, or BYOK on self-hosted servers;
  - a local fallback that splits on commas and the locale's words for "and" (see [ADR 6](0006-multi-language.md)).

## Consequences

- One "add items" path keeps dictation a drop-in feature later.
- When a local-only list is first shared, its ops are uploaded with `group_id` set. The data needs no migration.
