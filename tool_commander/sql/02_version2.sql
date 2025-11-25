DROP TRIGGER IF EXISTS trigger_update_user_card_points ON loyalty_transactions;
DROP FUNCTION IF EXISTS update_user_card_points;

CREATE OR REPLACE FUNCTION update_user_card_touched_at()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE user_cards
    SET touched_at = NOW()
    WHERE user_card_id = NEW.user_card_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER loyalty_transaction_update_user_card
AFTER INSERT ON loyalty_transactions
FOR EACH ROW
WHEN (NEW.user_card_id IS NOT NULL)
EXECUTE FUNCTION update_user_card_touched_at();

SELECT insert_version(1, 1, '1.1', 2, 'Dropped trigger_update_user_card_points, update_user_card_points', '{}');

-- eof
