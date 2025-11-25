-- Vymazanie existujúcich údajov
DELETE FROM client_sellers;
DELETE FROM client_payments;
DELETE FROM leaflets;
DELETE FROM user_coupons;
DELETE FROM loyalty_transactions;
DELETE FROM program_rewards;
DELETE FROM receipts;
DELETE FROM product_orders;
DELETE FROM pos;
DELETE FROM user_cards;
DELETE FROM programs;
DELETE FROM cards;
DELETE FROM coupons;
DELETE FROM locations;
DELETE FROM product_items;
DELETE FROM product_sections;
DELETE FROM product_offers;
DELETE FROM reservation_dates;
DELETE FROM reservation_slots;
DELETE FROM reservations;

-- Pridanie príkladových dát pre tabuľku 'clients'
INSERT INTO clients (client_id, name, logo, color, blocked, countries, settings, meta, created_at, updated_at)
VALUES
    ('client1', 'Lidl', 'lidl_logo.png', '0000FF', false, ARRAY['sk', 'py'], '{"setting1": "value1", "setting2": "value2"}', '{"qrCodeScanning": {"provider": 1, "providerId": ["35793783"], "createNewUserCard": true, "ratio":0.001}}', NOW(), NOW()),
    ('client2', 'Tesco', 'tesco_logo.png', 'FF0000', false, ARRAY['us', 'sk', 'py'], '{"setting1": "value1", "setting2": "value2"}', '{"meta_key": "meta_value"}', NOW(), NOW()),
    ('client3', 'Albert', 'albert_logo.png', '00FF00', false, ARRAY['us', 'sk', 'py'], '{"setting1": "value1", "setting2": "value2"}', '{"qrCodeScanning": {"provider": 2, "providerId": ["80124528"], "createNewUserCard": true}}', NOW(), NOW())
ON CONFLICT (client_id) DO NOTHING;

-- Pridanie príkladových dát pre tabuľku 'locations'
INSERT INTO locations (location_id, client_id, name, address, country, city, postal_code, latitude, longitude, meta, created_at, updated_at)
VALUES
    ('location1', 'client1', 'Lidl Store 1', '123 Main Street', 'SK', 'Bratislava', '12345', 48.1234, 17.9876, '{"meta_key": "meta_value"}', NOW(), NOW()),
    ('location2', 'client1', 'Lidl Store 2', '456 Elm Street', 'SK', 'Kosice', '98765', 48.5678, 21.5432, NULL, NOW(), NOW()),
    ('location3', 'client2', 'Tesco Store 1', '789 Oak Street', 'US', 'New York', '54321', 40.6789, -73.9876, NULL, NOW(), NOW()),
    ('location4', 'client2', 'Tesco Store 2', '321 Maple Street', 'US', 'Los Angeles', '67890', 34.1234, -118.9876, '{"meta_key": "meta_value"}', NOW(), NOW()),
    ('location5', 'client3', 'Albert Store 1', '987 Pine Street', 'US', 'Chicago', '43210', 41.5678, -87.5432, NULL, NOW(), NOW())
ON CONFLICT (location_id) DO NOTHING;

-- Pridanie príkladových dát pre tabuľku 'users'
INSERT INTO users (user_id, user_type, login, email, password_hash, password_salt, nick, gender, yob, language, country, theme, email_verified, blocked, created_at, updated_at)
VALUES 
    ('user1', 1, 'user1login', 'user1@example.com', 'passwordhash1', 'passwordsalt1', 'user1nick', 1, 2000, 'sk', 'sk', 2, true, false, NOW(), NOW()), 
    ('user2', 1, 'user2login', 'user2@example.com', 'passwordhash2', 'passwordsalt2', 'user2nick', 2, 2001, 'en', 'GB', 1, false, false, NOW(), NOW()), 
    ('user3', 2, 'user3login', 'user3@example.com', 'passwordhash3', 'passwordsalt3', 'user3nick', 1, 2002, 'en', 'CA', 3, false, true, NOW(), NOW()), 
    ('user4', 2, 'user4login', 'user4@example.com', 'passwordhash4', 'passwordsalt4', 'user4nick', 2, 2003, 'en', 'AU', 1, false, false, NOW(), NOW()), 
    ('user5', 1, 'user5login', 'user5@example.com', 'passwordhash5', 'passwordsalt5', 'user5nick', 2, 2004, 'en', 'NZ', 2, true, false, NOW(), NOW())
