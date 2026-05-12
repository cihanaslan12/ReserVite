-- (BR-05) Au moment de sa création ou de sa modification,
-- l'heure d'une réservation doit correspondre à un créneau de réservation (slot) pour le restaurant.
-- Un créneau de réservation doit toujours correspondre à une heure exacte
-- (sans minutes) augmentée d'un multiple de la durée du créneau de réservation.

CREATE OR REPLACE FUNCTION fn_check_reservation_valid_slot()
    RETURNS TRIGGER AS
$$
BEGIN
    IF NOT EXISTS(
        SELECT 1
        FROM services s
            JOIN restaurants r ON r.id = s.restaurant
        WHERE NEW.restaurant = s.restaurant
            AND EXTRACT(isodow FROM NEW.datetime) = s.day_of_week
            AND EXTRACT(minute FROM NEW.datetime) % r.slot_duration = 0
            AND (NEW.datetime::time >= s.start_time
                     AND NEW.datetime::time <= s.end_time - r.slot_duration * INTERVAL '1 minute')
        ) THEN
        RAISE EXCEPTION 'Le créneau de la réservation ne correspond pas au service du restaurant!';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_check_reservation_valid_slot ON reservations;
CREATE TRIGGER trg_check_reservation_valid_slot
    BEFORE INSERT OR UPDATE
    ON reservations
    FOR EACH ROW
EXECUTE FUNCTION fn_check_reservation_valid_slot();

-- Aucune table ne peut être attribuée à une réservation en attente ou annulée