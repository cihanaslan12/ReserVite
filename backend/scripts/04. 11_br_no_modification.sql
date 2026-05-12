-- (BR-11) Une réservation terminée ou annulée ne peut pas être modifiée

CREATE OR REPLACE FUNCTION fn_check_no_modification()
    RETURNS TRIGGER AS
$$
BEGIN
    IF OLD.status IN ('completed', 'cancelled') THEN
        RAISE EXCEPTION 'Une réservation terminée ou annulée ne peut être modifiée !';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_check_no_modification ON reservations;
CREATE TRIGGER trg_check_no_modification
    BEFORE UPDATE
    ON reservations
    FOR EACH ROW
EXECUTE FUNCTION fn_check_no_modification();

-- Aucune table ne peut être attribuée à une réservation en attente ou annulée (4)