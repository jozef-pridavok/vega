DROP VIEW IF EXISTS view_coupons;
DROP VIEW IF EXISTS view_user_cards;
DROP VIEW IF EXISTS view_user_email_verifications;
DROP VIEW IF EXISTS view_leaflets;
DROP VIEW IF EXISTS view_loyalty_transaction_status;
DROP VIEW IF EXISTS view_receipts;

DROP TABLE IF EXISTS qr_tag;
DROP TABLE IF EXISTS product_item_ratings;
DROP TABLE IF EXISTS user_ratings;
DROP TABLE IF EXISTS client_ratings;
DROP TABLE IF EXISTS messages;
DROP TABLE IF EXISTS client_sellers;
DROP TABLE IF EXISTS client_payments;
DROP TABLE IF EXISTS client_payment_providers;
DROP TABLE IF EXISTS seller_payments;
DROP TABLE IF EXISTS leaflets;
DROP TABLE IF EXISTS user_coupons;
DROP TABLE IF EXISTS loyalty_transactions;
DROP TABLE IF EXISTS program_rewards;
DROP TABLE IF EXISTS receipts;
DROP TABLE IF EXISTS product_order_item_modifications;
DROP TABLE IF EXISTS product_order_items;
DROP TABLE IF EXISTS product_orders;
DROP TABLE IF EXISTS pos;
DROP TABLE IF EXISTS user_cards;
DROP TABLE IF EXISTS reservation_dates;
DROP TABLE IF EXISTS reservation_slots;
DROP TABLE IF EXISTS reservations;
DROP TABLE IF EXISTS product_item_options;
DROP TABLE IF EXISTS product_item_modifications;
DROP TABLE IF EXISTS product_items;
DROP TABLE IF EXISTS product_sections;
DROP TABLE IF EXISTS product_offers;
DROP TABLE IF EXISTS programs;
DROP TABLE IF EXISTS cards;
DROP TABLE IF EXISTS coupons;
DROP TABLE IF EXISTS locations;
DROP TABLE IF EXISTS user_addresses;
DROP TABLE IF EXISTS tokens;
DROP TABLE IF EXISTS installations;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS clients;
DROP TABLE IF EXISTS versions;

DROP FUNCTION IF EXISTS insert_version;

CREATE TABLE clients
(
    client_id VARCHAR(64) NOT NULL,
    name VARCHAR(128) NOT NULL,
    description VARCHAR(1024),
    logo VARCHAR(256),
    logo_bh VARCHAR(64),
    color VARCHAR(32) NOT NULL DEFAULT '#ffffff',
    blocked BOOL NOT NULL DEFAULT FALSE,
    countries VARCHAR(8)[],
    categories INT[],
    currency VARCHAR(3) NOT NULL DEFAULT 'USD',
    next_user_card_number INTEGER NOT NULL DEFAULT 1,   
    settings JSONB, 
    meta JSONB NOT NULL DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(), 
    deleted_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT pk_clients PRIMARY KEY (client_id)
);
CREATE INDEX idx_clients_blocked ON clients(blocked);


CREATE TABLE locations
(
    location_id VARCHAR(64) NOT NULL,
    client_id VARCHAR(64) NOT NULL,
    type INT NOT NULL DEFAULT 1,   
    rank INT NOT NULL DEFAULT 1,
    name VARCHAR(128),
    description VARCHAR(1024),
    address_line_1 VARCHAR(256),
    address_line_2 VARCHAR(256),
    city VARCHAR(128),
    zip VARCHAR(32),
    state VARCHAR(64),
    country VARCHAR(8),
    phone VARCHAR(32),
    email VARCHAR(64),
    website VARCHAR(256),
    opening_hours JSONB, -- '{ "mon": "08:00-18:00", "tue": "08:00-18:00", "wed": "08:00-18:00", "thu": "08:00-18:00", "fri": "08:00-18:00"}'
    opening_hours_exceptions JSONB, -- '[{ "20170101": "closed", "20170106": "08:00-12:00" }]'
    latitude FLOAT NOT NULL,
    longitude FLOAT NOT NULL,
    meta JSONB,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE,    
    CONSTRAINT pk_locations PRIMARY KEY (location_id),
    CONSTRAINT fk_locations_client FOREIGN KEY(client_id) REFERENCES clients(client_id)
);
CREATE INDEX idx_locations_client_id ON locations(client_id);

CREATE TABLE users
(
    user_id VARCHAR(64) NOT NULL,
    user_type INT NOT NULL DEFAULT 2, -- 1 = root, 2 = customer, 3 = client, 4 = branch
    client_id VARCHAR(64), -- if belongs to a client
    roles INT[],
    login VARCHAR(64),
    email VARCHAR(64),
    password_hash TEXT,
    password_salt TEXT,
    nick VARCHAR(64),
    gender INT,
    yob INT,
    language VARCHAR(8),
    country VARCHAR(8),
    theme INT NOT NULL DEFAULT 1,
    email_verified BOOL NOT NULL DEFAULT FALSE,
    blocked BOOL NOT NULL DEFAULT FALSE,
    folders JSONB NOT NULL DEFAULT '{"selected": "all", "list": [{"folderId": "all", "name": "All", "layout": 3, "type": 1, "userCards": []}, {"folderId": "favorites", "name": "Favorites", "layout": 3, "type": 2, "userCards": []}]}',
    meta JSONB, -- emailToken, emailTokenExpiration
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT pk_users PRIMARY KEY (user_id),
    CONSTRAINT fk_users_client FOREIGN KEY(client_id) REFERENCES clients(client_id)
);
CREATE INDEX idx_users_client_id ON users(client_id);
CREATE INDEX idx_users_blocked ON users(blocked);

CREATE VIEW view_user_email_verifications AS 
    SELECT user_id, meta->>'emailToken' AS email_token, meta->>'emailTokenExpiration' AS email_token_expiration
    FROM users
    WHERE blocked = FALSE AND email_verified = FALSE;

CREATE TABLE user_addresses(
    user_address_id VARCHAR(64) NOT NULL,
    user_id VARCHAR(64) NOT NULL,
    name VARCHAR(128) NOT NULL,
    address_line_1 VARCHAR(256),
    address_line_2 VARCHAR(256),
    city VARCHAR(128),
    zip VARCHAR(32),
    state VARCHAR(64),
    country VARCHAR(8),
    latitude FLOAT,
    longitude FLOAT,
    meta JSONB,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT pk_user_addresses PRIMARY KEY (user_address_id),
    CONSTRAINT fk_user_addresses_user FOREIGN KEY(user_id) REFERENCES users(user_id)
);
CREATE INDEX idx_user_addresses_user ON user_addresses(user_id);

CREATE TABLE installations
(
    installation_id VARCHAR(64) NOT NULL,
    user_id VARCHAR(64) NOT NULL,
    device_token VARCHAR(4096),
    device_info JSONB,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(), 
    deleted_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT pk_installations PRIMARY KEY (installation_id),
    CONSTRAINT fk_installations_user FOREIGN KEY(user_id) REFERENCES users(user_id) 
);
CREATE INDEX idx_installations_user_id ON installations(user_id);

