# Coding standards

Use these judgments when changing public skills and client documentation.
[AGENTS.md](AGENTS.md) remains authoritative for scope, security and owner permission.
Mechanical checks belong in existing tooling, not in this review guide.

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
