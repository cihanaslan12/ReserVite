-- (BR-04) L'heure d'une réservation confirmée, terminée ou en attente
-- doit être comprise entre l'heure de début et l'heure de fin d'un service
-- pour le même jour de la semaine.

CREATE OR REPLACE FUNCTION fn_check_valid_reservation_time()
    RETURNS TRIGGER AS
$$
BEGIN
    IF NEW.status IN ('confirmed', 'completed', 'pending') THEN
        IF NOT EXISTS(
            SELECT 1
            FROM services s
            WHERE NEW.restaurant = s.restaurant
                AND EXTRACT(isodow from NEW.datetime) = s.day_of_week
                AND NEW.datetime::time >= s.start_time
                AND NEW.datetime::time <= s.end_time
        ) THEN
            RAISE EXCEPTION 'L''heure de la réservation n''est pas comprise dans les heures de service de ce jour';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_check_valid_reservation_time ON reservations;
CREATE TRIGGER trg_check_valid_reservation_time
    BEFORE INSERT OR UPDATE
    ON reservations
    FOR EACH ROW
EXECUTE FUNCTION fn_check_valid_reservation_time();