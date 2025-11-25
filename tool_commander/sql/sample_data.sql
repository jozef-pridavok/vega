INSERT INTO clients (client_id, name, logo, logo_bh, color, countries, settings, meta, created_at, updated_at)
VALUES 
('client1', 'Client 1', 'c1.jpg', 'LqRMMPs9Xmkqs:jubHfk_MS#nNi_', '#FFFFFF', ARRAY['sk', 'py'], '{ "description": {"en": "Description of my business", "sk": "Popis mojeho obchodu"}, "phone": "+00000000", "email": "contact@domain.tld", "web": "https://www.domain.tld" }', '{"accountPrefix": "c1", "qrCodeScanning": {"provider": 1, "providerId": ["35793783"], "createNewUserCard": true, "ratio":0.001}}', NOW(), NOW()),
('client2', 'Client 2', 'c2.jpg', 'LIDC2AofE1WoxuayWBay0KWV?Hof', '#000000', ARRAY['us', 'sk', 'py'], '{ "description": {"en": "Description of my business", "sk": "Popis mojeho obchodu"}, "phone": "+00000000", "email": "contact@domain.tld", "web": "https://www.domain.tld" }', '{"accountPrefix": "c2"}', NOW(), NOW()),
('client3', 'Client 3', 'c3.jpg', 'LrS$7PoLf+oLoffQfQfQysfle.bH', '#1529df', ARRAY['us', 'sk', 'py'], '{ "description": {"en": "Description of my business", "sk": "Popis mojeho obchodu"}, "phone": "+00000000", "email": "contact@domain.tld", "web": "https://www.domain.tld" }', '{"accountPrefix": "c3", "qrCodeScanning": {"provider": 2, "providerId": ["80124528"], "createNewUserCard": true}}', NOW(), NOW())
ON CONFLICT (client_id) DO NOTHING;

INSERT INTO
    locations (
        location_id,
        client_id,
        type,
        rank,
        name,
        address_line_1,
        city,
        zip,
        state,
        country,
        phone,
        email,
        website,
        latitude,
        longitude,
        meta,
        created_at,
        updated_at
    )
VALUES (
        'loc1',
        'client2',
        1,
        1,
        'Store 1',
        '123 Main St',
        'Cityville',
        '12345',
        'Stateville',
        'US',
        '123-456-7890',
        'store1@example.com',
        'https://www.store1.com',
        40.7128,
        -74.0060,
        '{"key": "value"}',
        NOW(),
        NOW()
    ),
    (
        'loc2',
        'client2',
        1,
        2,
        'Store 2',
        '456 Elm St',
        'Townville',
        '54321',
        'Stateville',
        'US',
        '987-654-3210',
        'store2@example.com',
        'https://www.store2.com',
        34.0522,
        -118.2437,
        '{"key": "value"}',
        NOW(),
        NOW()
    ),
    (
        'loc3',
        'client2',
        2,
        1,
        'Warehouse 1',
        '789 Warehouse Ave',
        'Industrial City',
        '67890',
        'Stateville',
        'US',
        '555-555-5555',
        'warehouse1@example.com',
        'https://www.warehouse1.com',
        42.3601,
        -71.0589,
        '{"key": "value"}',
        NOW(),
        NOW()
    ),
    (
        'loc4',
        'client2',
        2,
        2,
        'Warehouse 2',
        '987 Depot St',
        'Logistics Town',
        '98765',
        'Stateville',
        'US',
        '222-222-2222',
        'warehouse2@example.com',
        'https://www.warehouse2.com',
        33.4484,
        -112.0740,
        '{"key": "value"}',
        NOW(),
        NOW()
    ),
    (
        'loc5',
        'client2',
        1,
        3,
        'Store 3',
        '789 Oak Rd',
        'Villageville',
        '34567',
        'Stateville',
        'US',
        '333-333-3333',
        'store3@example.com',
        'https://www.store3.com',
        39.7392,
        -104.9903,
        '{"key": "value"}',
        NOW(),
        NOW()
    ) ON CONFLICT (location_id) DO NOTHING;

INSERT INTO
    locations (
        location_id,
        client_id,
        type,
        rank,
        name,
        address_line_1,
        city,
        zip,
        state,
        country,
        phone,
        email,
        website,
        latitude,
        longitude,
        meta,
        created_at,
        updated_at
    )
