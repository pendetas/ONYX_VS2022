# Admin Auth Link and Git Ignore Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans (inline) to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a visible admin-registration path from the admin login page and ignore local development artifacts and secrets.

**Architecture:** Reuse the existing admin auth pages and footer styles. Add navigation only; do not change authentication or registration behavior. Extend the existing `.gitignore` with the requested local output patterns without duplicating its existing secret rules.

**Tech Stack:** ASP.NET Web Forms, C#, HTML/CSS, PowerShell source-contract tests, Git ignore rules.

## Constraints

- Build the registration URL with `ResolveUrl("~/auth_page/onyx_admin_register.aspx")`.
- Do not change login validation, password handling, session setup, or admin account creation.
- Preserve the existing ONYX dark footer styling.
- Existing tracked files under ignored directories remain tracked; the new rules affect untracked files going forward.
- Keep admin registration behavior unchanged in this task; hardening it behind an invitation or authorization gate is a separate follow-up.
- Preserve unrelated working-tree changes.

## Tasks

- [ ] **1. Add failing source-contract checks.** Extend `Tests/AdminRegistration.Tests.ps1` to load the admin-login markup and `.gitignore`, then assert that the login contains the admin-registration prompt/link and that `.agents/`, `.codex/`, `docs/`, `tests/`, `outputs/`, and `.env.*` are ignored. Run the test and confirm it fails before implementation.

- [ ] **2. Implement the approved changes.** Replace the admin-login footer with `Don't have an admin account? Register as an admin`, linking through `ResolveUrl` to `onyx_admin_register.aspx`. Append the missing `tmp/`, `outputs/`, `docs/`, and `tests/` ignore section while retaining existing agent-state and secret rules. Re-run the focused contract test and confirm it passes.

- [ ] **3. Verify and commit.** Run all PowerShell source-contract tests, `git check-ignore` against representative local files, `git diff --check`, and the Debug MSBuild build. Stage only the login page, `.gitignore`, and focused test, then commit as `feat: connect admin login to registration`.

## Acceptance Criteria

- The admin login visibly offers a registration link that resolves to the existing admin registration page.
- Existing admin login and registration logic is unchanged.
- Requested local agent, documentation/test, generated-output, and secret patterns are present in `.gitignore`.
- Focused and full verification passes, with no unrelated files staged.