CREATE TABLE cards
(
    card_id VARCHAR(64) NOT NULL,
    client_id VARCHAR(64),
    code_type INT NOT NULL DEFAULT 12, -- 1 = upca, 2 = upce, 3 = ean8, 4 = ean13, 5 = code39, 6 = code93, 7 = code128, 8 = itf14, 9 = interleaved2of5, 10 = pdf417, 11 = aztec, 12 = qr, 13 = datamatrix
    name VARCHAR(128) NOT NULL,
    logo VARCHAR(256),
    logo_bh VARCHAR(64),
    color VARCHAR(32) NOT NULL DEFAULT '#ffffff',
    blocked BOOL NOT NULL DEFAULT FALSE,
    rank INT NOT NULL DEFAULT 1,
    countries VARCHAR(8)[],
    meta JSONB,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(), 
    deleted_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT pk_cards PRIMARY KEY (card_id),
    CONSTRAINT fk_cards_client FOREIGN KEY(client_id) REFERENCES clients(client_id)
);
CREATE INDEX idx_cards_client ON cards(client_id);
CREATE INDEX idx_cards_blocked ON cards(blocked);

CREATE TABLE user_cards
(
    user_card_id VARCHAR(64) NOT NULL,
    user_id VARCHAR(64) NOT NULL,
    card_id VARCHAR(64),
    client_id VARCHAR(64),
    code_type INT NOT NULL DEFAULT 12,
    number VARCHAR(1024),
    points INT NOT NULL DEFAULT 0,
    digits INT NOT NULL DEFAULT 0, -- 0 = integer, 1 = 0.1, 2 = 0.01, 3 = 0.001, 4 = 0.0001...
    name VARCHAR(128),
    notes VARCHAR(1024),
    logo VARCHAR(256),
    logo_bh VARCHAR(64),
    color VARCHAR(32),
    front VARCHAR(256),
    front_bh VARCHAR(64),
    back VARCHAR(256),
    back_bh VARCHAR(64),
    active BOOL NOT NULL DEFAULT TRUE,
    rank INT NOT NULL DEFAULT 1,
    meta JSONB, -- activation_pin, activation_pin_expiration, activation_pin_attempts, activation_pin_blocked
    touched_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT pk_user_cards PRIMARY KEY (user_card_id),
    CONSTRAINT fk_user_cards_user FOREIGN KEY(user_id) REFERENCES users(user_id),
    CONSTRAINT fk_user_cards_card FOREIGN KEY(card_id) REFERENCES cards(card_id),
    CONSTRAINT fk_user_cards_client FOREIGN KEY(client_id) REFERENCES clients(client_id)
);
CREATE INDEX idx_user_cards_user ON user_cards(user_id);
CREATE INDEX idx_user_cards_card ON user_cards(card_id);
CREATE INDEX idx_user_cards_client ON user_cards(client_id);

CREATE VIEW view_user_cards AS 
    SELECT 
        uc.user_card_id, uc.user_id, uc.card_id, uc.client_id, uc.code_type, uc.number, uc.name, uc.notes, uc.logo, uc.logo_bh, uc.color, uc.front, uc.front_bh, uc.back, uc.back_bh, uc.active,
        c.name AS card_name, c.code_type AS card_code_type, c.logo AS card_logo, c.logo_bh AS card_logo_bh, c.color AS card_color,
        cl.name AS client_name, cl.logo AS client_logo, cl.logo_bh AS client_logo_bh, cl.color AS client_color
    FROM user_cards AS uc
    INNER JOIN users AS u ON uc.user_id = u.user_id
    LEFT JOIN cards AS c ON uc.card_id = c.card_id
    LEFT JOIN clients AS cl ON uc.client_id = cl.client_id
    WHERE uc.deleted_at IS NULL
    ORDER BY uc.name ASC;

CREATE TABLE coupons
(
    coupon_id VARCHAR(64) NOT NULL,
    client_id VARCHAR(64) NOT NULL,
    location_id VARCHAR(64),
    type INT NOT NULL DEFAULT 1,
    name VARCHAR(128) NOT NULL,
    description VARCHAR(1024),
    discount VARCHAR(32),
    code VARCHAR(128),
    codes VARCHAR(128)[],
    image VARCHAR(256),
    image_bh VARCHAR(64),
    countries VARCHAR(8)[],
    rank INT NOT NULL DEFAULT 1,
    valid_from INT NOT NULL,
    valid_to INT,
    blocked BOOL NOT NULL DEFAULT FALSE,
    meta JSONB,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(), 
    deleted_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT pk_coupons PRIMARY KEY (coupon_id),
    CONSTRAINT fk_coupons_client FOREIGN KEY(client_id) REFERENCES clients(client_id),
    CONSTRAINT fk_coupons_location FOREIGN KEY(location_id) REFERENCES locations(location_id)
);
CREATE INDEX idx_coupons_client ON coupons(client_id);
CREATE INDEX idx_coupons_location ON coupons(location_id);

CREATE VIEW view_coupons AS 
    SELECT 
        c.coupon_id, c.client_id, c.location_id, c.type, c.name, c.description, c.code, c.codes, c.image, c.image_bh, c.countries, c.rank, c.valid_from, c.valid_to,
        cl.name AS client_name, cl.logo AS client_logo, cl.logo_bh AS client_logo_bh, cl.color AS client_color,
        l.name AS location_name, l.type AS location_type, l.address_line_1 AS location_address_line_1, l.address_line_2 AS location_address_line_2, l.city AS location_city, l.state AS location_state, l.zip AS location_zip, l.country AS location_country, l.phone AS location_phone, l.email AS location_email, l.website AS location_website
    FROM coupons c
    INNER JOIN clients cl ON c.client_id = cl.client_id
    LEFT JOIN locations l ON c.location_id = l.location_id
    WHERE c.deleted_at IS NULL
    ORDER BY c.rank ASC, c.name ASC;

CREATE TABLE programs
(
    program_id VARCHAR(64) NOT NULL,
    client_id VARCHAR(64) NOT NULL,
    card_id VARCHAR(64) NOT NULL,
    location_id VARCHAR(64),
    type INT NOT NULL DEFAULT 1, -- 1 = reach, 2 = collect, 3 = credit
    name VARCHAR(128) NOT NULL,    
    description VARCHAR(1024),
    digits INT NOT NULL DEFAULT 0, -- 0 = integer, 1 = 0.1, 2 = 0.01, 3 = 0.001, 4 = 0.0001, ...
    image VARCHAR(256),
    image_bh VARCHAR(64),
    countries VARCHAR(8)[],
    rank INT NOT NULL DEFAULT 1,
    valid_from INT NOT NULL,
    valid_to INT,
    blocked BOOL NOT NULL DEFAULT FALSE,
    meta JSONB,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT pk_programs PRIMARY KEY (program_id),
    CONSTRAINT fk_programs_client FOREIGN KEY(client_id) REFERENCES clients(client_id),
    CONSTRAINT fk_programs_card FOREIGN KEY(card_id) REFERENCES cards(card_id),
    CONSTRAINT fk_programs_location FOREIGN KEY(location_id) REFERENCES locations(location_id)
);
CREATE INDEX idx_programs_client ON programs(client_id);
CREATE INDEX idx_programs_card ON programs(card_id);
CREATE INDEX idx_programs_location ON programs(location_id);