VALUES (
        'loc6',
        'client1',
        1,
        4,
        'Obchod 4',
        'Javorová ulica 6/A',
        'Mestoville',
        '45678',
        'Štátoville',
        'SK',
        '555-555-555',
        'obchod4@example.com',
        'https://www.obchod4.sk',
        48.1486,
        17.1077,
        '{"key": "value"}',
        NOW(),
        NOW()
    ),
    (
        'loc7',
        'client1',
        2,
        3,
        'Sklad 3',
        'Skladová ulica 77',
        'Priemyslové Mesto',
        '98765',
        'Štátoville',
        'SK',
        '222-222-222',
        'sklad3@example.com',
        'https://www.sklad3.sk',
        48.1951,
        16.6068,
        '{"key": "value"}',
        NOW(),
        NOW()
    ),
    (
        'loc8',
        'client1',
        1,
        5,
        'Obchod 5',
        'Dubová ulica 8',
        'Dedinkoville',
        '34567',
        'Štátoville',
        'SK',
        '333-333-333',
        'obchod5@example.com',
        'https://www.obchod5.sk',
        48.6690,
        17.6990,
        '{"key": "value"}',
        NOW(),
        NOW()
    ),
    (
        'loc9',
        'client1',
        2,
        4,
        'Sklad 4',
        'Skladová ulica 9/99',
        'Priemyslové Mesto',
        '98765',
        'Štátoville',
        'SK',
        '222-222-222',
        'sklad4@example.com',
        'https://www.sklad4.sk',
        49.1951,
        16.6068,
        '{"key": "value"}',
        NOW(),
        NOW()
    ),
    (
        'loc10',
        'client1',
        1,
        6,
        'Obchod 6',
        'Dubová ulica 10',
        'Dedinkoville',
        '34567',
        'Štátoville',
        'SK',
        '333-333-333',
        'obchod6@example.com',
        'https://www.obchod6.sk',
        48.6690,
        19.6990,
        '{"key": "value"}',
        NOW(),
        NOW()
    ) ON CONFLICT (location_id) DO NOTHING;

UPDATE locations
SET
    opening_hours = '{ "mon": "08:00-18:00", "tue": "09:00-13:00", "wed": "08:00-18:00", "fri": "08:00-18:00"}'
WHERE
    location_id = 'loc7';

UPDATE locations
SET
    opening_hours_exceptions = '{ "20230903": "closed", "20230909": "08:00-12:00" }'
WHERE
    location_id = 'loc7';

INSERT INTO
    locations (
        location_id,
        client_id,
        type,
        rank,
        name,
        address_line_1,
        city,
        zip,
        state,
        country,
        phone,
        email,
        website,
        latitude,
        longitude,
        meta,
        created_at,
        updated_at
    )
VALUES (
        'loc11',
        'client3',
        1,
        1,
        'Tienda 1',
        '123 Calle Principal',
        'Ciudadville',
        '12345',
        'Estadoville',
        'PY',
        '123-456-789',
        'tienda1@example.com',
        'https://www.tienda1.com',
        -23.4425,
        -58.4438,
        '{"key": "value"}',
        NOW(),
        NOW()
    ),
    (
        'loc12',
        'client3',
        1,
        2,
        'Tienda 2',
        '456 Calle Elm',
        'Pueblovilla',
        '54321',
        'Estadoville',
        'PY',
        '987-654-321',
        'tienda2@example.com',
        'https://www.tienda2.com',
        -25.2637,
        -57.5759,
        '{"key": "value"}',
        NOW(),
        NOW()
    ),
    (
        'loc13',
        'client3',
        2,
        1,
        'Almacén 1',
        '789 Avenida Almacén',
        'Ciudad Industrial',
        '67890',
        'Estadoville',
        'PY',
        '555-555-555',
        'almacen1@example.com',
        'https://www.almacen1.com',
        -25.2637,
        -57.5759,
        '{"key": "value"}',
        NOW(),
        NOW()
    ),
    (
        'loc14',
        'client3',
        2,
        2,
        'Almacén 2',
        '987 Calle Depósito',
        'Ciudad Logística',
        '98765',
        'Estadoville',
        'PY',
        '222-222-222',
        'almacen2@example.com',
        'https://www.almacen2.com',
        -23.4425,
        -58.4438,
        '{"key": "value"}',
        NOW(),
        NOW()
    ),
    (
        'loc15',
        'client3',
        1,
        3,
        'Tienda 3',
        '789 Calle Roble',
        'Pueblovilla',
        '34567',
        'Estadoville',
        'PY',
        '333-333-333',
        'tienda3@example.com',
        'https://www.tienda3.com',
        -26.2041,
        -58.1892,
        '{"key": "value"}',
        NOW(),
        NOW()
    ) ON CONFLICT (location_id) DO NOTHING;

