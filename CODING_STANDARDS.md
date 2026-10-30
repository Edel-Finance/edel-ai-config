# Coding standards

Use these judgments when changing public skills and client documentation.
[AGENTS.md](AGENTS.md) remains authoritative for scope, security and owner permission.
Mechanical checks belong in existing tooling, not in this review guide.

## Owner coding rules

- Before adding logic, inspect the reusable core (`packages/`, crates or shared libraries) and reuse or extend it instead of duplicating behavior.
- TypeScript forbids nested ternaries; use a switch or lookup map for repeated equality dispatch on one stable subject, while allowing unrelated conditions.
- Validate the whole input schema first at each boundary, then throw or emit one existing typed validation-error event; avoid scattered field checks.
- TypeScript uses Zod wherever performance permits, always for endpoints, MCP tools, config and messages; Rust uses serde plus garde/validator or typed newtypes; Python uses pydantic; C++ may validate explicitly at the boundary when library overhead would harm performance.
- Keep [GLOSSARY.md](GLOSSARY.md) current and review ambiguous terms; unqualified contract means a DTO/schema, while ledger and EVM smart contracts require explicit qualification.
- Every added logic change ships with unit tests and fixtures/mocks where needed: Rust in same-file `#[cfg(test)] mod tests`, TypeScript/Python/C++ in separate neighboring or mirrored test files; missing tests are review FAIL.
- Tests protect behaviour. A test is a meaningful unit test of real behaviour, never hardcoded values or expectations copied from current output to make CI pass. Once a test is merged, changing or deleting it is an exception: the PR must say which test changed and why the old expectation is now wrong (a deliberate behaviour or config change), and the reviewer must check that justification in two separate review passes before PASS. Editing a test only to turn CI green, weakening an assertion, or loosening a floor gets CHANGES.
- Run locally what CI runs, before every push. Install the repo's git hooks in every clone and worktree before the first commit (run the tracked hook with `git -c core.hooksPath=.githooks push`, as this repo documents; it has no install script), and never bypass them with `--no-verify`. Type check with TypeScript 7 (`tsgo`, 7.0 or 7.1) locally before pushing. A PR whose CI fails on format, lint, types or a unit test the hooks would have caught gets CHANGES. This repo has no TypeScript code, so it has no `tsgo` step.

These rules guide new changes; they do not request a repository-wide validation-library or runtime refactor. Keep existing security and owner boundaries. Run the actual formatter, linter and all offline unit tests before pushing; DB, internal-service and end-to-end suites are separate gates.

## Establish the public contract before claiming a capability

Distinguish an implemented backend feature, a published tool and a route available in the
intended venue. Name the evidence that supports each claim. When the venue's live contract
omits a route, preserve its unavailable status rather than suggesting an alternative path.
Resolve disagreements through the [skill's source hierarchy](skills/edel-markets/SKILL.md).

[PR #18](https://github.com/Edel-Finance/edel-ai-config/pull/18) documented capabilities while
explicitly marking their routes unavailable on TestNet; [PR #21](https://github.com/Edel-Finance/edel-ai-config/pull/21)
updated them after publication. The [PR #25 review](https://github.com/Edel-Finance/edel-ai-config/pull/25#issuecomment-6399084520)
checked the generated tool mapping against the public contract and source. These are real
approved decisions; the inspected recent reviews contain no new corrective finding.

## Keep capability and permission separate

A tool name, installed plugin, API-key scope or prompt instruction does not authorize a money
action. Preserve the existing [authentication and owner-approval sequence](skills/edel-markets/AUTH.md)
and explicit owner permission per money action. Human signing and passkey ceremonies stay with
the owner. Review instructions for the authority they imply, including examples that might
accidentally make an owner-only operation appear unattended.

A platform package may expose less than the general skill. Keep its actual boundary explicit:
[ChatGPT instructions](chatgpt/instructions.md) allow public read-only Actions, while
[capability references](skills/edel-markets/CAPABILITIES.md) describe wider public surfaces.
Neither description widens account, environment or financial permission.

## Match platform claims to observed proof

Separate manifest/format inspection, a real client installation, transport/authentication reachability
and an authenticated operation. Success at one layer does not prove the next, or another venue.
[PR #20](https://github.com/Edel-Finance/edel-ai-config/pull/20) recorded real CLI installs separately
from structure checks and unauthenticated MCP responses. Keep that distinction when updating the
[platform status](README.md#platform-status); do not carry an old observation forward as new proof.

## Preserve unknown and refused outcomes

When a read or action fails, report what the documented response establishes and stop at the
existing boundary. Do not invent account state, a missing estimate, an endpoint or an authentication
diagnosis. An unavailable route or refused credential is a reason to disclose the limitation,
not to broaden scopes or substitute someone else's session. Keep this judgment consistent with
[agent safety rules](AGENTS.md#safety) and each platform's narrower instructions.

## Stack related pull requests

Pull requests that belong to one feature, or that depend on each other, are linked with the official `gh stack` extension and land together with `gh stack merge`. A change that is part of such a stack and is opened on its own does not pass review: the reviewer gives CHANGES until it is stacked. Independent changes stay single pull requests.
