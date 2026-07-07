CREATE TABLE IF NOT EXISTS catalog_search_events (
    catalog_search_event_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id BIGINT NOT NULL,
    search_term TEXT NOT NULL,
    inferred_category VARCHAR(50),
    searched_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_catalog_search_events_user
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_catalog_search_events_user_time
    ON catalog_search_events (user_id, searched_at DESC);

CREATE INDEX IF NOT EXISTS idx_catalog_search_events_user_category
    ON catalog_search_events (user_id, inferred_category)
    WHERE inferred_category IS NOT NULL;