ON CONFLICT (user_id) DO NOTHING;

INSERT INTO cards (card_id, client_id, code_type, name, logo, color, blocked, countries, meta, created_at, updated_at)
VALUES 
    ('card1', 'client1', 7, 'Card 1', 'card1logo.png', '00FF00', false, ARRAY['US'], '{"key": "value"}', NOW(), NOW()),
    ('card2', 'client2', 7, 'Card 2', 'card2logo.png', 'FF0000', false, ARRAY['US', 'CA'], '{"key": "value"}', NOW(), NOW()),
    ('card3', 'client3', 7, 'Card 3', 'card3logo.png', '0000FF', false, ARRAY['PY'], '{"key": "value"}', NOW(), NOW()),
    ('card4', NULL, 7, 'Card 4', 'card4logo.png', '800080', false, ARRAY['GB', 'FR'], '{"key": "value"}', NOW(), NOW()),
    ('card5', NULL, 7, 'Card 5', 'card5logo.png', 'FFA500', false, ARRAY['AU'], '{"key": "value"}', NOW(), NOW()),
    ('card6', NULL, 7, 'Card 6', 'card6logo.png', 'FFFF00', false, ARRAY['AU', 'NZ'], '{"key": "value"}', NOW(), NOW()),
    ('card7', NULL, 7, 'Card 7', 'card7logo.png', '0000FF', false, ARRAY['CA'], '{"key": "value"}', NOW(), NOW()),
    ('card8', NULL, 7, 'Card 8', 'card8logo.png', 'FF0000', false, ARRAY['CA', 'US'], '{"key": "value"}', NOW(), NOW()),
    ('card9', NULL, 7, 'Card 9', 'card9logo.png', '008000', false, ARRAY['NZ'], '{"key": "value"}', NOW(), NOW()),
    ('card10', NULL, 7, 'Card 10', 'card10logo.png', '800080', false, ARRAY['NZ', 'AU'], '{"key": "value"}', NOW(), NOW())
ON CONFLICT (card_id) DO NOTHING;

-- Pridanie príkladových dát pre tabuľku 'user_cards'
INSERT INTO user_cards (user_card_id, user_id, card_id, client_id, code_type, number, name, notes, logo, color, front, back, meta, touched_at, created_at, updated_at)
VALUES 
    ('uc11', 'user1', 'card1', 'client1', 7, '1234567890', 'Card 1', 'notes', 'card1logo.png', '00FF00', 'front.jpg', 'back.jpg', '{"key": "value"}', NOW(), NOW(), NOW()),
    ('uc12', 'user1', 'card1', 'client1', 7, '0987654321', 'Card 2', 'notes', 'card2logo.png', 'FF0000', 'front.jpg', 'back.jpg', '{"key": "value"}', NOW(), NOW(), NOW()),
    ('uc13', 'user1', 'card2', 'client2', 7, '1111111111', 'Card 3', 'notes', 'card3logo.png', '0000FF', 'front.jpg', 'back.jpg', '{"key": "value"}', NOW(), NOW(), NOW()),
    ('uc14', 'user1', 'card4', NULL, 7, '2222222222', 'Card 4', 'notes', 'card4logo.png', '800080', 'front.jpg', 'back.jpg', '{"key": "value"}', NOW(), NOW(), NOW()),
    ('uc21', 'user2', 'card1', 'client1', 7, '3333333333', 'Card 1', 'notes', 'card1logo.png', '00FF00', 'front.jpg', 'back.jpg', '{"key": "value"}', NOW(), NOW(), NOW()),
    ('uc22', 'user2', 'card2', 'client2', 7, '4444444444', 'Card 6', 'notes', 'card6logo.png', 'FFFF00', 'front.jpg', 'back.jpg', '{"key": "value"}', NOW(), NOW(), NOW()),
    ('uc23', 'user2', 'card7', NULL, 7, '5555555555', 'Card 7', 'notes', 'card7logo.png', '0000FF', 'front.jpg', 'back.jpg', '{"key": "value"}', NOW(), NOW(), NOW())