-- $2a$10$l5UkKRFGkRDU9MNyExbcNOEA3VJZpU2hEA1Kkx9CLpQerI/jBEwKe is for password 'a'

INSERT INTO
    users (
        user_id,
        user_type,
        login,
        email,
        password_hash,
        password_salt,
        nick,
        gender,
        yob,
        language,
        country,
        theme,
        email_verified,
        blocked,
        created_at,
        updated_at
    )
VALUES (
        'user1',
        2,
        'user1login',
        'user1@example.com',
        'passwordhash1',
        'passwordsalt1',
        'user1nick',
        1,
        2000,
        'sk',
        'sk',
        2,
        true,
        false,
        NOW(),
        NOW()
    ),
    (
        'user2',
        2,
        'user2login',
        'user2@example.com',
        'passwordhash2',
        'passwordsalt2',
        'user2nick',
        2,
        2001,
        'en',
        'GB',
        1,
        false,
        false,
        NOW(),
        NOW()
    ),
    (
        'user3',
        2,
        'user3login',
        'user3@example.com',
        'passwordhash3',
        'passwordsalt3',
        'user3nick',
        1,
        2002,
        'en',
        'CA',
        3,
        false,
        true,
        NOW(),
        NOW()
    ),
    (
        'user4',
        2,
        'user4login',
        'user4@example.com',
        'passwordhash4',
        'passwordsalt4',
        'user4nick',
        2,
        2003,
        'en',
        'AU',
        1,
        false,
        false,
        NOW(),
        NOW()
    ),
    (
        'user5',
        2,
        'user5login',
        'user5@example.com',
        'passwordhash5',
        'passwordsalt5',
        'user5nick',
        2,
        2004,
        'en',
        'NZ',
        2,
        true,
        false,
        NOW(),
        NOW()
    ) ON CONFLICT (user_id) DO NOTHING;

INSERT INTO
    users (
        user_id,
        user_type,
        roles,
        client_id,
        login,
        email,
        password_hash,
        password_salt,
        nick,
        gender,
        yob,
        language,
        country,
        theme,
        email_verified,
        blocked,
        created_at,
        updated_at
    )
VALUES (
        'u1',
        2,
        NULL,
        NULL,
        'c1.u1',
        'u1@a.com',
        '$2a$10$l5UkKRFGkRDU9MNyExbcNOEA3VJZpU2hEA1Kkx9CLpQerI/jBEwKe',
        '$2a$10$l5UkKRFGkRDU9MNyExbcNO',
        'u1',
        1,
        2000,
        'sk',
        'sk',
        2,
        false,
        false,
        NOW(),
        NOW()
    ),
    (
        'pos1',
        3,
        '{3}',
        'client1',
        'c1.pos1',
        'pos1@a.com',
        '$2a$10$l5UkKRFGkRDU9MNyExbcNOEA3VJZpU2hEA1Kkx9CLpQerI/jBEwKe',
        '$2a$10$l5UkKRFGkRDU9MNyExbcNO',
        'pos1',
        1,
        2000,
        'sk',
        'sk',
        2,
        false,
        false,
        NOW(),
        NOW()
    ),
    (
        'admin1',
        3,
        '{1, 3}',
        'client1',
        'c1.admin1',
        'admin1@a.com',
        '$2a$10$l5UkKRFGkRDU9MNyExbcNOEA3VJZpU2hEA1Kkx9CLpQerI/jBEwKe',
        '$2a$10$l5UkKRFGkRDU9MNyExbcNO',
        'admin1',
        2,
        2001,
        'en',
        'sk',
        1,
        false,
        false,
        NOW(),
        NOW()
    ) ON CONFLICT (user_id) DO NOTHING;

INSERT INTO
    users (
        user_id,
        user_type,
        roles,
        login,
        email,
        password_hash,
        password_salt,
        nick,
        gender,
        yob,
        language,
        country,
        theme,
        email_verified,
        blocked,
        created_at,
        updated_at
    )
