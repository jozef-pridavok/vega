INSERT INTO users(user_id, email, password_hash, roles)
VALUES('a5d56ee2-e7b3-4be4-9729-a58d2de65835', 'fake@gmail.com', 'hash', ARRAY[1, 2])
ON CONFLICT (user_id) DO UPDATE SET
    email = EXCLUDED.email,
    password_hash = EXCLUDED.password_hash,
    roles = EXCLUDED.roles;
;

INSERT INTO installations(installation_id, user_id, device_token, device_info, locale, updated_at, expires_at)
VALUES('0147d5c4-fee3-410e-9116-bcc28a0c5089', 'a5d56ee2-e7b3-4be4-9729-a58d2de65835', 'device_token1', '{}'::JSONB, 'en', NOW(), '2030-01-01')
ON CONFLICT (installation_id) DO UPDATE SET
    user_id = EXCLUDED.user_id,
    device_token = EXCLUDED.device_token,
    device_info = EXCLUDED.device_info,
    locale = EXCLUDED.locale;

INSERT INTO sessions(session_id, user_id, installation_id, expires_at)
VALUES('8225a08a-5bdd-4dae-8f95-5983ef43e4da', 'a5d56ee2-e7b3-4be4-9729-a58d2de65835', '0147d5c4-fee3-410e-9116-bcc28a0c5089', '2030-01-01')
ON CONFLICT (session_id) DO UPDATE SET
    user_id = EXCLUDED.user_id,
    installation_id = EXCLUDED.installation_id,
    expires_at = EXCLUDED.expires_at;

SELECT * FROM user_sessions;
