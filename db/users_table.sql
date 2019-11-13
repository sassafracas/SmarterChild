CREATE TABLE users (
    user_id       INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    name          TEXT,
    discord_id    BIGINT NOT NULL UNIQUE,
    discord_name  TEXT NOT NULL,
    timezone      TEXT NOT NULL
);