VALUES (
        'seller1',
        4,
        '{2}',
        'seller1',
        NULL,
        '$2a$10$l5UkKRFGkRDU9MNyExbcNOEA3VJZpU2hEA1Kkx9CLpQerI/jBEwKe',
        '$2a$10$l5UkKRFGkRDU9MNyExbcNO',
        'oxy',
        1,
        2000,
        'sk',
        'sk',
        2,
        false,
        false,
        NOW(),
        NOW()
    ),
    (
        'seller2',
        4,
        '{2}',
        'seller2',
        NULL,
        '$2a$10$l5UkKRFGkRDU9MNyExbcNOEA3VJZpU2hEA1Kkx9CLpQerI/jBEwKe',
        '$2a$10$l5UkKRFGkRDU9MNyExbcNO',
        'Enimo Admin',
        1,
        2000,
        'sk',
        'sk',
        2,
        false,
        false,
        NOW(),
        NOW()
    ) ON CONFLICT (user_id) DO NOTHING;

INSERT INTO
    users (
        user_id,
        user_type,
        roles,
        login,
        email,
        password_hash,
        password_salt,
        nick,
        gender,
        yob,
        language,
        country,
        theme,
        email_verified,
        blocked,
        created_at,
        updated_at
    )
VALUES (
        '55165f89-9acd-457b-b10e-c5ea511d5839',
        1,
        '{10}',
        'superadmin',
        NULL,
        '$2a$10$l5UkKRFGkRDU9MNyExbcNOEA3VJZpU2hEA1Kkx9CLpQerI/jBEwKe',
        '$2a$10$l5UkKRFGkRDU9MNyExbcNO',
        'oxy',
        1,
        2000,
        'sk',
        'sk',
        2,
        false,
        false,
        NOW(),
        NOW()
    ),
    (
        'd6852a32-b9b7-458a-aaae-aeed04c42865',
        4,
        '{2}',
        'enimo',
        NULL,
        '$2a$10$l5UkKRFGkRDU9MNyExbcNOEA3VJZpU2hEA1Kkx9CLpQerI/jBEwKe',
        '$2a$10$l5UkKRFGkRDU9MNyExbcNO',
        'Enimo Admin',
        1,
        2000,
        'sk',
        'sk',
        2,
        false,
        false,
        NOW(),
        NOW()
    ) ON CONFLICT (user_id) DO NOTHING;

-- https://vega-dev-static.vega.com/card/x1.jpg LrS$7PoLf+oLoffQfQfQysfle.bH
-- https://vega-dev-static.vega.com/card/x2.jpg LoNc_^V?T3M|t8j]axoL.AofIqbJ

INSERT INTO cards (card_id, client_id, code_type, name, logo, logo_bh, color, blocked, countries, meta, created_at, updated_at)
VALUES 
('card1', 'client1', 7, 'Card 1', 'x1.jpg', 'LrS$7PoLf+oLoffQfQfQysfle.bH', 'blue', false, ARRAY['US'], '{"key": "value"}', NOW(), NOW()),
('card2', 'client2', 7, 'Card 2', 'x2.jpg', 'LoNc_^V?T3M|t8j]axoL.AofIqbJ', 'red', false, ARRAY['US', 'CA'], '{"key": "value"}', NOW(), NOW()),
('card3', 'client3', 7, 'Card 3', NULL, NULL, 'green', false, ARRAY['PY'], '{"key": "value"}', NOW(), NOW()),
('card4', NULL, 7, 'Card 4', NULL, NULL, 'purple', false, ARRAY['GB', 'FR'], '{"key": "value"}', NOW(), NOW()),
('card5', NULL, 7, 'Card 5', NULL, NULL, 'orange', false, ARRAY['AU'], '{"key": "value"}', NOW(), NOW()),
('card6', NULL, 7, 'Card 6', NULL, NULL, 'yellow', false, ARRAY['AU', 'NZ'], '{"key": "value"}', NOW(), NOW()),
('card7', NULL, 7, 'Card 7', NULL, NULL, 'blue', false, ARRAY['CA'], '{"key": "value"}', NOW(), NOW()),
('card8', NULL, 7, 'Card 8', NULL, NULL, 'red', false, ARRAY['CA', 'US'], '{"key": "value"}', NOW(), NOW()),
('card9', NULL, 7, 'Card 9', NULL, NULL, 'green', false, ARRAY['NZ'], '{"key": "value"}', NOW(), NOW()),
('card10', NULL, 7, 'Card 10', NULL, NULL, 'purple', false, ARRAY['NZ', 'AU'], '{"key": "value"}', NOW(), NOW())
ON CONFLICT (card_id) DO NOTHING;

