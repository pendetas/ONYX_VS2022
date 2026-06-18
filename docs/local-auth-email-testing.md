# Local Authentication And Email Testing

This guide configures the ONYX ASP.NET Web Forms application for local
registration, Cloudflare Turnstile test mode, OTP verification, PostgreSQL,
and email capture through smtp4dev.

smtp4dev receives messages locally. It does not deliver messages to Gmail or
other real mailboxes.

## 1. Install The Prerequisites

Install and start:

1. Visual Studio 2022 with the **ASP.NET and web development** workload.
2. .NET Framework 4.8 developer tools.
3. PostgreSQL and DBeaver.
4. Docker Desktop using Linux containers.
5. Git.

Clone the repository and switch to the authentication testing branch:

```powershell
git clone https://github.com/pendetas/ONYX_VS2022.git
cd ONYX_VS2022
git switch stanley-auth-testing
```

Open `ONYX_DDAC.sln` in Visual Studio and restore NuGet packages.

## 2. Create Or Select The PostgreSQL Database

The default configuration expects:

```text
Host: localhost
Port: 5432
Database: onyx
Username: postgres
```

Create the `onyx` database if it does not already exist.

In DBeaver:

1. Open the PostgreSQL connection.
2. Right-click **Databases**.
3. Select **Create New Database**.
4. Enter `onyx` as the database name.
5. Select the local PostgreSQL owner, normally `postgres`.
6. Save the database.

If the project database already exists, do not recreate it.

## 3. Configure The Local Database Password

Open `Web.config`. Find both:

```xml
Password=REPLACE_DATABASE_PASSWORD;
```

Replace `REPLACE_DATABASE_PASSWORD` with the password for the local PostgreSQL
user in both `DefaultConnection` and `ReadConnection`.

Example structure:

```xml
<add name="DefaultConnection"
     connectionString="Host=localhost;Port=5432;Database=onyx;Username=postgres;Password=YOUR_LOCAL_PASSWORD;Pooling=true;Minimum Pool Size=1;Maximum Pool Size=100;Keepalive=30;"
     providerName="Npgsql" />
```

Do not commit or push the edited password. Before committing unrelated work,
restore the placeholder:

```text
Password=REPLACE_DATABASE_PASSWORD;
```

If the local database uses a different host, port, database, or username,
update both connection strings accordingly.

## 4. Apply The Existing ONYX Schema

If the database is empty, execute `App_Data/onyx_schema.sql` first.

In DBeaver:

1. Select the `onyx` database in **Database Navigator**.
2. Right-click the database and select **SQL Editor > New SQL Script**.
3. Open `App_Data/onyx_schema.sql` in a text editor.
4. Copy all SQL text from the file.
5. Paste the SQL text into the DBeaver SQL editor.
6. Confirm the editor toolbar shows the `onyx` database.
7. Select **Execute SQL Script** or press `Alt+X`.
8. Confirm the execution completes without errors.

Do not paste the Windows file path into the SQL editor. A path such as
`C:\...\onyx_schema.sql` is not SQL.

## 5. Apply The Authentication Migration

The migration adds:

- `pending_registrations`
- `auth_rate_limits`
- Case-insensitive unique indexes for usernames and email addresses
- OTP expiry and rate-limit indexes

In DBeaver:

1. Select the `onyx` database.
2. Open **SQL Editor > New SQL Script**.
3. Open `App_Data/20260612_auth_security.sql` in a text editor.
4. Copy the complete SQL contents.
5. Paste them into DBeaver.
6. Confirm the active database is `onyx`.
7. Execute the complete script with `Alt+X`.
8. Confirm that the transaction reaches `COMMIT` without errors.
9. Refresh the `public` schema with `F5`.

Verify the migration by running:

```sql
SELECT tablename
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN ('pending_registrations', 'auth_rate_limits')
ORDER BY tablename;
```

Expected rows:

```text
auth_rate_limits
pending_registrations
```

If unique-index creation fails, inspect the `users` table for usernames or
email addresses that differ only by letter case. Resolve those duplicates and
run the migration again.

## 6. Start Docker Desktop

1. Open Docker Desktop.
2. Wait until Docker reports that the engine is running.
3. Confirm Docker works:

```powershell
docker info
```

Docker may print host capability warnings on some Windows installations. The
helper script treats Docker as available when the command exits successfully.

## 7. Start smtp4dev

From PowerShell in the repository root:

```powershell
.\scripts\start-smtp4dev.ps1
```

The script:

1. Checks that Docker is installed and running.
2. Starts the existing `smtp4dev-onyx` container when present.
3. Otherwise creates it with localhost-only port bindings.
4. Prints the SMTP and inbox addresses.

Equivalent Docker command:

