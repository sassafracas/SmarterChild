CREATE TABLE user_events (
    user_id        INT REFERENCES users (user_id) ON UPDATE CASCADE ON DELETE CASCADE,
    event_id       INT REFERENCES events (event_id) ON UPDATE CASCADE,
    CONSTRAINT user_event_id PRIMARY KEY (user_id, event_id)
);