INSERT INTO
    user_cards (
        user_card_id,
        user_id,
        card_id,
        client_id,
        code_type,
        number,
        name,
        notes,
        logo,
        color,
        front,
        back,
        meta,
        touched_at,
        created_at,
        updated_at
    )
VALUES (
        'uc11',
        'u1',
        'card1',
        'client1',
        7,
        '1234567890',
        'Card 1',
        'notes',
        NULL,
        NULL,
        NULL,
        NULL,
        '{"key": "value"}',
        NOW(),
        NOW(),
        NOW()
    ),
    (
        'uc12',
        'u1',
        'card1',
        'client1',
        7,
        '0987654321',
        'Card 2',
        'notes',
        NULL,
        NULL,
        NULL,
        NULL,
        '{"key": "value"}',
        NOW(),
        NOW(),
        NOW()
    ),
    (
        'uc13',
        'u1',
        'card2',
        'client2',
        7,
        '1111111111',
        'Card 3',
        'notes',
        'card3logo.png',
        'green',
        NULL,
        NULL,
        '{"key": "value"}',
        NOW(),
        NOW(),
        NOW()
    ),
    (
        'uc14',
        'u1',
        'card4',
        NULL,
        7,
        '2222222222',
        'No client',
        'Sample notes for non client card 4',
        'card4logo.png',
        'purple',
        'front.jpg',
        'back.jpg',
        '{"key": "value"}',
        NOW(),
        NOW(),
        NOW()
    ) ON CONFLICT (user_card_id) DO NOTHING;

INSERT INTO
    user_cards (
        user_card_id,
        user_id,
        card_id,
        client_id,
        code_type,
        number,
        name,
        notes,
        logo,
        color,
        front,
        back,
        meta,
        touched_at,
        created_at,
        updated_at
    )
VALUES (
        'uc21',
        'user2',
        'card1',
        'client1',
        7,
        '3333333333',
        'Card 1',
        'notes',
        NULL,
        NULL,
        NULL,
        NULL,
        '{"key": "value"}',
        NOW(),
        NOW(),
        NOW()
    ),
    (
        'uc22',
        'user2',
        'card2',
        'client2',
        7,
        '4444444444',
        'Card 6',
        'notes',
        NULL,
        NULL,
        'front.jpg',
        'back.jpg',
        '{"key": "value"}',
        NOW(),
        NOW(),
        NOW()
    ),
    (
        'uc23',
        'user2',
        'card7',
        NULL,
        7,
        'No client',
        'Card 7',
        'Sample notes for non client card 7',
        'card7logo.png',
        'blue',
        NULL,
        NULL,
        '{"key": "value"}',
        NOW(),
        NOW(),
        NOW()
    ) ON CONFLICT (user_card_id) DO NOTHING;

INSERT INTO
    installations (
        installation_id,
        user_id,
        device_token,
        device_info,
        created_at,
        updated_at
    )
VALUES (
        'installation1',
        'user1',
        'deviceToken1',
        '{"key": "value"}',
        NOW(),
        NOW()
    ) ON CONFLICT (installation_id) DO NOTHING;

INSERT INTO
    installations (
        installation_id,
        user_id,
        device_token,
        device_info,
        created_at,
        updated_at
    )
VALUES (
        'installation2',
        'user2',
        'deviceToken2',
        '{"key": "value"}',
        NOW(),
        NOW()
    ) ON CONFLICT (installation_id) DO NOTHING;

INSERT INTO
    installations (
        installation_id,
        user_id,
        device_token,
        device_info,
        created_at,
        updated_at
    )
VALUES (
        'u1installation',
        'u1',
        'deviceToken_u1',
        '{"key": "value"}',
        NOW(),
        NOW()
    ) ON CONFLICT (installation_id) DO NOTHING;

INSERT INTO
    installations (
        installation_id,
        user_id,
        device_token,
        device_info,
        created_at,
        updated_at
    )
VALUES (
        'pos1installation',
        'pos1',
        'deviceToken_pos1',
        '{"key": "value"}',
        NOW(),
        NOW()
    ) ON CONFLICT (installation_id) DO NOTHING;

INSERT INTO
    installations (
        installation_id,
        user_id,
        device_token,
        device_info,
        created_at,
        updated_at
    )
VALUES (
        'admin1installation',
        'admin1',
        'deviceToken_admin1',
        '{"key": "value"}',
        NOW(),
        NOW()
    ) ON CONFLICT (installation_id) DO NOTHING;

