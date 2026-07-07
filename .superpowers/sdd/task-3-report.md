# Task 3 Report: Shared Post-Auth Personalization Routing

## Outcome

Task 3 is implemented exactly within the auth-routing scope from the brief. I did not build the personalization page itself.

## TDD Sequence Followed

1. Extended `tests/PersonalizationFlow.Tests.ps1` with the new post-auth routing contract checks.
2. Ran the focused test and confirmed RED:
   - Missing redirect helper
   - Missing `RegisterCustomer(...)`
   - Missing shared redirect usage in the auth entry points
3. Implemented the minimal production changes required by the brief.
4. Re-ran the focused test until GREEN.
5. Ran solution build and fixed one compile issue in the helper without changing task scope.

## Files Changed

- Created `Helpers/PostAuthRedirectHelper.cs`
- Modified `Services/AuthService.cs`
- Modified `auth_page/onyx_login.aspx.cs`
- Modified `auth_page/onyx_register.aspx.cs`
- Modified `auth_page/google_callback.aspx.cs`
- Modified `auth_page/oauth_callback.aspx.cs`
- Modified `ONYX_DDAC.csproj`
- Modified `tests/PersonalizationFlow.Tests.ps1`

## What Changed

### Shared redirect helper

Added `PostAuthRedirectHelper` with the required signatures:

- `GetTarget(Page page, User user, string requestedCustomerTarget) : string`
- `Redirect(Page page, User user, string requestedCustomerTarget = null) : void`

Behavior:

- Null user routes to `~/auth_page/onyx_login.aspx`
- Admin routes to `~/admin_page/onyx_admin_dashboard.aspx`
- Customers who still require personalization route to `~/customer_page/onyx_personalization.aspx`
- Otherwise honors an explicit requested customer target
- Falls back to `~/customer_page/onyx_home.aspx`

### Manual registration auto-login

Added `AuthService.RegisterCustomer(...) : User`, which:

- Reuses existing `Register(...)`
- Throws `InvalidOperationException` with the existing error text when registration fails
- Loads the created user through `_userRepository.GetUserByEmail(email)`
- Returns the created `User` so the register page can establish a session immediately

### Auth page integration

- `onyx_login.aspx.cs`
  - Replaced local role redirect logic with `PostAuthRedirectHelper.Redirect(...)`
  - Preserved the `profile=true` destination override for customers who are already complete

- `onyx_register.aspx.cs`
  - Replaced the old “redirect to login with registered=true” flow
  - Now registers, auto-signs-in, and routes through the shared helper
  - Preserved error display behavior by surfacing `InvalidOperationException.Message`

- `google_callback.aspx.cs`
  - Replaced role redirect with `PostAuthRedirectHelper.Redirect(...)`
  - Left OAuth state, welcome email, and failure handling intact

- `oauth_callback.aspx.cs`
  - Replaced role redirect with `PostAuthRedirectHelper.Redirect(...)`
  - Left provider-specific callback, state, PKCE, welcome email, and failure handling intact

### Project wiring

Added `Helpers\PostAuthRedirectHelper.cs` to `ONYX_DDAC.csproj`.

## Verification

### Focused test

Command:

```powershell
powershell -ExecutionPolicy Bypass -File .\tests\PersonalizationFlow.Tests.ps1
```

Result:

- Passes with `Personalization schema/model source contract passes.`

### Build

Command:

```powershell
& 'C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe' .\ONYX_DDAC.sln /p:Configuration=Debug /p:Platform="Any CPU" /m
```

Result:

- Build succeeded
- `0 Warning(s)`
- `0 Error(s)`

## Notes / Concerns

One compile issue surfaced during build because `Page.Context` was not accessible from the new helper in this project context. I corrected the helper to call `HttpContext.Current.ApplicationInstance.CompleteRequest()` instead, preserving the intended redirect behavior and keeping the contract requirement for `CompleteRequest`.

No other concerns found within Task 3 scope.

## Review Fix Verification

Addressed the follow-up review findings for Task 3:

1. `AuthService.RegisterCustomer(...)` now reloads the newly created user through `UserRepository.GetUserByEmailForWrite(...)` so the post-insert auto-login path does not depend on the read connection.
2. `PostAuthRedirectHelper` now routes `admin`, `owner`, and `staff` to `~/admin_page/onyx_admin_dashboard.aspx`, while preserving customer personalization behavior.
3. `tests/PersonalizationFlow.Tests.ps1` now asserts both the write-side reload contract and the privileged-role routing contract.

Verification rerun after the fixes:

- `powershell -ExecutionPolicy Bypass -File .\tests\PersonalizationFlow.Tests.ps1`
  - Pass: `Personalization schema/model source contract passes.`
- `& 'C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe' .\ONYX_DDAC.sln /p:Configuration=Debug /p:Platform="Any CPU" /m`
  - Pass: `Build succeeded. 0 Warning(s), 0 Error(s).`
