CREATE TABLE IF NOT EXISTS user_personalization_profiles (
    user_id BIGINT PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    gaming_style VARCHAR(40) NOT NULL,
    preferred_categories TEXT NOT NULL,
    priorities TEXT NOT NULL,
    budget_range VARCHAR(40) NOT NULL,
    setup_goal VARCHAR(60) NOT NULL,
    completed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_user_personalization_completed
    ON user_personalization_profiles (completed_at);

ALTER TABLE user_personalization_profiles
    ADD COLUMN IF NOT EXISTS comfort_preferences TEXT NOT NULL DEFAULT '';

ALTER TABLE user_personalization_profiles
    ADD COLUMN IF NOT EXISTS performance_preferences TEXT NOT NULL DEFAULT '';

ALTER TABLE user_personalization_profiles
    ADD COLUMN IF NOT EXISTS setup_constraints TEXT NOT NULL DEFAULT '';