INSERT INTO
    installations (
        installation_id,
        user_id,
        device_token,
        device_info,
        created_at,
        updated_at
    )
VALUES (
        'seller1installation',
        'seller1',
        'deviceToken_seller1',
        '{"key": "value"}',
        NOW(),
        NOW()
    ) ON CONFLICT (installation_id) DO NOTHING;

-- sk {"plural": {"one": "{} bod", "few":"{} body", "many":"{} bodu", "other":"{} bodov"} }
-- en {"plural": {"one": "{} point", "other":"{} points"} }
-- es {"plural": {"one": "{} punto", "other":"{} puntos"} }

INSERT INTO programs (program_id, client_id, card_id, location_id, type, name, description, image, image_bh, countries, rank, valid_from, valid_to, meta, created_at, updated_at)
VALUES 
('program1', 'client1', 'card1', NULL, 1, 'Program reach 1', 'Description of program 1', 'program1.jpg', 'program1_bh.jpg', ARRAY['us', 'sk', 'py'], 1, 20230401, NULL, '{"plural": {"one": "{} bod", "few":"{} body", "other":"{} bodov"}, "actions": {"addition": "Pridať body", "subtraction": "Vydať odmenu"} }', NOW(), NOW()),
('program2', 'client2', 'card2', NULL, 1, 'Program reach 2', 'Description of program 2', 'program2.jpg', 'program2_bh.jpg',  ARRAY['us', 'sk', 'py'], 2, 20230401, NULL, '{"plural": {"one": "{} point", "other":"{} points"}, "actions": {"addition": "Pridať body", "subtraction": "Vydať odmenu"} }', NOW(), NOW()),
('program3', 'client3', 'card3', NULL, 2, 'Program collect 3', 'Description of program 3', 'program3.jpg', 'program3_bh.jpg',  ARRAY['us', 'ca', 'sk', 'py'], 3, 20230401, 20990430, '{"plural": {"one": "{} punto", "other":"{} puntos"}, "actions": {"addition": "Pridať body", "subtraction": "Vydať odmenu"} }', NOW(), NOW()),
('program4', 'client2', 'card2', NULL, 2, 'Program collect 4', 'Description of program 4', 'program4.jpg', 'program4_bh.jpg',  ARRAY['ca'], 4, 20230401, 20990430, '{"plural": {"one": "{} bod", "few":"{} body", "other":"{} bodov"}, "actions": {"addition": "Pridať body", "subtraction": "Vydať odmenu"} }', NOW(), NOW()),
('program5', 'client1', 'card1', NULL, 3, 'Program credit 5', 'Description of program 5', 'program5.jpg', 'program5_bh.jpg',  ARRAY['us', 'sk', 'py'], 5, 20230401, NULL, '{"plural": {"one": "{} point", "other":"{} points"}, "actions": {"addition": "Pridať vstupy", "subtraction": "Odpočítať vstup"} }', NOW(), NOW())
ON CONFLICT (program_id) DO NOTHING;

INSERT INTO
    program_rewards (
        program_reward_id,
        program_id,
        name,
        description,
        image,
        image_bh,
        points,
        rank,
        meta,
        valid_from,
        valid_to,
        created_at,
        updated_at
    )
VALUES (
        'reward1',
        'program1',
        'Reward 1',
        'Description of reward 1',
        'https://picsum.photos/id/429/300/300',
        'LVKAvk?G.SjDHX_Nx]tQNtMdR5x]',
        100,
        1,
        '{"meta_key": "meta_value"}',
        20240601,
        NULL,
        NOW(),
        NOW()
    ),
    (
        'reward2',
        'program1',
        'Reward 2',
        'Description of reward 2',
        'https://picsum.photos/id/63/300/300',
        'L$LT7jsonPs.|xWVW;bG#9R*kBR+',
        200,
        2,
        NULL,
        20230401,
        NULL,
        NOW(),
        NOW()
    ),
    (
        'reward3',
        'program2',
        'Reward 3',
        'Description of reward 3',
        'https://picsum.photos/id/99/300/300',
        'LxI5Sjaxofof~qj?ofofxuM|j[WB',
        150,
        1,
        '{"meta_key": "meta_value"}',
        20240401,
        20230601,
        NOW(),
        NOW()
    ),
    (
        'reward4',
        'program2',
        'Reward 4',
        'Description of reward 4',
        'https://picsum.photos/id/152/300/300',
        'LcEB{{%3NFR%RjjvayoM5MNFt7ax',
        250,
        2,
        NULL,
        20230401,
        NULL,
        NOW(),
        NOW()
    ) ON CONFLICT (program_reward_id) DO NOTHING;

