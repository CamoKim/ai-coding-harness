# Authenticated External Document Access

## Goal

Prevent an agent from declaring an enterprise document unavailable merely because unauthenticated web access fails.

## Rule

For an external work-document or service URL (including Confluence, Jira, Google Drive, and Notion), the agent first checks for a connected official app or connector and its direct-read permission. It uses that route before general web access or asking the user to paste content. Only after confirming that no suitable connection exists or that access is denied may it report the resource unavailable or request a fallback.

## Scope

The rule belongs in global engineering guidance because it applies across repositories. The portable Harness global template carries the same rule so later adoption does not lose it. It neither installs nor manages plugins and does not bypass authorization.

## Verification

Run the Harness source validator after updating the global template and documentation contract.
