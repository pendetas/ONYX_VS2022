# ONYX AI Assistant

This document defines how the ONYX chat assistant should behave on the customer-facing site.

## Model And Endpoint

- Provider: Google Gemini through the official `Google.GenAI` SDK.
- Default model: `gemini-2.5-flash`.
- API route used by the site: `customer_page/onyx_ai_chat.ashx`.
- API key lookup order: `GEMINI_API_KEY`, then `GeminiApiKey` from ignored local app settings.
- The key must stay server-side. Do not place it in JavaScript, markup, CSS, committed config, or public documentation.
- The model can be changed with `GeminiModel`.

## Local Secret Setup

Use environment variables for deployed or shared environments:

```powershell
setx GEMINI_API_KEY "your-gemini-key"
```

For local development, `Web.config` can load ignored overrides from `AppSettings.Local.config`:

```xml
<appSettings>
  <add key="GeminiApiKey" value="your-gemini-key" />
  <add key="GeminiModel" value="gemini-2.5-flash" />
</appSettings>
```

`AppSettings.Local.config` is ignored by Git and must not be committed.

## Allowed Scope

The assistant may answer questions about:

- ONYX products and categories: mice, keyboards, headsets, monitors, and accessories.
- Product browsing, product details, price, stock, variants, wishlist, reviews, and setup basics.
- Cart, checkout guidance, order history, invoices, shipping, warranty, returns, replacement paths, and support.
- Account navigation such as login, register, forgot password, and profile guidance.
- ONYX policy pages such as Support, Privacy, and Terms.

## Knowledge Context

The assistant uses retrieval-augmented context from safe ONYX project text files before calling Gemini. This is not permanent model training; it gathers relevant local snippets for each question and adds them to the prompt.

The curated local training brief is `docs/onyx-assistant-knowledge.md`. Keep it customer-facing and free of secrets. It should contain route guidance, support requirements, order-history guidance, product/category notes, and assistant answer style.

Included file types: `.aspx`, `.ascx`, `.master`, `.md`, `.txt`, and `.sql`.

Excluded files and folders include config files, local app settings, project files, build output, NuGet packages, Git metadata, Visual Studio metadata, videos, binaries, and source code internals. Do not add secrets or private operational data to assistant context.

The retriever expands customer wording with related ONYX terms. For example, purchase can map to order, checkout, invoice, and receipt; claim or broken can map to warranty, support, serial, and replacement; saved or favorite can map to wishlist and cart.

The chat service must only call Gemini after local ONYX file knowledge is found for the question. If retrieval returns no context, the assistant should refuse briefly and ask the customer to ask about ONYX products, cart, order history, warranty, account, or support. Clearly unrelated questions must be rejected before ONYX keyword matching, even if the prompt includes the word ONYX.

When knowledge is found, the assistant should answer the question directly first and use page paths as helpful follow-up actions. Page guidance should support the answer, not replace it.

## Restricted Scope

The assistant must refuse or redirect questions about:

- Topics unrelated to ONYX, ecommerce, gaming gear, or the website.
- Schoolwork, coding help, general research, trivia, politics, medical, legal, or financial advice.
- Requests to collect passwords, full card numbers, CVV, banking credentials, or private security codes.
- Requests to complete payment, issue refunds, cancel orders, change account data, or perform backend actions directly.

## Refusal Style

When a question is out of scope, answer in one short sentence and redirect the user back to ONYX. Example:

`I can only help with ONYX products, orders, warranty, and support, but I can help you compare gear or find the right support path.`

Vague prompts such as "help" or "I want to know" should not be treated as violations. The assistant should ask a short follow-up that points the user toward ONYX products, cart, orders, warranty, or support.

Short greetings such as "hello", "hi", and "hey" should receive a brief ONYX-focused welcome instead of an out-of-scope response.

## UI Placement

- The chat button appears from the shared customer master page.
- It is hidden on login, register, forgot password, checkout, and invoice pages.
- It should not interrupt payment or authentication flows.

## Maintenance Notes

- Keep replies short, helpful, and answer-first: two to four sentences.
- Keep replies plain text. Do not return Markdown formatting such as bold markers, headings, bullets, numbered lists, or links.
- Update this document whenever the assistant gains new allowed topics, tools, or backend actions.
- If the API provider changes, update the endpoint notes and `GeminiAssistantService` together.