```powershell
docker run -d --name smtp4dev-onyx -p 127.0.0.1:3000:80 -p 127.0.0.1:2525:25 rnwood/smtp4dev
```

Useful commands:

```powershell
docker start smtp4dev-onyx
docker stop smtp4dev-onyx
docker ps --filter "name=smtp4dev-onyx"
docker logs smtp4dev-onyx
```

Open the inbox:

```text
http://localhost:3000
```

The ONYX SMTP settings are:

```text
Host: localhost
Port: 2525
SSL: false
Username: blank
Password: blank
```

## 8. Turnstile Local Test Configuration

`Web.config` contains Cloudflare's always-pass visible test site key and
matching test secret key. These are intended for development and work on
localhost.

The site key is rendered by the registration page. The secret key is read only
by `CaptchaService` and must never be placed in ASPX markup or JavaScript.

Current official test-key documentation:

https://developers.cloudflare.com/turnstile/troubleshooting/testing/

Production deployments must replace both test keys securely.

## 9. Run ONYX

1. Open `ONYX_DDAC.sln` in Visual Studio 2022.
2. Restore NuGet packages if Visual Studio requests it.
3. Select the **Debug** configuration.
4. Build the solution.
5. Start the application using IIS Express.
6. Open `auth_page/onyx_register.aspx`.

Local Debug allows HTTP cookies. The Release transform disables debug output,
requires HTTPS cookies, and replaces local development values with
fail-closed deployment placeholders.

## 10. Test Registration And OTP Verification

1. Enter a new username.
2. Use a fake email such as `testuser1@onyx.local`.
3. Enter a password that includes uppercase, lowercase, number, and symbol.
4. Complete the Turnstile test widget.
5. Submit registration.
6. Open `http://localhost:3000`.
7. Open the ONYX verification message.
8. Copy the six-digit OTP.
9. Return to ONYX and submit the OTP.
10. Confirm redirection to the login page.
11. Log in using the registered email or username and registration password.

Use a different username and email for repeated tests because uniqueness is
case-insensitive.

The real `users` row is inserted only after successful OTP verification.
Before verification, only a BCrypt password hash and HMAC OTP hash exist in
`pending_registrations`. Plain OTP values are not stored in the database,
Session, ViewState, or hidden fields.

## 11. Inspect The Database During Testing

Pending registrations:

```sql
SELECT id, username, email, otp_expires_at, otp_attempts, resend_count
FROM pending_registrations
ORDER BY created_at DESC;
```

Completed users:

```sql
SELECT id, username, email, role, created_at
FROM users
ORDER BY created_at DESC;
```

Rate limits:

```sql
SELECT action, identity_key, attempt_count, blocked_until, last_attempt_at
FROM auth_rate_limits
ORDER BY last_attempt_at DESC;
```

Password and OTP hash values are intentionally unreadable. Do not replace them
with plaintext.

## 12. Troubleshooting

### PostgreSQL Password Authentication Failed

`Web.config` still has the placeholder or the wrong local password. Update
both connection strings, stop Visual Studio debugging, and start it again.

### Relation Does Not Exist

Apply `App_Data/onyx_schema.sql` if the base schema is missing, then apply
`App_Data/20260612_auth_security.sql`.

### No Email Appears

1. Run `docker ps --filter "name=smtp4dev-onyx"`.
2. Confirm ports `127.0.0.1:3000` and `127.0.0.1:2525` are published.
3. Confirm `SmtpHost=localhost`, `SmtpPort=2525`, and SSL is `false`.
4. Check the Visual Studio Output window for the exception type.

### smtp4dev Shows `GET /` And `500 Command unrecognised`

An HTTP health probe contacted SMTP port `2525`. This is not an OTP email and
does not mean smtp4dev is broken. Real SMTP sessions use commands such as
`MAIL FROM`, `RCPT TO`, and `DATA`.

### CAPTCHA Verification Failed

Confirm the browser can reach `https://challenges.cloudflare.com` and both
Turnstile values are the matching Cloudflare test pair.

### OTP Expired

The local lifetime is 10 minutes. Request a resend after the 60-second
cooldown or start registration again.

### Maximum OTP Attempts Reached

The maximum is five attempts. Start registration again to generate a new
pending registration.

### Invalid Email Or Password

Use the password entered in the registration form, not the OTP or PostgreSQL
password. Confirm the verified account is in `users` and no longer remains in
`pending_registrations`.

## 13. Security Rules

- Never commit PostgreSQL passwords.
- Never commit Gmail passwords or production SMTP credentials.
- Never commit production Turnstile secret keys.
- Never use the local `OtpHmacSecret` in production.
- smtp4dev catches messages locally and does not deliver real mail.
- Use deployment environment variables, protected IIS configuration, or a
  secret manager for production.
