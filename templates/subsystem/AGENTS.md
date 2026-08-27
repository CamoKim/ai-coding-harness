# Subsystem Guide

Replace the bracketed prompts with verified subsystem facts. Link to detailed documentation instead of copying it into this file.

## Purpose and Scope

- Purpose: [what this subsystem owns]
- In scope: [primary directories or components]
- Out of scope: [neighboring responsibilities]

## Execution Path

- Entry points: [commands, services, modules, or request handlers]
- Main flow: [concise input-to-output path]
- External dependencies: [services, databases, queues, or shared libraries]

## Architecture Constraints

- [Document dependency direction and component boundaries.]
- [State constraints that are not mechanically enforced elsewhere.]

## Development Commands

- Setup: [command and side effects]
- Run: [command]
- Other project-owned commands: [command and purpose]

## Compatibility Contracts

- [List public APIs, schemas, configuration, storage, messaging, or data contracts.]
- [Link to the source of truth and identify affected consumers.]

## Verification

- [Record this subsystem's project-owned verification command, if any.]
- Fast: [command or unsupported]
- Full: [command or unsupported]
- [Explain when full verification is required and what environment it needs.]
- [State material limitations, permitted skips, and checks that require another subsystem.]

## Stateful or Destructive Operations

- [List migrations, imports, activation, deployment, reset, or production operations.]
- [State required approval, backup, isolation, or rollback conditions.]
- These operations must not run as part of default verification.

## Sources of Truth and Generated Artifacts

- Source of truth: [files or directories]
- Generated artifacts: [generation command and direct-edit policy]
- [State how drift is detected.]

## Environment Limitations

- [Required tools and supported versions]
- [Local-only files, credentials, ports, networks, volumes, or platform constraints]
- [Known reasons a verification level may be unsupported]
