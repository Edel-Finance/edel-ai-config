# Glossary

- **Contract:** a DTO or schema defining a request, response or message shape. A **ledger contract** is a Canton ledger object; an **EVM smart contract** is deployed executable chain code. Qualify those meanings rather than using contract interchangeably.
- **Capability:** a documented available operation, not permission to perform it.
- **Scope:** the operations allowed by a credential; it does not replace the owner's explicit instruction for a money action.
- **Signing identity:** the owner's passkey and delegated signing key; distinct from the Canton Party binding.
- **Party binding:** the account's Canton ledger relationship; not a signing identity or evidence of owner approval for an action.
- **API key / bearer / realtime ticket:** distinct credentials for documented API, session or realtime use; never interchangeable and never examples to print or persist in the repo.
- **Venue / environment:** the specific public API and its contract; Development or TestNet proof does not prove Production availability.
- **Published / implemented:** publicly available in the intended venue / present in source; implementation alone does not establish publication.
- **Paper / live:** simulated strategy activity / actual venue activity; use the current public contract to establish which applies rather than inferring from a tool name.
- **Installed / structure-checked:** exercised through the real client / inspected against its format; neither alone proves an authenticated operation.
- **Unavailable / unknown:** documented absence / insufficient evidence; neither permits an invented route, value or authorization workaround.
