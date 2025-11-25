DROP TABLE delivery_messages;
ALTER TABLE messages ADD COLUMN response JSONB;

SELECT insert_version(1, 1, '1.3', 3, 'Dropped table delivery_messages, added response to messages', '{}');

-- eof
