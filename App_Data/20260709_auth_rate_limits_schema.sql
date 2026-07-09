BEGIN;

DROP TABLE IF EXISTS public.auth_rate_limits;

CREATE TABLE public.auth_rate_limits (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  action VARCHAR(50) NOT NULL,
  identity_key VARCHAR(320) NOT NULL,
  attempt_count INTEGER NOT NULL DEFAULT 0 CHECK (attempt_count >= 0),
  window_started_at TIMESTAMP NOT NULL,
  blocked_until TIMESTAMP,
  last_attempt_at TIMESTAMP NOT NULL,
  UNIQUE (action, identity_key)
);

CREATE INDEX ix_auth_rate_limits_blocked_until
  ON public.auth_rate_limits (blocked_until);

COMMIT;
