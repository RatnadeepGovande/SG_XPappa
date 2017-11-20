-- Adding Presence Status to `identities` table
ALTER TABLE identities ADD presence_status INTEGER NON NULL;

-- Adding Last Seen At to `identities` table
ALTER TABLE identities ADD last_seen_at DATETIME;