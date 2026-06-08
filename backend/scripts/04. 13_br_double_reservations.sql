-- (BR-13) Un client ne peut pas avoir deux réservations en attente,
-- confirmées ou terminées pour une même date et un même service

CREATE OR REPLACE FUNCTION fn_check_double_reservations()
    RETURNS TRIGGER AS
$$
DECLARE
    new_service_id INT;
BEGIN
    SELECT id INTO new_service_id
    FROM services
    WHERE restaurant = NEW.restaurant
        AND day_of_week = EXTRACT(isodow FROM NEW.datetime)::int
        AND NEW.datetime::time >= start_time
        AND NEW.datetime::time < end_time
    LIMIT 1;

    IF EXISTS(
        SELECT 1
        FROM reservations r
            JOIN services s ON s.restaurant = r.restaurant
                AND s.day_of_week = EXTRACT(isodow FROM r.datetime)::int
                AND r.datetime::time >= s.start_time
                AND r.datetime::time < s.end_time
        WHERE r.id != NEW.id
            AND r.client = NEW.client
            AND NEW.status IN ('pending', 'confirmed', 'completed')
            AND r.status IN ('pending', 'confirmed', 'completed')
            AND NEW.datetime::date = r.datetime::date
            AND s.id = new_service_id
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