CREATE TABLE program_rewards 
(
    program_reward_id VARCHAR(64) NOT NULL,
    program_id VARCHAR(64) NOT NULL,
    name VARCHAR(128) NOT NULL,
    description VARCHAR(1024),
    image VARCHAR(256),
    image_bh VARCHAR(64),
    points INT NOT NULL,
    rank INT NOT NULL DEFAULT 1,
    valid_from INT NOT NULL,
    valid_to INT,
    blocked BOOL NOT NULL DEFAULT FALSE,
    count INT,
    meta JSONB,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(), 
    deleted_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT pk_program_rewards PRIMARY KEY (program_reward_id),
    CONSTRAINT fk_program_rewards_program FOREIGN KEY(program_id) REFERENCES programs(program_id)
);
CREATE INDEX idx_program_rewards_program ON program_rewards(program_id);

CREATE TABLE reservations
(
    reservation_id VARCHAR(64) NOT NULL,
    client_id VARCHAR(64),
    program_id VARCHAR(64),
    loyalty_mode INT NOT NULL DEFAULT 0, -- 0 = none, = count reservations, 2 = count spent money
    name VARCHAR(128) NOT NULL,
    description VARCHAR(1024),
    image VARCHAR(256),
    image_bh VARCHAR(64),
    rank INT NOT NULL DEFAULT 1,
    blocked BOOL NOT NULL DEFAULT FALSE,
    meta JSONB,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(), 
    deleted_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT pk_reservations PRIMARY KEY (reservation_id),
    CONSTRAINT fk_reservations_client FOREIGN KEY(client_id) REFERENCES clients(client_id),
    CONSTRAINT fk_reservations_program FOREIGN KEY(program_id) REFERENCES programs(program_id)
);
CREATE INDEX idx_reservations_client ON reservations(client_id);
CREATE INDEX idx_reservations_program ON reservations(program_id);

CREATE TABLE reservation_slots
(
    reservation_slot_id VARCHAR(64) NOT NULL,
    client_id VARCHAR(64) NOT NULL,
    reservation_id VARCHAR(64) NOT NULL,
    location_id VARCHAR(64),
    name VARCHAR(128) NOT NULL,
    description VARCHAR(1024),
    color VARCHAR(32) NOT NULL,
    image VARCHAR(256),
    image_bh VARCHAR(64),
    rank INT NOT NULL DEFAULT 1,
    price INT,
    currency VARCHAR(3),
    duration INT,
    blocked BOOL NOT NULL DEFAULT FALSE,
    meta JSONB,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(), 
    deleted_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT pk_reservation_slots PRIMARY KEY (reservation_slot_id),
    CONSTRAINT fk_reservation_slots_client FOREIGN KEY(client_id) REFERENCES clients(client_id),
    CONSTRAINT fk_reservation_slots_reservation FOREIGN KEY(reservation_id) REFERENCES reservations(reservation_id),
    CONSTRAINT fk_reservation_slots_location FOREIGN KEY(location_id) REFERENCES locations(location_id)
);
CREATE INDEX idx_reservation_slots_reservation ON reservation_slots(reservation_id);
CREATE INDEX idx_reservation_slots_client ON reservation_slots(client_id);
CREATE INDEX idx_reservation_slots_location ON reservation_slots(location_id);

CREATE TABLE reservation_dates
(
    reservation_date_id VARCHAR(64) NOT NULL,
    client_id VARCHAR(64),
    reservation_id VARCHAR(64) NOT NULL,
    reservation_slot_id VARCHAR(64) NOT NULL,
    reserved_by_user_id VARCHAR(64),
    status INT NOT NULL DEFAULT 1,
    date_time_from TIMESTAMP WITH TIME ZONE NOT NULL,
    date_time_to TIMESTAMP WITH TIME ZONE NOT NULL,
    meta JSONB,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT pk_reservation_dates PRIMARY KEY (reservation_date_id),
    CONSTRAINT fk_reservation_dates_client FOREIGN KEY(client_id) REFERENCES clients(client_id),    
    CONSTRAINT fk_reservation_dates_reservation FOREIGN KEY(reservation_id) REFERENCES reservations(reservation_id),
    CONSTRAINT fk_reservation_dates_reservation_slot FOREIGN KEY(reservation_slot_id) REFERENCES reservation_slots(reservation_slot_id),
    CONSTRAINT fk_reservation_dates_reserved_by_user FOREIGN KEY(reserved_by_user_id) REFERENCES users(user_id)
);
CREATE INDEX idx_reservation_dates_reservation ON reservation_dates(reservation_id);
CREATE INDEX idx_reservation_dates_reservation_slot ON reservation_dates(reservation_slot_id);
CREATE INDEX idx_reservation_dates_reserved_by_user ON reservation_dates(reserved_by_user_id);
CREATE INDEX idx_reservation_dates_client ON reservation_dates(client_id);

CREATE TABLE product_offers
(
    product_offer_id VARCHAR(64) NOT NULL,
    client_id VARCHAR(64) NOT NULL,
    program_id VARCHAR(64),
    location_id VARCHAR(64),
    name VARCHAR(128) NOT NULL,
    description VARCHAR(1024),
    loyalty_mode INT NOT NULL DEFAULT 0, -- 0 = none, = count orders, 2 = count spent money
    type INT NOT NULL DEFAULT 1, -- 1 = regular, 2 = daily, 3 = weekly, 4 = monthly, 5 = yearly, 6 = special
    date INT NULL,
    rank INT NOT NULL DEFAULT 1,
    blocked BOOL NOT NULL DEFAULT FALSE,
    meta JSONB,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(), 
    deleted_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT pk_product_offers PRIMARY KEY (product_offer_id),
    CONSTRAINT fk_product_offers_client FOREIGN KEY(client_id) REFERENCES clients(client_id),
    CONSTRAINT fk_product_offers_location FOREIGN KEY(location_id) REFERENCES locations(location_id),
    CONSTRAINT fk_product_offers_program FOREIGN KEY(program_id) REFERENCES programs(program_id)
);
CREATE INDEX idx_product_offers_client ON product_offers(client_id);
CREATE INDEX idx_product_offers_location ON product_offers(location_id);
CREATE INDEX idx_product_offers_program ON product_offers(program_id);

CREATE TABLE product_sections
(
    product_section_id VARCHAR(64) NOT NULL,
    client_id VARCHAR(64) NOT NULL,
    product_offer_id VARCHAR(64) NOT NULL,    
    name VARCHAR(128) NOT NULL,
    description VARCHAR(1024),
    rank INT NOT NULL DEFAULT 1,
    blocked BOOL NOT NULL DEFAULT FALSE,
    meta JSONB,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(), 
    deleted_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT pk_product_sections PRIMARY KEY (product_section_id),
    CONSTRAINT fk_product_sections_client FOREIGN KEY(client_id) REFERENCES clients(client_id),
    CONSTRAINT fk_product_sections_offer FOREIGN KEY(product_offer_id) REFERENCES product_offers(product_offer_id)
);
CREATE INDEX idx_product_sections_offer ON product_sections(product_offer_id);
CREATE INDEX idx_product_sections_client ON product_sections(client_id);