INSERT INTO coupons (coupon_id, client_id, location_id, type, name, description, code, codes, image, image_bh, countries, rank, valid_from, valid_to, created_at, updated_at)
VALUES
    ('c1', 'client1', 'loc6', 1, '10% off', '10% off all products', 'ABC123', NULL, 'https://picsum.photos/id/85/300/100/', 'LcJ+c2n$Rmo}LNofWBae+GkDayWB', ARRAY['US', 'CA'], 1, 20230401, NULL, NOW(), NOW()),
    ('c2', 'client1', NULL, 2, 'Free shipping array', 'Free shipping on all orders', 'DEF456', ARRAY['A1', 'B2', 'C3', 'D4', 'E5', 'F6', 'G7', 'H8', 'I9'], 'https://picsum.photos/id/95/300/100/', 'LPI#+6%L4U_MV_j[WUt7MyIBRjM{',  ARRAY['GB'], 2, 20230401, 20240201, NOW(), NOW()),
    ('c3', 'client1', 'loc8', 1, '20% off', '20% off all products in store', 'GHI789', NULL, 'https://picsum.photos/id/75/300/100/', 'LcH_#u01~VNHIVR%WEIVR%o3WA%2',  ARRAY['US', 'CA'], 1, 20240401, 20280401, NOW(), NOW()),
    ('c4', 'client2', 'loc1', 1, '50% off', '50% off all products online', 'MNO345', NULL, 'https://picsum.photos/id/65/300/100/', 'L~MY+P0hX7%0TJRQoyjukDjYR,W;', ARRAY['FR', 'DE'], 3, 20230401, 20231001, NOW(), NOW()),
    ('c5', 'client2', NULL, 2, 'Free gift array', 'Get a free gift with every purchase', 'STU901', ARRAY['STU901'], 'https://picsum.photos/id/55/300/100/', 'LVGIWD0ND+n.xBIW-oM|N2WEoa--', ARRAY['GB'], 2, 20230401, NULL, NOW(), NOW())
ON CONFLICT (coupon_id) DO NOTHING;

INSERT INTO
    user_coupons (
        user_coupon_id,
        user_id,
        client_id,
        coupon_id,
        created_at,
        updated_at
    )
VALUES (
        'uc1_1',
        'u1',
        'client1',
        'c1',
        NOW(),
        NOW()
    ),
    (
        'uc1_2',
        'u1',
        'client1',
        'c2',
        NOW(),
        NOW()
    ),
    (
        'uc1_3',
        'u1',
        'client2',
        'c3',
        NOW(),
        NOW()
    ) ON CONFLICT (user_coupon_id) DO NOTHING;

INSERT INTO
    receipts (
        receipt_id,
        client_id,
        user_id,
        user_card_id,
        purchased_at_time,
        purchased_at_place,
        total_items,
        total_price,
        total_price_currency,
        items,
        created_at,
        updated_at
    )
VALUES (
        'receipt1',
        'client1',
        'user1',
        'uc11',
        NOW(),
        'store1',
        3,
        2500,
        'EUR',
        '[{"name": "item1", "unit_price": 800, "quantity": 1, "total_price": 800, "currency": "EUR"},
    {"name": "item2", "unit_price": 900, "quantity": 1, "total_price": 900, "currency": "EUR"},
    {"name": "item3", "unit_price": 800, "quantity": 1, "total_price": 800, "currency": "EUR"}]',
        NOW(),
        NOW()
    ),
    (
        'receipt2',
        'client1',
        'user1',
        'uc11',
        NOW(),
        'store2',
        2,
        1500,
        'EUR',
        '[{"name": "item4", "unit_price": 750, "quantity": 1, "total_price": 750, "currency": "EUR"},
    {"name": "item5", "unit_price": 750, "quantity": 1, "total_price": 750, "currency": "EUR"}]',
        NOW(),
        NOW()
    ),
    (
        'receipt3',
        'client2',
        'user1',
        'uc12',
        NOW(),
        'store3',
        1,
        500,
        'USD',
        '[{"name": "item6", "unit_price": 500, "quantity": 1, "total_price": 500, "currency": "USD"}]',
        NOW(),
        NOW()
    ) ON CONFLICT (receipt_id) DO NOTHING;

