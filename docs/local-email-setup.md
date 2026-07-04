# Local Email Setup

ONYX keeps SMTP credentials out of `Web.config` on purpose. When the config value starts with `REPLACE_`, the email service reads the matching environment variable instead.

Use this once on each developer machine:

```powershell
.\Scripts\setup-local-email.ps1 -SmtpUsername "support.onyxgaming@gmail.com" -SmtpPassword "<gmail-app-password>"
```

Then restart Visual Studio or IIS Express before testing registration/login email.

If email still does not arrive, check:

- `App_Data/email_debug.log` for `sent` or `failed`
- the recipient inbox spam folder
- whether the Gmail app password was copied without extra spaces

The Gmail app password should be shared privately between teammates, not committed to Git.
