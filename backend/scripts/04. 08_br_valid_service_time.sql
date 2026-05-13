-- (BR-08) Au moment de leur création ou de leur modification,
-- les heures de début et de fin d'un service doivent être alignées
-- sur les créneaux de réservation pour le restaurant.

CREATE OR REPLACE FUNCTION fn_check_valid_service_time()
    RETURNS TRIGGER AS
$$
BEGIN
    IF EXISTS(
        SELECT 1
        FROM restaurants r
        WHERE r.id = NEW.restaurant
            AND ((EXTRACT(minute FROM NEW.start_time) % r.slot_duration != 0)
                OR (EXTRACT(minute FROM NEW.end_time) % r.slot_duration != 0))
    ) THEN
        RAISE EXCEPTION 'Le nouveau service ne correspond pas aux créneaux de réservation du restaurant';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;



DROP TRIGGER IF EXISTS trg_check_service_time ON services;
CREATE TRIGGER trg_check_service_time
    BEFORE INSERT OR UPDATE
    ON services
    FOR EACH ROW
EXECUTE FUNCTION fn_check_valid_service_time();