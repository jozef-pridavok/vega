SELECT
    gen_random_uuid () AS card_id,
    '{"oldCardId":"' || "objectId" || '"}' AS meta,
    "name",
    "color",
    "regions",
    CASE
        WHEN "subcode" = 'upca' THEN 1
        WHEN "subcode" = 'upce' THEN 2
        WHEN "subcode" = 'ean8' THEN 3
        WHEN "subcode" = 'ean13' THEN 4
        WHEN "subcode" = 'code39' THEN 5
        WHEN "subcode" = 'code93' THEN 6
        WHEN "subcode" = 'code128' THEN 7
        WHEN "subcode" = 'itf14' THEN 8
        WHEN "subcode" = 'interleaved2of5' THEN 9
        WHEN "subcode" = 'pdf417' THEN 10
        WHEN "subcode" = 'aztec' THEN 11
        WHEN "subcode" = 'qr' THEN 12
        WHEN "subcode" = 'datamatrix' THEN 13
        ELSE 7
    END AS code_type
FROM "Cards"
WHERE
    "client" IS NULL
    AND "name" IS NOT NULL;

--target
INSERT INTO
    cards (
        card_id,
        code_type,
        name,
        color,
        countries,
        meta
    )
VALUES (
        $.card_id,
        $.code_type,
        $Cards.name,
        $Cards.color,
        $Cards.regions,
        $.meta
    ) ON CONFLICT (card_id) DO
UPDATE
SET
    code_type = EXCLUDED.code_type,
    name = EXCLUDED.name,
    logo = EXCLUDED.logo,
    color = EXCLUDED.color,
    countries = EXCLUDED.countries;