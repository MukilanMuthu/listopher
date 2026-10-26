# 11. OpenAI dictation, BYOK first

Date: 2026-10-26
Status: Accepted

## Context

Dictation should work for local-first users without requiring a self-hosted server. Earlier plans tied BYOK to self-hosted server configuration ([ADR 2](0002-tiers-and-monetization.md)), used on-device speech-to-text and a local fallback parser ([ADR 5](0005-data-model.md#dictation-seam)), and chose `speech_to_text` for speech input ([ADR 7](0007-stack-and-module-design.md)). This decision replaces those dictation plans.

## Decision

- Ship open-source, bring-your-own-key voice first. User enters their OpenAI API key in the app; no server is required. Store that key only in device secure storage. Never sync or log it.
- Use OpenAI as the only provider initially. Transcribe recorded audio, then use an LLM to extract item names, quantities, and units. Detect the spoken language automatically and preserve it; do not force translation or require a language selector.
- User taps the microphone to start and taps Stop to finish. Record up to two minutes; stop and process at the limit. Show Listening and Stop, with no timer or countdown.
- Show an editable preview before adding anything. One recording has one destination list, selected in the preview. Add only after the user confirms; use the existing `addItems` creation path ([ADR 5](0005-data-model.md)).
- On failure, keep the recording and offer Retry. Delete audio only after successful Add or explicit Discard. If no key is set, prompt the user to set one. Keep manual entry; do not fall back to a basic parser.
- Later store version: paid users use our hosted service and key. Defer hosted voice and store billing to a separate step. Never embed our service key in the store app.

For example, “two kilos onions, milk and bread” yields onions at 2 kg, milk, and bread.

## Consequences

- Local-first users can use voice without creating an account or running a server; OpenAI API use requires their own key.
- The key is stored only on-device and used to authenticate requests to OpenAI. Audio and transcript are sent to OpenAI for processing, not to the Listopher server. A local audio copy is retained through retries and preview until successful Add or explicit Discard.
- Hosted voice, paid-tier integration, and store billing need a later decision and implementation.
- OpenAI is the only provider until another is requested; no provider interface is added now.

References: [OpenAI speech-to-text guide](https://developers.openai.com/api/docs/guides/speech-to-text), [OpenAI audio guide](https://developers.openai.com/api/docs/guides/audio).