CREATE TABLE product_items
(
    product_item_id VARCHAR(64) NOT NULL,
    product_section_id VARCHAR(64),
    client_id VARCHAR(64) NOT NULL,
    name VARCHAR(128) NOT NULL,
    description VARCHAR(1024),
    photo VARCHAR(256),
    photo_bh VARCHAR(64),
    rank INT NOT NULL DEFAULT 1,
    price INT,
    currency VARCHAR(3) NOT NULL,
    qty_precision INT NOT NULL DEFAULT 0, -- 0 = integer, 1 = 0.1, 2 = 0.01, 3 = 0.001, 4 = 0.0001, ...
    unit VARCHAR(64),
    blocked BOOL NOT NULL DEFAULT FALSE,
    meta JSONB,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(), 
    deleted_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT pk_product_items PRIMARY KEY (product_item_id),
    CONSTRAINT fk_product_items_client FOREIGN KEY(client_id) REFERENCES clients(client_id),
    CONSTRAINT fk_product_items_section FOREIGN KEY(product_section_id) REFERENCES product_sections(product_section_id)
);
CREATE INDEX idx_product_items_section ON product_items(product_section_id);
CREATE INDEX idx_product_items_client ON product_items(client_id);

CREATE TABLE product_item_modifications
(
    product_item_modification_id VARCHAR(64) NOT NULL,
    product_item_id VARCHAR(64) NOT NULL,
    client_id VARCHAR(64) NOT NULL,
    name VARCHAR(128) NOT NULL,
    type INT NOT NULL DEFAULT 1, -- 1 = single, 2 = multiple
    mandatory BOOL NOT NULL DEFAULT FALSE,
    max INT,
    rank INT NOT NULL DEFAULT 1,
    blocked BOOL NOT NULL DEFAULT FALSE,
    meta JSONB,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(), 
    deleted_at TIMESTAMP WITH TIME ZONE,    
    CONSTRAINT pk_product_item_modifications PRIMARY KEY (product_item_modification_id),
    CONSTRAINT fk_product_item_modifications_client FOREIGN KEY(client_id) REFERENCES clients(client_id),
    CONSTRAINT fk_product_item_modifications_item FOREIGN KEY(product_item_id) REFERENCES product_items(product_item_id)
);
CREATE INDEX idx_product_item_modifications_item ON product_item_modifications(product_item_id);
CREATE INDEX idx_product_item_modifications_client ON product_item_modifications(client_id);

CREATE TABLE product_item_options
(
    product_item_option_id VARCHAR(64) NOT NULL,
    product_item_modification_id VARCHAR(64) NOT NULL,
    client_id VARCHAR(64) NOT NULL,
    name VARCHAR(128) NOT NULL,
    price INT NOT NULL,
    pricing INT NOT NULL DEFAULT 1, -- 1 = add, 2 = override
    unit VARCHAR(64) NOT NULL,
    rank INT NOT NULL DEFAULT 1,
    blocked BOOL NOT NULL DEFAULT FALSE,
    meta JSONB,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(), 
    deleted_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT pk_product_item_options PRIMARY KEY (product_item_option_id),    
    CONSTRAINT fk_product_item_options_client FOREIGN KEY(client_id) REFERENCES clients(client_id),
    CONSTRAINT fk_product_item_options_modification FOREIGN KEY(product_item_modification_id) REFERENCES product_item_modifications(product_item_modification_id)
);
CREATE INDEX idx_product_item_options_modification ON product_item_modifications(product_item_modification_id);
CREATE INDEX idx_product_item_options_client ON product_item_options(client_id);

/*
ALTER TABLE product_item_options ADD COLUMN client_id VARCHAR(64) NOT NULL;

        or

        ALTER TABLE product_item_options ADD COLUMN client_id VARCHAR(64);
        UPDATE product_item_options SET client_id = 'client1';
        ALTER TABLE product_item_options ALTER COLUMN client_id SET NOT NULL;

ALTER TABLE product_item_options ADD CONSTRAINT fk_product_item_options_client FOREIGN KEY(client_id) REFERENCES clients(client_id);
CREATE INDEX idx_product_item_options_client ON product_item_options(client_id);
*/

CREATE TABLE product_orders
(
    product_order_id VARCHAR(64) NOT NULL,
    product_offer_id VARCHAR(64) NOT NULL,
    client_id VARCHAR(64) NOT NULL,
    location_id VARCHAR(64),
    user_id VARCHAR(64) NOT NULL,
    user_card_id VARCHAR(64) NOT NULL,
    notes VARCHAR(1024),
    status INT NOT NULL DEFAULT 1, -- 1 = created, 2 = cancelled, 3 = accepted, 4 = in progress, 5 = ready, 6 = dispatched, 7 = delivered, 8 = returned, 9 = completed
    cancelled_reason VARCHAR(1024),
    cancelled_by_user_id VARCHAR(64),
    cancelled_at TIMESTAMP WITH TIME ZONE,
    total_price INT,
    total_price_currency VARCHAR(3),
    delivery_type INT NOT NULL DEFAULT 1, -- 1 = pickup, 2 = delivery
    delivery_date TIMESTAMP WITH TIME ZONE,
    deliver_price INT,
    deliver_currency VARCHAR(3),
    delivery_address_id VARCHAR(64),
    meta JSONB, -- { ordered_by_user, cancelled_by_user, delivery_address, }
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(), 
    deleted_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT pk_product_orders PRIMARY KEY (product_order_id),
    CONSTRAINT fk_product_orders_client FOREIGN KEY(client_id) REFERENCES clients(client_id),
    CONSTRAINT fk_product_orders_user FOREIGN KEY(user_id) REFERENCES users(user_id),        
    CONSTRAINT fk_product_orders_offer FOREIGN KEY(product_offer_id) REFERENCES product_offers(product_offer_id),
    CONSTRAINT fk_product_orders_card FOREIGN KEY(user_card_id) REFERENCES user_cards(user_card_id),
    CONSTRAINT fk_product_orders_cancelled_by_user FOREIGN KEY(cancelled_by_user_id) REFERENCES users(user_id),
    CONSTRAINT fk_product_orders_location FOREIGN KEY(location_id) REFERENCES locations(location_id),
    CONSTRAINT fk_product_orders_delivery_address FOREIGN KEY(delivery_address_id) REFERENCES user_addresses(user_address_id)
);
CREATE INDEX idx_product_orders_offer ON product_orders(product_offer_id);
CREATE INDEX idx_product_orders_client ON product_orders(client_id);
CREATE INDEX idx_product_orders_user ON product_orders(user_id);
CREATE INDEX idx_product_orders_card ON product_orders(user_card_id);
CREATE INDEX idx_product_orders_cancelled_by_user ON product_orders(cancelled_by_user_id);
CREATE INDEX idx_product_orders_location ON product_orders(location_id);
CREATE INDEX idx_product_orders_delivery_address ON product_orders(delivery_address_id);

CREATE TABLE product_order_items
(
    product_order_item_id VARCHAR(64) NOT NULL,
    product_order_id VARCHAR(64) NOT NULL,
    product_item_id VARCHAR(64) NOT NULL,
    qty INT NOT NULL DEFAULT 1,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    CONSTRAINT pk_product_order_items PRIMARY KEY (product_order_item_id),
    CONSTRAINT fk_product_order_items_item FOREIGN KEY(product_item_id) REFERENCES product_items(product_item_id)
);
CREATE INDEX idx_product_order_items_item ON product_order_items(product_item_id);

