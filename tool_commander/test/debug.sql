ALTER TABLE clients ALTER COLUMN updated_at SET DEFAULT NOW();

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
