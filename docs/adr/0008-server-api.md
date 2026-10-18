# 8. Server API and accounts

Date: 2026-10-11
Status: Accepted

## Context

The server authenticates users, orders ops per space, stores them and hands them to members ([ADR 3](0003-operation-log-sync.md)). It's a Dart `shelf` app with SQLite ([ADR 7](0007-stack-and-module-design.md)). Private spaces never reach it.

Accounts must survive a reinstall: a user who reinstalls logs in again and gets their shared spaces back. Strangers must not be able to join.

## Decision

### Accounts: two ways in, one server

| Edition | How accounts are created | How the app signs in |
|---------|--------------------------|----------------------|
| **Self-hosted** (open) | The admin creates them with the server CLI: `listopher-server add-user <username> <display name>` (prompts for the password). There is no public sign-up. | Server URL + username + password |
| **Hosted** (commercial) | Created on first sign-in | Google (Android) / Apple (iOS) ID token, verified by the server against the provider's public keys |

- **Multiple servers per phone.** A phone can be in spaces on several servers. It keeps one account + session per server (`servers` table on the phone: url, account_id, token). Joining a space on a new server asks for that server's username and password.
- Accounts get **server-generated ids**. The phone adopts the account id as its user id for shared spaces. Private-space ops keep the local id, since they never leave the phone.
- Passwords are stored as Argon2id or PBKDF2 hashes (whatever a maintained pure-Dart package offers), never in plain text.
- Every login creates a **session token** (32 random bytes, base64url). Only its SHA-256 hash is stored. One account can have many sessions, so multiple phones and reinstalls just work.
- Every route except login needs `Authorization: Bearer <token>`. Otherwise 401.
- **Build now:** password login and the CLI. **Later:** Google/Apple login, using the same `accounts` and `sessions` tables plus a provider-identity column. Note that Apple requires Sign in with Apple on iOS whenever another social login is offered.

### Sharing needs a login

- Creating a shared space = creating it on the server. The Spaces tab's + asks you to log in first if you aren't.
- Free users without a server keep only their private space ([ADR 2](0002-tiers-and-monetization.md)).

### Routes

| Route | Who | Does |
|-------|-----|------|
| `POST /auth/login {username, password}` | anyone | Returns `{token, user_id, display_name}`. 401 for bad credentials. Same response for an unknown user and a wrong password. |
| `POST /auth/logout` | authed | Deletes this session |
| `GET /me/delete-preview` | authed | Lists which owned spaces would be transferred and which deleted. The app shows this as a warning before `DELETE /me`. |
| `DELETE /me` | authed | Delete own account: sessions and memberships. Each owned space passes to its **oldest eligible member**. If there is none, the space is deleted. Its ops stay for blame and show as "deleted user". Required by Google Play. |
| `GET /me/spaces` | authed | Lists the space ids you're a member of. Used to restore spaces after a reinstall. |
| `POST /spaces {space_id}` | authed | Register a shared space; the caller becomes owner. The id is generated on the phone. 409 if it already exists. |
| `DELETE /spaces/:id` | owner | Delete the space with all its ops and members. Members' phones get 404 on the next sync and remove it locally. |
| `POST /spaces/:id/invite` | owner | New invite token. Replaces the old one, so old QR codes stop working. |
| `POST /spaces/:id/join {invite}` | authed | Join as a member if the invite matches, else 403. Joining twice is a no-op. |
| `GET /spaces/:id/members` | member | Returns `[{user_id, display_name, role}]`, the names for blame |
| `POST /spaces/:id/ops [op…]` | member | Append ops and return `{op_id: server_seq}` |
| `GET /spaces/:id/ops?after=N` | member | Ops with `server_seq > N`, in order. Max 500 per call; the client loops. |

Non-members get 403 on space routes.

### Joining

1. The owner shows the QR code: `listopher://join?server=<url>&space=<id>&invite=<token>`.
2. The joiner scans it. If the joiner isn't logged in to that server, the app asks for their **own** username and password.
3. The app calls join, then pulls ops from 0.

Both the invite and an account the admin created are needed, so a leaked QR code alone gets nobody in.

### Op rules (on `POST …/ops`)

- Each op is parsed with `opFromJson` from `core`. Bad JSON → 400 and **nothing** is stored (all or nothing).
- `op.space_id` must match the URL, and `op.user_id` must be the authenticated account. Otherwise 403. This makes blame trustworthy, and a reinstall keeps the same id because it's the account's id.
- **Idempotent:** an op id the server has already seen returns its existing seq, so resending is safe.
- Seq is `max(seq) + 1` per space, inside one transaction. `ponytail:` SQLite allows one writer at a time, which is fine for shopping lists. Upgrade path: Postgres sequences.
- The server never interprets op bodies. It stores no names and no item state. Joiners get the space name from the `space.create` op.

### Names and ownership

- **Person names:** the server account's `display_name` is shown in shared spaces. The local name from the first-launch prompt is used only in the private space.
- **Eligible owner:** in the open edition every member is eligible. In the commercial edition only paid members are; until billing exists, `isEligibleOwner` returns true. If no member is eligible, the space is deleted, and the app warns first (via the delete preview).

### Abuse limits

- **Login lockout:** after 5 failed logins an account is locked for 15 minutes, counted per account.
- **Body cap:** requests over 1 MB get 413.
- **CLI:** `add-user`, `set-password <username>` and `revoke-sessions <username>` (for a stolen phone).

### Transport

Plain `http://` is allowed. HTTPS (e.g. a Caddy reverse proxy) is the self-hoster's responsibility. Over plain HTTP, passwords and tokens are readable on the network. That risk is accepted and documented for self-hosters.

### Storage

```
accounts  id pk, username unique, password_hash, display_name, failed_logins, locked_until?, created_at
sessions  token_hash pk, account_id, created_at
spaces    id pk, owner_id, invite_token?, created_at
members   space_id, account_id, role, joined_at        pk(space_id, account_id)
ops       space_id, seq, id unique, account_id, json, received_at   pk(space_id, seq)
```

### Config

Environment variables `PORT` (default 8080) and `DB_PATH` (default `listopher.db`).

### Deferred

Google/Apple login, removing members and leaving spaces, manual ownership transfer, session expiry, rate limiting beyond the login lockout, billing, push.

## Consequences

- Reinstalling restores shared spaces: log in, then `GET /me/spaces`, then pull ops. The **private space is lost** on reinstall. That's accepted.
- Moving an item between spaces = delete in one space + add in the other. No new op type.
- Self-hosters must create accounts before anyone can share. That's one more step, but it keeps strangers out.
- The phone has two ids for "me": the local id (private space) and the account id (shared spaces). The store resolves both to "me".
- The hosted edition can't go public until Google/Apple login, rate limiting and billing exist.