CREATE TABLE product_order_item_modifications
(
    product_order_item_modification_id VARCHAR(64) NOT NULL,
    product_order_item_id VARCHAR(64) NOT NULL,
    product_item_modification_id VARCHAR(64) NOT NULL,
    product_item_option_id VARCHAR(64) NOT NULL,
    product_order_id VARCHAR(64) NOT NULL,
    CONSTRAINT pk_product_order_item_modifications PRIMARY KEY (product_order_item_modification_id),
    CONSTRAINT fk_product_order_item_modifications_item FOREIGN KEY(product_order_item_id) REFERENCES product_order_items(product_order_item_id),
    CONSTRAINT fk_product_order_item_modifications_modification FOREIGN KEY(product_item_modification_id) REFERENCES product_item_modifications(product_item_modification_id),
    CONSTRAINT fk_product_order_item_modifications_option FOREIGN KEY(product_item_option_id) REFERENCES product_item_options(product_item_option_id),
    CONSTRAINT fk_product_order_item_modifications_order FOREIGN KEY(product_order_id) REFERENCES product_orders(product_order_id)
);
CREATE INDEX idx_product_order_item_modifications_item ON product_order_item_modifications(product_order_item_id);
CREATE INDEX idx_product_order_item_modifications_modification ON product_order_item_modifications(product_item_modification_id);
CREATE INDEX idx_product_order_item_modifications_option ON product_order_item_modifications(product_item_option_id);
CREATE INDEX idx_product_order_item_modifications_order ON product_order_item_modifications(product_order_id);

CREATE TABLE pos
(
    pos_id VARCHAR(64) NOT NULL,
    client_id VARCHAR(64) NOT NULL,
    user_id VARCHAR(64),
    program_id VARCHAR(64),
    coupon_id VARCHAR(64),
    reservation_id VARCHAR(64),
    product_offer_id VARCHAR(64),
    name VARCHAR(128),
    description VARCHAR(1024),
    blocked BOOL NOT NULL DEFAULT FALSE,
    meta JSONB,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(), 
    deleted_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT pk_pos PRIMARY KEY (pos_id),
    CONSTRAINT fk_pos_client FOREIGN KEY(client_id) REFERENCES clients(client_id),
    CONSTRAINT fk_pos_user FOREIGN KEY(user_id) REFERENCES users(user_id),
    CONSTRAINT fk_pos_program FOREIGN KEY(program_id) REFERENCES programs(program_id),    
    CONSTRAINT fk_pos_coupon FOREIGN KEY(coupon_id) REFERENCES coupons(coupon_id),
    CONSTRAINT fk_pos_reservation FOREIGN KEY(reservation_id) REFERENCES reservations(reservation_id),
    CONSTRAINT fk_pos_offer FOREIGN KEY(product_offer_id) REFERENCES product_offers(product_offer_id)
);    
CREATE INDEX idx_pos_client ON pos(client_id);
CREATE INDEX idx_pos_user ON pos(user_id);
CREATE INDEX idx_pos_program ON pos(program_id);
CREATE INDEX idx_pos_coupon ON pos(coupon_id);
CREATE INDEX idx_pos_reservation ON pos(reservation_id);
CREATE INDEX idx_pos_offer ON pos(product_offer_id);

CREATE TABLE user_coupons
(
    user_coupon_id VARCHAR(64) NOT NULL,
    user_id VARCHAR(64) NOT NULL,
    coupon_id VARCHAR(64) NOT NULL,
    client_id VARCHAR(64) NOT NULL,
    expires_at INT NOT NULL DEFAULT TO_CHAR(NOW(), 'YYYYMMDD')::INT,
    redeemed_at TIMESTAMP WITH TIME ZONE,
    redeemed_by_pos_id VARCHAR(64),
    redeemed_by_user_id VARCHAR(64),
    meta JSONB,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT pk_user_coupons PRIMARY KEY (user_coupon_id),
    CONSTRAINT fk_user_coupons_user FOREIGN KEY(user_id) REFERENCES users(user_id),
    CONSTRAINT fk_user_coupons_coupon FOREIGN KEY(coupon_id) REFERENCES coupons(coupon_id),
    CONSTRAINT fk_user_coupons_client FOREIGN KEY(client_id) REFERENCES clients(client_id),
    CONSTRAINT fk_user_coupons_pos FOREIGN KEY(redeemed_by_pos_id) REFERENCES pos(pos_id),
    CONSTRAINT fk_user_coupons_redeemed_by_user FOREIGN KEY(redeemed_by_user_id) REFERENCES users(user_id)
);
CREATE INDEX idx_user_coupons_user ON user_coupons(user_id);
CREATE INDEX idx_user_coupons_coupon ON user_coupons(coupon_id);
CREATE INDEX idx_user_coupons_client ON user_coupons(client_id);
CREATE INDEX idx_user_coupons_redeemed_by_pos ON user_coupons(redeemed_by_pos_id);
CREATE INDEX idx_user_coupons_redeemed_by_user ON user_coupons(redeemed_by_user_id);

CREATE TABLE receipts
(
    receipt_id VARCHAR(64) NOT NULL,
    client_id VARCHAR(64) NOT NULL,
    user_id VARCHAR(64) NOT NULL,
    user_card_id VARCHAR(64) NOT NULL,
    purchased_at_time TIMESTAMP WITH TIME ZONE NOT NULL,
    purchased_at_place VARCHAR(128),
    total_items INT NOT NULL,
    total_price INT NOT NULL,
    total_price_currency VARCHAR(3) NOT NULL,
    items JSONB, -- [{name, unit_price, quantity, total_price, currency}]
    external_id VARCHAR(128),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT pk_receipts PRIMARY KEY (receipt_id),
    CONSTRAINT fk_receipts_client FOREIGN KEY(client_id) REFERENCES clients(client_id),
    CONSTRAINT fk_receipts_user FOREIGN KEY(user_id) REFERENCES users(user_id),
    CONSTRAINT fk_receipts_user_card FOREIGN KEY(user_card_id) REFERENCES user_cards(user_card_id)
);
CREATE INDEX idx_receipts_client ON receipts(client_id);
CREATE INDEX idx_receipts_user ON receipts(user_id);
CREATE INDEX idx_receipts_user_card ON receipts(user_card_id);
CREATE INDEX idx_receipts_external_id ON receipts(external_id);

CREATE VIEW view_receipts AS
    SELECT r.receipt_id, r.client_id, r.user_id, r.user_card_id, r.purchased_at_time, r.purchased_at_place, r.total_items, r.total_price, r.total_price_currency, r.items
    FROM receipts r
    WHERE deleted_at IS NULL
    ORDER BY purchased_at_time DESC;

CREATE TABLE qr_tag (
    qr_tag_id VARCHAR(64) NOT NULL,
    client_id VARCHAR(64) NOT NULL,
    program_id VARCHAR(64) NOT NULL,
    points INT NOT NULL DEFAULT 0,
    used_by_user_id VARCHAR(64),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE,
    used_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT pk_qr_tag PRIMARY KEY (qr_tag_id),
    CONSTRAINT fk_qr_tag_clients FOREIGN KEY(client_id) REFERENCES clients(client_id),
    CONSTRAINT fk_qr_tag_programs FOREIGN KEY(program_id) REFERENCES programs(program_id),
    CONSTRAINT fk_qr_tag_users FOREIGN KEY(used_by_user_id) REFERENCES users(user_id)
);
CREATE INDEX idx_qr_tag_client_id ON qr_tag(client_id);
CREATE INDEX idx_qr_tag_program_id ON qr_tag(program_id);
CREATE INDEX idx_qr_tag_used_by_user_id ON qr_tag(used_by_user_id);

