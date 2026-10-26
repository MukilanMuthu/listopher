# OpenAI BYOK dictation

Status: ready-for-agent

## Goal

Implement the local-first OpenAI voice flow in [ADR 11](../../../docs/adr/0011-openai-dictation.md). Do not implement hosted voice or store billing.

## Acceptance criteria

- [ ] Tapping the microphone starts recording; tapping Stop ends it. Handle microphone permission denial, recording errors, and cancellation.
- [ ] Enforce a hidden two-minute recording cap. Stop and process at the limit; show Listening and Stop with no timer or countdown.
- [ ] Without an OpenAI key, prompt the user to set one. Store their key only in device secure storage; never send it to the Listopher server or write it to logs.
- [ ] Transcribe the recording with OpenAI, detect its language automatically, and preserve the spoken language. Do not require language selection or translate the text.
- [ ] Use an OpenAI LLM to extract editable item names, quantities, and units. For “two kilos onions, milk and bread”, preview onions at 2 kg, milk, and bread.
- [ ] Let the user edit the preview and select one destination list per recording. Save no items until they confirm Add; use the existing `addItems` path.
- [ ] On failure, retain the recording and offer Retry. Delete audio only after successful Add or explicit Discard. Canceling the preview adds no items.
- [ ] Keep manual entry. Do not add a basic-parser fallback or a speculative provider interface.
- [ ] Verify an actual OpenAI API flow with a user key and check the recording, preview, retry, discard, and Add flows on an Android phone. Do not put a raw key in code, docs, or test fixtures.
- [ ] Keep any hosted service key out of the store app; hosted voice and billing stay deferred.
