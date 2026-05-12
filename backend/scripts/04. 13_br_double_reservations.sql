-- (BR-13) Un client ne peut pas avoir deux réservations en attente,
-- confirmées ou terminées pour une même date et un même service

CREATE OR REPLACE FUNCTION fn_check_double_reservations()
    RETURNS TRIGGER AS
$$
BEGIN
    IF EXISTS(
        SELECT 1
        FROM reservations r
            JOIN services s ON s.restaurant = r.restaurant
        WHERE r.id != NEW.id
            AND r.client = NEW.client
            AND NEW.status IN ('pending', 'confirmed', 'completed')
            AND r.status IN ('pending', 'confirmed', 'completed')
            AND NEW.datetime::date = r.datetime::date
            AND NEW.datetime::time >= s.start_time AND NEW.datetime::time < s.end_time
            AND r.datetime::time >= s.start_time AND r.datetime::time < s.end_time
    ) THEN
        RAISE EXCEPTION 'Un client ne peut pas avoir 2 réservations en attente, confirmée ou terminée pour le même service du jour';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_check_double_reservations ON reservations;
CREATE TRIGGER trg_check_double_reservations
    BEFORE INSERT OR UPDATE
    ON reservations
    FOR EACH ROW
EXECUTE FUNCTION fn_check_double_reservations();

-- Aucune table ne peut être attribuée à une réservation en attente ou annulée (4)