CREATE TABLE loyalty_transactions
(
    loyalty_transaction_id VARCHAR(64) NOT NULL,
    client_id VARCHAR(64) NOT NULL,
    location_id VARCHAR(64),
    card_id VARCHAR(64),
    program_id VARCHAR(64),
    user_id VARCHAR(64),
    user_card_id VARCHAR(64),
    points INT NOT NULL DEFAULT 0,
    transaction_object_type INT NOT NULL, -- 1 = order, 2 = reservation, 3 = receipt, 4 = external receipt, 5 = pos, 6 = qr tag, 7 = program reward
    transaction_object_id VARCHAR(64) NOT NULL,
    log JSONB,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE, 
    CONSTRAINT pk_loyalty_transactions PRIMARY KEY (loyalty_transaction_id),
    CONSTRAINT fk_loyalty_transactions_client FOREIGN KEY(client_id) REFERENCES clients(client_id),
    CONSTRAINT fk_loyalty_transactions_location FOREIGN KEY(location_id) REFERENCES locations(location_id),
    CONSTRAINT fk_loyalty_transactions_card FOREIGN KEY(card_id) REFERENCES cards(card_id),
    CONSTRAINT fk_loyalty_transactions_user_card FOREIGN KEY(user_card_id) REFERENCES user_cards(user_card_id),
    CONSTRAINT fk_loyalty_transactions_program FOREIGN KEY(program_id) REFERENCES programs(program_id),    
    CONSTRAINT fk_loyalty_transactions_user FOREIGN KEY(user_id) REFERENCES users(user_id)
);
CREATE INDEX idx_loyalty_transactions_client ON loyalty_transactions(client_id);
CREATE INDEX idx_loyalty_transactions_location ON loyalty_transactions(location_id);
CREATE INDEX idx_loyalty_transactions_user_card ON loyalty_transactions(user_card_id);
CREATE INDEX idx_loyalty_transactions_card ON loyalty_transactions(card_id);
CREATE INDEX idx_loyalty_transactions_user ON loyalty_transactions(user_id);

CREATE VIEW view_loyalty_transaction_status AS
    SELECT 
        SUM(lt.points) AS points, p.digits,
        lt.user_id, p.program_id 
    FROM loyalty_transactions lt
    INNER JOIN programs p ON lt.program_id = p.program_id
    GROUP BY lt.user_id, p.program_id;

CREATE TABLE client_sellers
(
    client_seller_id VARCHAR(64) NOT NULL,
    client_id VARCHAR(64) NOT NULL,
    seller_id VARCHAR(64) NOT NULL,
    share INT NOT NULL DEFAULT 0, -- in bps (1/100 of 1%), 1 = 0.01%, 100 = 1%, 10000 = 100%
    notes VARCHAR(1024),
    blocked BOOL NOT NULL DEFAULT FALSE,
    meta JSONB,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(), 
    deleted_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT pk_client_sellers PRIMARY KEY (client_seller_id),
    CONSTRAINT fk_client_sellers_client FOREIGN KEY(client_id) REFERENCES clients(client_id),
    CONSTRAINT fk_client_sellers_seller FOREIGN KEY(seller_id) REFERENCES users(user_id)
);
CREATE INDEX idx_client_sellers_client ON client_sellers(client_id);
CREATE INDEX idx_client_sellers_seller ON client_sellers(seller_id);

CREATE TABLE seller_payments
(
    seller_payment_id VARCHAR(64) NOT NULL,
    client_id VARCHAR(64) NOT NULL,
    seller_id VARCHAR(64) NOT NULL,
    seller_invoice VARCHAR(64),
    status INT NOT NULL DEFAULT 0, -- 0 = pending, 1 = in progress, 2 = cancelled, 3 = failed, 4 = paid
    total_price INT NOT NULL,
    total_currency VARCHAR(3) NOT NULL,
    due_date INT NULL,
    paid_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(), 
    deleted_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT pk_seller_payments PRIMARY KEY (seller_payment_id),
    CONSTRAINT fk_seller_payments_client FOREIGN KEY(client_id) REFERENCES clients(client_id),
    CONSTRAINT fk_seller_payments_seller FOREIGN KEY(seller_id) REFERENCES users(user_id)
);
CREATE INDEX idx_seller_payments_client ON seller_payments(client_id);
CREATE INDEX idx_seller_payments_seller ON seller_payments(seller_id);

CREATE TABLE client_payment_providers
(
    client_payment_provider_id VARCHAR(64) NOT NULL,
    name VARCHAR(64) NOT NULL,
    type INT NOT NULL, -- 1 = cash, 2 = stripe, 3 = google pay, 4 = apple pay, 5 = btcserver.org, 6 = paypal, 7 = bank transfer
    fixed_price INT NOT NULL DEFAULT 0,
    currency VARCHAR(3) NOT NULL,
    percentage INT NOT NULL DEFAULT 0, -- in bps, 1 = 0.01%, 25 = 0.25%, 425 = 4.25%, 100 = 1%, 1000 = 10%, 10000 = 100%
    meta JSONB,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT pk_client_payment_providers PRIMARY KEY (client_payment_provider_id)
);

CREATE TABLE client_payments
(
    client_payment_id VARCHAR(64) NOT NULL,
    client_id VARCHAR(64) NOT NULL,
    seller_id VARCHAR(64) NOT NULL, 
    status INT NOT NULL DEFAULT 0, -- 0 = pending, 1 = processing, 2 = cancelled, 3 = failed, 4 = paid
    period INT NOT NULL,
    client_payment_provider_id VARCHAR(64),
    active_cards INT NOT NULL,
    base INT NOT NULL,
    pricing INT NOT NULL,
    currency VARCHAR(3) NOT NULL,
    period_from INT NOT NULL,
    period_to INT NOT NULL,
    due_date INT NOT NULL,
    paid_at TIMESTAMP WITH TIME ZONE,
    seller_payment_id VARCHAR(64),
    meta JSONB,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(), 
    deleted_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT pk_client_payments PRIMARY KEY (client_payment_id),
    CONSTRAINT fk_client_payments_client FOREIGN KEY(client_id) REFERENCES clients(client_id),
    CONSTRAINT fk_client_payments_seller_id FOREIGN KEY(seller_id) REFERENCES users(user_id),
    CONSTRAINT fk_client_payments_client_payment_provider FOREIGN KEY(client_payment_provider_id) REFERENCES client_payment_providers(client_payment_provider_id),
    CONSTRAINT fk_client_payments_seller_payment FOREIGN KEY(seller_payment_id) REFERENCES seller_payments(seller_payment_id)
);
CREATE INDEX idx_client_payments_client ON client_payments(client_id);
CREATE INDEX idx_client_payments_seller_id ON client_payments(seller_id);
CREATE INDEX idx_client_payments_seller_payment ON client_payments(seller_payment_id);
CREATE INDEX idx_client_payments_client_payment_provider ON client_payments(client_payment_provider_id);

