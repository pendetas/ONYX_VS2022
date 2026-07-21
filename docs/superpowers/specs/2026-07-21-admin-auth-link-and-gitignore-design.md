# Admin Auth Link and Git Ignore Design

## Goal

Make the admin authentication flow navigable in both directions and keep local development artifacts out of source control.

## Current Behavior

`auth_page/onyx_admin_register.aspx` already offers an `Already have an account? Sign in` link. `auth_page/onyx_Admin_Login.aspx` has no equivalent registration link, even though both pages use the same admin role flow and database user records.

The repository `.gitignore` covers common Visual Studio and local secret files but does not yet ignore the requested agent state, local documentation/tests, temporary files, or generated outputs.

## Design

Add a footer line to the admin login card using the existing `.card-footer` and `.card-footer a` styles:

```html
Don't have an admin account? <a href=".../onyx_admin_register.aspx">Register as an admin</a>
```

Use `ResolveUrl` so the link remains correct when the application is deployed under a virtual path. Do not change login validation or registration behavior.

Extend `.gitignore` with the supplied rules for Visual Studio files, build output, NuGet packages, ASP.NET local data/logs, OS/editor files, agent/tooling state, local docs/tests/output, and `.env` secrets. Existing tracked files remain tracked; the ignore rules only affect untracked files going forward.

## Security Note

The registration page currently permits direct admin account creation. This change only exposes the existing page through navigation; a separate follow-up should add an invitation, secret, or equivalent authorization gate before production use.

## Verification

- A source-contract test fails before the login link and ignore rules are present.
- The focused test passes after implementation.
- All existing source-contract tests pass.
- The Visual Studio solution builds successfully.
- `git check-ignore` confirms representative local artifact paths are ignored.
