CREATE TABLE IF NOT EXISTS faqs (
    id          SERIAL PRIMARY KEY,
    question    TEXT NOT NULL,
    answer      TEXT NOT NULL,
    category    TEXT NOT NULL DEFAULT 'general',
    sort_order  INTEGER NOT NULL DEFAULT 100
);