CREATE TABLE leaflets
(
    leaflet_id VARCHAR(64) NOT NULL,
    client_id VARCHAR(64) NOT NULL,
    location_id VARCHAR(64),
    country VARCHAR(8) NOT NULL,
    name VARCHAR(64) NOT NULL,
    rank INT NOT NULL DEFAULT 1,
    leaflet VARCHAR(1024),
    thumbnail VARCHAR(1024),
    thumbnail_bh VARCHAR(64),
    pages VARCHAR(1024)[],
    pages_bh VARCHAR(64)[],
    valid_from INT NOT NULL,
    valid_to INT,
    blocked BOOL NOT NULL DEFAULT FALSE,
    meta JSONB,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT pk_leaflets PRIMARY KEY (leaflet_id),
    CONSTRAINT fk_leaflets_client FOREIGN KEY(client_id) REFERENCES clients(client_id),
    CONSTRAINT fk_leaflets_location FOREIGN KEY(location_id) REFERENCES locations(location_id)
);
CREATE INDEX idx_leaflets_client ON leaflets(client_id);
CREATE INDEX idx_leaflets_location ON leaflets(location_id);

CREATE VIEW view_leaflets AS
    SELECT leaflet_id, l.client_id, l.location_id, l.country, l.name, valid_from, valid_to, thumbnail, thumbnail_bh, leaflet, pages, pages_bh,
        c.name AS client_name, c.logo AS client_logo, c.logo_bh AS client_logo_bh,
        loc.name AS location_name, loc.type AS location_type, loc.address_line_1 AS location_address_line_1, loc.address_line_2 AS location_address_line_2, loc.city AS location_city, loc.state AS location_state, loc.zip AS location_zip, loc.country AS location_country, loc.phone AS location_phone, loc.email AS location_email, loc.website AS location_website
    FROM leaflets l
    INNER JOIN clients c ON c.client_id = l.client_id
    LEFT JOIN locations loc ON loc.location_id = l.location_id;

CREATE TABLE messages
(
    message_id VARCHAR(64) NOT NULL,
    message_type INT NOT NULL,
    status INT NOT NULL DEFAULT 1,
    from_participant INT NOT NULL,
    from_id VARCHAR(64),
    to_participant INT NOT NULL,
    to_id VARCHAR(64),
    subject TEXT,
    body TEXT,
    payload JSONB,
    response JSONB,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT pk_messages PRIMARY KEY (message_id)
);
CREATE INDEX idx_messages_status_message_type ON messages (status, message_type);
CREATE INDEX idx_messages_from_id ON messages(from_id);
CREATE INDEX idx_messages_to_id ON messages(to_id);

CREATE TABLE tokens (
    token_id VARCHAR(64) NOT NULL,
    user_id VARCHAR(64) NOT NULL,
    refresh_token VARCHAR(512) NOT NULL,
    family VARCHAR(64) NULL,
    expires_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    blocked BOOLEAN DEFAULT FALSE,
    CONSTRAINT pk_tokens PRIMARY KEY (token_id),
    CONSTRAINT fk_tokens_users FOREIGN KEY(user_id) REFERENCES users(user_id)
);
CREATE INDEX idx_tokens_refresh_token ON tokens(refresh_token);
CREATE INDEX idx_tokens_family ON tokens(family);

CREATE TABLE client_ratings (
    client_rating_id VARCHAR(64) NOT NULL,
    client_id VARCHAR(64) NOT NULL,
    user_id VARCHAR(64) NOT NULL,
    rating INT NOT NULL,
    language VARCHAR(8) NOT NULL,
    comment VARCHAR(2000),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT pk_client_ratings PRIMARY KEY (client_rating_id),
    CONSTRAINT fk_client_ratings_clients FOREIGN KEY(client_id) REFERENCES clients(client_id),
    CONSTRAINT fk_client_ratings_users FOREIGN KEY(user_id) REFERENCES users(user_id)
);
CREATE INDEX idx_client_ratings_client_id ON client_ratings(client_id);
CREATE INDEX idx_client_ratings_user_id ON client_ratings(user_id);

CREATE TABLE user_ratings (
    user_rating_id VARCHAR(64) NOT NULL,
    user_id VARCHAR(64) NOT NULL,
    client_id VARCHAR(64) NOT NULL,
    rating INT NOT NULL,
    language VARCHAR(8) NOT NULL,
    comment VARCHAR(2000),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT pk_user_ratings PRIMARY KEY (user_rating_id),
    CONSTRAINT fk_user_ratings_users FOREIGN KEY(user_id) REFERENCES users(user_id),
    CONSTRAINT fk_user_ratings_clients FOREIGN KEY(client_id) REFERENCES clients(client_id)
);
CREATE INDEX idx_user_ratings_user_id ON user_ratings(user_id);
CREATE INDEX idx_user_ratings_client_id ON user_ratings(client_id);

CREATE TABLE product_item_ratings (
    product_item_rating_id VARCHAR(64) NOT NULL,
    product_item_id VARCHAR(64) NOT NULL,
    user_id VARCHAR(64) NOT NULL,
    client_id VARCHAR(64) NOT NULL,
    rating INT NOT NULL,
    language VARCHAR(8) NOT NULL,
    comment VARCHAR(2000),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT pk_product_item_ratings PRIMARY KEY (product_item_rating_id),
    CONSTRAINT fk_product_item_ratings_product_items FOREIGN KEY(product_item_id) REFERENCES product_items(product_item_id),
    CONSTRAINT fk_product_item_ratings_users FOREIGN KEY(user_id) REFERENCES users(user_id),
    CONSTRAINT fk_product_item_ratings_clients FOREIGN KEY(client_id) REFERENCES clients(client_id)
);
CREATE INDEX idx_product_item_ratings_product_item_id ON product_item_ratings(product_item_id);
CREATE INDEX idx_product_item_ratings_user_id ON product_item_ratings(user_id);
CREATE INDEX idx_product_item_ratings_client_id ON product_item_ratings(client_id);

/*
CREATE TABLE client_stats(
    stat_id VARCHAR(64) NOT NULL,
    client_id VARCHAR(64) NOT NULL,
    type INT NOT NULL, -- totalUsers, currentActiveUserCards, activeUserCards, newUsers, newUserCards
    period INT NOT NULL DEFAULT(1), -- permanent, week, month, year
    date INT NOT NULL, -- for permanent = 0, for week date of monday, for month date of 1st day, for year date of 1st day of january
    value INT NOT NULL DEFAULT 0, -- counter
    digits INT NOT NULL DEFAULT 0, -- 0 = integer, 1 = 0.1, 2 = 0.01, 3 = 0.001, 4 = 0.0001, ...
    currency VARCHAR(3),
    meta JSONB,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT pk_client_stats PRIMARY KEY (stat_id),
    CONSTRAINT fk_client_stats_client FOREIGN KEY(client_id) REFERENCES clients(client_id)
);
CREATE INDEX idx_client_stats_client ON client_stats(client_id);
CREATE INDEX idx_client_stats_date ON client_stats(date);    
*/

-- Functions & triggers

CREATE OR REPLACE FUNCTION update_next_user_card_number()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE clients
    SET next_user_card_number = next_user_card_number + 1
    WHERE client_id = NEW.client_id;
    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_last_number
AFTER INSERT ON user_cards
FOR EACH ROW
EXECUTE FUNCTION update_next_user_card_number();