-- https://vega-dev-static.vega.com/sample_data/lf1.jpg LfJ@qF~pOrnh$do}NHoLXoM{a0s9
-- https://vega-dev-static.vega.com/sample_data/lf2.jpg LeO3nT4TyDRkE3M{RktSS~x]jZxb
-- https://vega-dev-static.vega.com/sample_data/lf3.jpg LpMjR8%Mx]x]4Tt7ozbH.8ayj[Ri
-- https://vega-dev-static.vega.com/sample_data/lf4.jpg LVPGa99Fs;x]4TE1spozIpR%n%oz
-- https://vega-dev-static.vega.com/sample_data/lf5.jpg LjNHrt-9RkS##+R*bbsm0#s.NdjF

INSERT INTO leaflets(leaflet_id, client_id, location_id, country, name, rank, valid_from, valid_to, thumbnail, thumbnail_bh, leaflet, pages, pages_bh, meta, created_at, updated_at)
VALUES
    ('1', 'client1', 'loc6', 'SK', 'Leaflet1', 1, 20220101, 20240131, 'https://vega-dev-static.vega.com/sample_data/lf1.jpg', 'LfJ@qF~pOrnh$do}NHoLXoM{a0s9', 'https://example.com/leaf1.jpg', 
        ARRAY['https://vega-dev-static.vega.com/sample_data/lf1.jpg', 'https://vega-dev-static.vega.com/sample_data/lf2.jpg', 'https://vega-dev-static.vega.com/sample_data/lf3.jpg'], 
        ARRAY['LfJ@qF~pOrnh$do}NHoLXoM{a0s9', 'LeO3nT4TyDRkE3M{RktSS~x]jZxb', 'LpMjR8%Mx]x]4Tt7ozbH.8ayj[Ri'], '{"description": "This is a leaflet about our products."}', NOW(), NOW()),
    ('2', 'client1', 'loc9', 'US', 'Leaflet2', 2, 20230201, 20240228, 'https://vega-dev-static.vega.com/sample_data/lf5.jpg', 'LjNHrt-9RkS##+R*bbsm0#s.NdjF', 'https://example.com/leaf2.jpg', 
        ARRAY['https://vega-dev-static.vega.com/sample_data/lf5.jpg', 'https://vega-dev-static.vega.com/sample_data/lf4.jpg', 'https://vega-dev-static.vega.com/sample_data/lf3.jpg'], 
        ARRAY['LjNHrt-9RkS##+R*bbsm0#s.NdjF', 'LVPGa99Fs;x]4TE1spozIpR%n%oz', 'LpMjR8%Mx]x]4Tt7ozbH.8ayj[Ri'], '{"description": "This is a leaflet about our services."}', NOW(), NOW()),
    ('3', 'client2', 'loc2', 'PY', 'Leaflet3', 1, 20230115, 20231115, 'https://example.com/leaf3_thumb.jpg', '24680', 'https://example.com/leaf3.jpg', 
        ARRAY['https://vega-dev-static.vega.com/sample_data/lf2.jpg', 'https://example.com/page2.jpg', 'https://example.com/page3.jpg', 'https://example.com/page4.jpg'], 
        ARRAY['LeO3nT4TyDRkE3M{RktSS~x]jZxb', 'qrst', 'uvwx', 'yz01'], '{"description": "This is a leaflet about our promotions."}', NOW(), NOW())
ON CONFLICT (leaflet_id) DO NOTHING;

INSERT INTO
    client_sellers (
        client_seller_id,
        client_id,
        seller_id,
        share,
        notes,
        blocked,
        meta,
        created_at,
        updated_at
    )
VALUES (
        'cs1',
        'client1',
        'seller1',
        100,
        'Seller 1',
        false,
        '{"key": "value"}',
        NOW(),
        NOW()
    ),
    (
        'cs2',
        'client1',
        'seller2',
        50,
        'Seller 2',
        false,
        '{"key": "value"}',
        NOW(),
        NOW()
    ),
    (
        'cs3',
        'client2',
        'seller1',
        100,
        'Seller 1',
        false,
        '{"key": "value"}',
        NOW(),
        NOW()
    ),
    (
        'cs4',
        'client2',
        'seller2',
        50,
        'Seller 2',
        false,
        '{"key": "value"}',
        NOW(),
        NOW()
    ) ON CONFLICT (client_seller_id) DO NOTHING;