ON CONFLICT (user_card_id) DO NOTHING;

-- Pridanie príkladových dát pre tabuľku 'installations'
INSERT INTO installations (installation_id, user_id, device_token, device_info, locale, expires_at, created_at, updated_at)
VALUES 
    ('installation1', 'user1', 'deviceToken1', '{"key": "value"}', 'en_US', NULL, NOW(), NOW()),
    ('installation2', 'user2', 'deviceToken2', '{"key": "value"}', 'en_GB', NULL, NOW(), NOW())
ON CONFLICT (installation_id) DO NOTHING;

-- Pridanie príkladových dát pre tabuľku 'sessions'
INSERT INTO sessions (session_id, user_id, installation_id, expires_at, created_at, updated_at)
VALUES 
    ('session1', 'user1', 'installation1', NOW() + INTERVAL '1 year', NOW(), NOW()),
    ('session2', 'user2', 'installation2', NOW() + INTERVAL '1 year', NOW(), NOW())
ON CONFLICT (session_id) DO NOTHING;

-- Pridanie príkladových dát pre tabuľku 'programs'
INSERT INTO programs (program_id, client_id, card_id, location_id, type, name, description, image, image_bh, color, countries, rank, starting_at, ending_at, meta, created_at, updated_at)
VALUES 
    ('program1', 'client1', 'card1', NULL, 1, 'Program reach 1', 'Description of program 1', 'program1.jpg', 'program1_bh.jpg', 'blue', ARRAY['us', 'sk', 'py'], 1, '2023-04-01 00:00:00+00', '2099-04-30 23:59:59+00', '{"plural": {"one": "{} bod", "few":"{} body", "other":"{} bodov"}, "actions": {"addition": "Pridať body", "subtraction": "Vydať odmenu"} }', NOW(), NOW()),
    ('program2', 'client2', 'card2', NULL, 1, 'Program reach 2', 'Description of program 2', 'program2.jpg', 'program2_bh.jpg', 'green', ARRAY['us', 'sk', 'py'], 2, '2023-04-01 00:00:00+00', '2099-04-30 23:59:59+00', '{"plural": {"one": "{} point", "other":"{} points"}", actions": {"addition": "Pridať body", "subtraction": "Vydať odmenu"} }', NOW(), NOW()),
    ('program3', 'client3', 'card3', NULL, 2, 'Program collect 3', 'Description of program 3', 'program3.jpg', 'program3_bh.jpg', 'red', ARRAY['us', 'ca', 'sk', 'py'], 1, '2023-04-01 00:00:00+00', '2099-04-30 23:59:59+00', '{"plural": {"one": "{} punto", "other":"{} puntos"}, "actions": {"addition": "Pridať body", "subtraction": "Vydať odmenu"} }', NOW(), NOW()),
    ('program4', 'client2', 'card2', NULL, 2, 'Program collect 4', 'Description of program 4', 'program4.jpg', 'program4_bh.jpg', 'purple', ARRAY['ca'], 2, '2023-04-01 00:00:00+00', '2099-04-30 23:59:59+00', '{"plural": {"one": "{} bod", "few":"{} body", "other":"{} bodov"}, "actions": {"addition": "Pridať body", "subtraction": "Vydať odmenu"} }', NOW(), NOW()),
    ('program5', 'client1', 'card1', NULL, 3, 'Program credit 5', 'Description of program 5', 'program5.jpg', 'program5_bh.jpg', 'orange', ARRAY['us', 'sk', 'py'], 3, '2023-04-01 00:00:00+00', '2099-04-30 23:59:59+00', '{"plural": {"one": "{} point", "other":"{} points"}, "actions": {"addition": "Pridať vstupy", "subtraction": "Odpočítať vstup"} }', NOW(), NOW())