CREATE OR REPLACE FUNCTION update_user_card_touched_at()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE user_cards
    SET touched_at = NOW()
    WHERE deleted_at IS NULL AND user_card_id = NEW.user_card_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER loyalty_transactions_insert_trigger
AFTER INSERT ON loyalty_transactions
FOR EACH ROW
EXECUTE FUNCTION update_user_card_touched_at();

--

CREATE EXTENSION IF NOT EXISTS unaccent;

CREATE OR REPLACE FUNCTION jaro_winkler(ying TEXT, yang TEXT)
    RETURNS float8 AS $$
DECLARE
    ying_len integer := LENGTH(ying);
    yang_len integer := LENGTH(yang);
    min_len integer := GREATEST(ying_len, yang_len);
    search_range integer;
    ying_flags bool[];
    yang_flags bool[];
    common_chars float8 := 0;
    ying_ch TEXT;
    hi integer;
    low integer;
    trans_count integer := 0;
    weight float8;
    i integer;
    j integer;
    jj integer;
    k integer;
BEGIN

    IF ying_len = 0 OR yang_len = 0 THEN
        RETURN 0;
    END IF;
    
    ying := lower(ying);
    yang := lower(yang);

    ying := unaccent(ying);
    yang := unaccent(yang);

    search_range := (GREATEST(ying_len, yang_len) / 2) - 1;
    IF search_range < 0 THEN
        search_range := 0;
    END IF;
    FOR i IN 1 .. ying_len LOOP
        ying_flags[i] := false;
    END LOOP;
    FOR i IN 1 .. yang_len LOOP
        yang_flags[i] := false;
    END LOOP;

    -- looking only within search range, count & flag matched pairs
    FOR i in 1 .. ying_len LOOP
        ying_ch := SUBSTRING(ying FROM i for 1);
        IF i > search_range THEN
            low := i - search_range;
        ELSE
            low := 1;
        END IF;
        IF i + search_range <= yang_len THEN
            hi := i + search_range;
        ELSE
            hi := yang_len;
        END IF;
        <<inner>>
        FOR j IN low .. hi LOOP
            IF NOT yang_flags[j] AND
                 SUBSTRING(yang FROM j FOR 1) = ying_ch THEN
               ying_flags[i] := true;
               yang_flags[j] := true;
               common_chars := common_chars + 1;
               EXIT inner;
            END IF;
        END LOOP inner;
    END LOOP;
    -- short circuit if no characters match
    IF common_chars = 0 THEN
        RETURN 0;
    END IF;

    -- count transpositions
    k := 1;
    FOR i IN 1 .. ying_len LOOP
        IF ying_flags[i] THEN
            <<inner2>>
            FOR j IN k .. yang_len LOOP
                jj := j;
                IF yang_flags[j] THEN
                    k := j + 1;
                    EXIT inner2;
                END IF;
            END LOOP;
            IF SUBSTRING(ying FROM i FOR 1) <>
                    SUBSTRING(yang FROM jj FOR 1) THEN
                trans_count := trans_count + 1;
            END IF;
        END IF;
    END LOOP;
    trans_count := trans_count / 2;

    -- adjust for similarities in nonmatched characters
    weight := ((common_chars/ying_len + common_chars/yang_len +
               (common_chars-trans_count) / common_chars)) / 3;

    -- winkler modification: continue to boost if strings are similar
    IF weight > 0.7 AND ying_len > 3 AND yang_len > 3 THEN
       -- adjust for up to first 4 chars in common
       j := LEAST(min_len, 4);
       i := 1;
       WHILE i - 1 < j AND
             SUBSTRING(ying FROM i FOR 1) = SUBSTRING(yang FROM i FOR 1) LOOP
           i := i + 1;
       END LOOP;
       weight := weight + (i - 1) * 0.1 * (1.0 - weight);
    END IF;

    RETURN weight;

END;
$$
LANGUAGE plpgsql;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE OR REPLACE FUNCTION distance(
    lat1 DOUBLE PRECISION,
    lon1 DOUBLE PRECISION,
    lat2 DOUBLE PRECISION,
    lon2 DOUBLE PRECISION)
  RETURNS DOUBLE PRECISION AS
$BODY$
DECLARE
    R integer = 6371e3; -- Meters
    rad double precision = 0.01745329252;

    φ1 double precision = lat1 * rad;
    φ2 double precision = lat2 * rad;
    Δφ double precision = (lat2-lat1) * rad;
    Δλ double precision = (lon2-lon1) * rad;

    a double precision = sin(Δφ/2) * sin(Δφ/2) + cos(φ1) * cos(φ2) * sin(Δλ/2) * sin(Δλ/2);
    c double precision = 2 * atan2(sqrt(a), sqrt(1-a));
BEGIN
    RETURN R * c;
END
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

/*
CREATE OR REPLACE FUNCTION update_user_card_points()
RETURNS TRIGGER AS $$
BEGIN
    -- Aktualizujte počet bodov v user_cards založené na novom zázname v loyalty_transactions
    UPDATE user_cards
    SET points = points + NEW.points
    WHERE user_card_id = NEW.user_card_id;

    -- Vrátiť nový záznam
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_user_card_points
AFTER INSERT ON loyalty_transactions
FOR EACH ROW
EXECUTE FUNCTION update_user_card_points();
*/

CREATE OR REPLACE FUNCTION intDateNow()
RETURNS INTEGER AS $$
BEGIN
  RETURN TO_CHAR(NOW(), 'YYYYMMDD')::INT;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION intDateYesterday()
RETURNS INTEGER AS $$
BEGIN
  RETURN TO_CHAR(NOW() - INTERVAL '1 day', 'YYYYMMDD')::INT;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- last stuff, everything should be in place above this stuff

CREATE TABLE versions
(
    version_id SERIAL PRIMARY KEY,
    product INT NOT NULL, -- 1 = database, 2 = mobile api, 3 = cron api, 4 = vega application, 5 = vega dashboard
    environment INT NOT NULL, -- 1 = development, 2 = quality assurance, 3 = demo, 4 = production
    version VARCHAR(32) NOT NULL,
    build INT NOT NULL,
    active BOOL NOT NULL DEFAULT TRUE,
    notes VARCHAR(1024),
    meta JSONB,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_versions_product ON versions(product);
CREATE INDEX idx_versions_environment ON versions(environment);
CREATE UNIQUE INDEX idx_versions_product_environment_build ON versions(product, environment, build);

CREATE OR REPLACE FUNCTION insert_version(p_product INT, p_environment INT, p_version VARCHAR(32), p_build INT, p_notes VARCHAR(1024) = NULL, p_meta JSONB = NULL)
RETURNS INT AS $$
DECLARE
    inserted_version_id INTEGER;
BEGIN
    
    inserted_version_id := 0;
    
    BEGIN
        INSERT INTO versions(product, environment, version, build, notes, meta) 
        VALUES (p_product, p_environment, p_version, p_build, p_notes, p_meta) 
        RETURNING version_id INTO inserted_version_id;        
    
        UPDATE versions SET active = FALSE WHERE product = p_product AND environment = p_environment AND version_id != inserted_version_id;
    EXCEPTION WHEN unique_violation THEN
        inserted_version_id := -1;
    END;

    RETURN inserted_version_id;
END;

$$ LANGUAGE plpgsql;

SELECT insert_version(1, 1, '1.0', 1, 'Initial version', '{}');


-- eof
