BEGIN;

CREATE TABLE IF NOT EXISTS user_oauth_accounts (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    provider VARCHAR(30) NOT NULL,
    provider_user_id VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    email_verified BOOLEAN NOT NULL DEFAULT false,
    display_name VARCHAR(255),
    avatar_url TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_login_at TIMESTAMP,
    CONSTRAINT ux_user_oauth_provider_user UNIQUE (provider, provider_user_id)
);

CREATE INDEX IF NOT EXISTS ix_user_oauth_accounts_user_id
    ON user_oauth_accounts (user_id);

DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name = 'users'
          AND column_name = 'google_sub'
    ) THEN
        INSERT INTO user_oauth_accounts (
            user_id,
            provider,
            provider_user_id,
            email,
            email_verified,
            display_name,
            avatar_url,
            created_at,
            last_login_at)
        SELECT
            id,
            'google',
            google_sub,
            email,
            google_email_verified,
            fullname,
            avatar_url,
            created_at,
            last_login_at
        FROM users
        WHERE google_sub IS NOT NULL
        ON CONFLICT (provider, provider_user_id) DO NOTHING;
    END IF;
END $$;

DROP INDEX IF EXISTS ux_users_google_sub;

ALTER TABLE users
    DROP COLUMN IF EXISTS auth_provider,
    DROP COLUMN IF EXISTS google_sub,
    DROP COLUMN IF EXISTS google_email_verified,
    DROP COLUMN IF EXISTS avatar_url,
    DROP COLUMN IF EXISTS last_login_at;

COMMIT;