ON CONFLICT (program_id) DO NOTHING;

-- Pridanie príkladových dát pre tabuľku 'program_rewards'
INSERT INTO program_rewards (program_reward_id, program_id, name, description, image, image_bh, points, rank, meta, valid_from, valid_to, created_at, updated_at)
VALUES 
    ('reward1', 'program1', 'Reward 1', 'Description of reward 1', 'http://via.placeholder.com/250x250', 'LWNm.*~qfQ~q~qxufQxufQfQfQfQ', 100, 1, '{"meta_key": "meta_value"}', '2023-04-01 00:00:00+00', NULL, NOW(), NOW()),
    ('reward2', 'program1', 'Reward 2', 'Description of reward 2', 'https://picsum.photos/id/63/300/300', 'L~LIrm,sr@#:|_w{WVsV;jWVX6oL', 200, 2, NULL, NULL, NULL, NOW(), NOW()),
    ('reward3', 'program2', 'Reward 3', 'Description of reward 3', 'https://picsum.photos/id/63/300/300', 'L~P5[b?Goy-o~Sx@kCx[thShWEof', 150, 1, '{"meta_key": "meta_value"}', '2043-04-01 00:00:00+00', '2043-04-30 23:59:59+00', NOW(), NOW()),
    ('reward4', 'program2', 'Reward 4', 'Description of reward 4', 'https://picsum.photos/id/152/300/300', 'LTEel^^nV[WU$-xcWAn-9:NFj]ax', 250, 2, NULL, '2023-04-01 00:00:00+00', '2043-04-30 23:59:59+00', NOW(), NOW())
ON CONFLICT (program_reward_id) DO NOTHING;

-- Pridanie príkladových dát pre tabuľku 'program_rewards' pre 'client2'
INSERT INTO program_rewards (program_reward_id, program_id, name, description, image, image_bh, points, rank, meta, valid_from, valid_to, created_at, updated_at)
VALUES 
    ('reward5', 'program3', 'Reward 5', 'Description of reward 5', 'http://via.placeholder.com/250x250', '6P!P8eP=pP~p~p~p~p', 300, 1, '{"meta_key": "meta_value"}', '2023-04-01 00:00:00+00', NULL, NOW(), NOW()),
    ('reward6', 'program3', 'Reward 6', 'Description of reward 6', 'https://picsum.photos/id/63/300/300', '6~6~6~6~6~6~6~6', 400, 2, NULL, NULL, NULL, NOW(), NOW()),
    ('reward7', 'program4', 'Reward 7', 'Description of reward 7', 'https://picsum.photos/id/63/300/300', '6!6!6!6!6!6!6!6', 350, 1, '{"meta_key": "meta_value"}', '2043-04-01 00:00:00+00', '2043-04-30 23:59:59+00', NOW(), NOW()),
    ('reward8', 'program4', 'Reward 8', 'Description of reward 8', 'https://picsum.photos/id/152/300/300', '6d6d6d6d6d6d6d', 450, 2, NULL, '2023-04-01 00:00:00+00', '2043-04-30 23:59:59+00', NOW(), NOW())
ON CONFLICT (program_reward_id) DO NOTHING;

