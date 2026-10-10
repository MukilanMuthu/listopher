# Listopher

Shared shopping list. Local-first Flutter app (Android first) plus a self-hostable Dart sync server. The decisions are in `docs/adr/`; read them before changing the architecture.

## Talking

- Talk to the user in caveman style (terse, no fluff).
- Never add Claude attribution to commits or PRs.
- During development, commit straight to `main` with no feature branches. This changes once the app leaves development.

## Code rules

1. **One function = one purpose.** A function can call others to compose them, but each base function does one thing.
2. **One base function per file**, with the file named after the function (`apply_op.dart` → `applyOp`). Group the files in folders by module. Each module's public interface is exported from a single file, and callers import only that.
3. **Remove, don't circumvent.** If something must go, delete it and its callers. Never add code that routes around it, flags it off or wraps it.
4. **Lazy, clean code.** Prefer the Dart/Flutter SDK, then the platform, then an existing dependency, then new code. No speculative abstractions, no interface with one implementation, no config for values that never change.
5. **Comments in caveman style, and lots of them.** Comment every function and every non-obvious line, but keep each comment terse.
6. **Readable or it goes.** If the user can't understand it, simplify it or delete it. No slop, no boilerplate.
7. **No overengineering.** Pick the simplest thing that works and write down its limit in a `ponytail:` comment.

## Modules

See [ADR 7](docs/adr/0007-stack-and-module-design.md). Each module has a small interface and its internals stay private. Tests go only through module interfaces.
