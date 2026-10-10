# 1. Local-first app with an open-source sync server

Date: 2026-10-10
Status: Accepted

## Context

Listopher is a shared shopping list. Group members add items offline and sync later. We first looked at pure peer-to-peer and at Google Drive as a backend (see [research](../research/p2p-shopping-list.md)).

- **P2P:** phones on different networks still need a relay. Two phones also only sync when both have the app open at the same time, because iOS suspends apps in the background.
- **Google Drive:** every member needs a Google account. Drive can't merge concurrent writes to one file, and its OAuth scopes are awkward for files other people share.

## Decision

- The phone keeps a local SQLite database. It is the source of truth for the UI, the widget and the notification.
- The app works fully offline. Changes queue up locally and sync when the phone is back online.
- Sharing goes through a sync server. The server is open source and self-hostable.
- App: Flutter, Android first and iOS later ([ADR 7](0007-stack-and-module-design.md)).

## Consequences

- An always-on server fixes the "both phones online at once" problem.
- Data ownership comes from being able to self-host, not from P2P.
- We run hosted infrastructure for the paid tier (see [ADR 2](0002-tiers-and-monetization.md)).
- The transport and stack sections of the research doc are superseded. Its QR, widget, notification and dictation sections still apply.