-- Pridanie príkladových dát pre tabuľku 'coupons' pre všetkých klientov
INSERT INTO coupons (coupon_id, client_id, location_id, type, name, description, code, codes, image, image_bh, color, countries, rank, starting_at, ending_at, created_at, updated_at)
VALUES
    ('c6', 'client1', NULL, 1, '15% off', '15% off all products', 'UVWXYZ', ARRAY['UVWXYZ', '123456'], 'https://example.com/c6.png', 'c6', 'yellow', ARRAY['US', 'CA'], 1, NOW() - INTERVAL '1 day', NOW() + INTERVAL '30 days', NOW(), NOW()),
    ('c7', 'client1', NULL, 2, 'Free gift', 'Get a free gift with every purchase', 'ABCDEF', ARRAY['ABCDEF'], 'https://example.com/c7.png', 'c7', 'pink', ARRAY['GB'], 2, NOW() - INTERVAL '2 days', NOW() + INTERVAL '60 days', NOW(), NOW()),
    ('c8', 'client2', NULL, 1, '10% off', '10% off all products online', 'GHIJKL', ARRAY['GHIJKL', 'MNOPQR'], 'https://example.com/c8.png', 'c8', 'blue', ARRAY['FR', 'DE'], 3, NOW() - INTERVAL '3 days', NOW() + INTERVAL '45 days', NOW(), NOW()),
    ('c9', 'client2', NULL, 2, 'Free shipping', 'Free shipping on all orders', 'STUVWX', ARRAY['STUVWX'], 'https://example.com/c9.png', 'c9', 'green', ARRAY['GB'], 2, NOW() - INTERVAL '4 days', NOW() + INTERVAL '90 days', NOW(), NOW()),
    ('c10', 'client3', NULL, 1, '20% off', '20% off all products', 'YZ0123', ARRAY['YZ0123', '456789'], 'https://example.com/c10.png', 'c10', 'purple', ARRAY['US', 'CA'], 1, NOW() - INTERVAL '5 days', NOW() + INTERVAL '75 days', NOW(), NOW())
ON CONFLICT (coupon_id) DO NOTHING;

-- Pridanie príkladových dát pre tabuľku 'user_coupons' pre všetkých vygenerovaných používateľov
INSERT INTO user_coupons (user_coupon_id, user_id, client_id, coupon_id, created_at, updated_at)
VALUES
    ('uc2_1', 'user2', 'client1', 'c6', NOW(), NOW()),
    ('uc2_2', 'user2', 'client1', 'c7', NOW(), NOW()),
    ('uc2_3', 'user2', 'client2', 'c8', NOW(), NOW()),
    ('uc3_1', 'user3', 'client1', 'c9', NOW(), NOW()),
    ('uc3_2', 'user3', 'client3', 'c10', NOW(), NOW()),
    ('uc4_1', 'user4', 'client2', 'c6', NOW(), NOW()),
    ('uc5_1', 'user5', 'client1', 'c7', NOW(), NOW()),
    ('uc5_2', 'user5', 'client2', 'c8', NOW(), NOW())
ON CONFLICT (user_coupon_id) DO NOTHING;

-- Pridanie príkladových dát pre tabuľku 'leaflets'
INSERT INTO leaflets(leaflet_id, client_id, location_id, country, name, rank, valid_from, valid_to, thumbnail, thumbnail_bh, leaflet, pages, pages_bh, meta, created_at, updated_at)
VALUES
    ('4', 'client1', NULL, 'SK', 'Leaflet4', 1, '2023-07-01', '2023-07-31', 'https://example.com/leaf4_thumb.jpg', '4_thumb', 'https://example.com/leaf4.jpg',
     ARRAY['https://example.com/page1.jpg', 'https://example.com/page2.jpg'], ARRAY['1234', '5678'],
     '{"description": "This is a leaflet about our products."}', NOW(), NOW()),
    ('5', 'client2', NULL, 'US', 'Leaflet5', 2, '2023-08-01', '2023-08-31', 'https://example.com/leaf5_thumb.jpg', '5_thumb', 'https://example.com/leaf5.jpg',
     ARRAY['https://example.com/page1.jpg', 'https://example.com/page2.jpg', 'https://example.com/page3.jpg'], ARRAY['abcd', 'efgh', 'ijkl'],
     '{"description": "This is a leaflet about our services."}', NOW(), NOW()),
    ('6', 'client3', NULL, 'PY', 'Leaflet6', 1, '2023-09-01', '2023-09-30', 'https://example.com/leaf6_thumb.jpg', '6_thumb', 'https://example.com/leaf6.jpg',
     ARRAY['https://example.com/page1.jpg', 'https://example.com/page2.jpg', 'https://example.com/page3.jpg', 'https://example.com/page4.jpg'], ARRAY['mnop', 'qrst', 'uvwx', 'yz01'],
     '{"description": "This is a leaflet about our promotions."}', NOW(), NOW())
ON CONFLICT (leaflet_id) DO NOTHING;

