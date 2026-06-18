BEGIN;

CREATE UNIQUE INDEX IF NOT EXISTS ux_users_username_ci
    ON users (LOWER(username));

CREATE UNIQUE INDEX IF NOT EXISTS ux_users_email_ci
    ON users (LOWER(email));

CREATE TABLE IF NOT EXISTS pending_registrations (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    fullname VARCHAR(100) NOT NULL,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    address TEXT,
    dob DATE,
    phone_number VARCHAR(30),
    otp_hash VARCHAR(255) NOT NULL,
    otp_expires_at TIMESTAMP NOT NULL,
    otp_attempts INTEGER NOT NULL DEFAULT 0 CHECK (otp_attempts >= 0),
    resend_count INTEGER NOT NULL DEFAULT 0 CHECK (resend_count >= 0),
    last_otp_sent_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT (NOW() AT TIME ZONE 'UTC')
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_pending_registrations_username_ci
    ON pending_registrations (LOWER(username));

CREATE UNIQUE INDEX IF NOT EXISTS ux_pending_registrations_email_ci
    ON pending_registrations (LOWER(email));

CREATE INDEX IF NOT EXISTS ix_pending_registrations_expires_at
    ON pending_registrations (otp_expires_at);

CREATE TABLE IF NOT EXISTS auth_rate_limits (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    action VARCHAR(50) NOT NULL,
    identity_key VARCHAR(320) NOT NULL,
    attempt_count INTEGER NOT NULL DEFAULT 0 CHECK (attempt_count >= 0),
    window_started_at TIMESTAMP NOT NULL,
    blocked_until TIMESTAMP,
    last_attempt_at TIMESTAMP NOT NULL,
    UNIQUE (action, identity_key)
);

CREATE INDEX IF NOT EXISTS ix_auth_rate_limits_blocked_until
    ON auth_rate_limits (blocked_until);

COMMIT;
