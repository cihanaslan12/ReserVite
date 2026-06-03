-- (BR-07) Pour un même jour de la semaine,
-- les services d'un restaurant ne peuvent pas se chevaucher.

CREATE OR REPLACE FUNCTION fn_check_services_overlaping()
    RETURNS TRIGGER AS
$$
BEGIN
    IF EXISTS(
        SELECT 1
        FROM services s
        WHERE s.id != NEW.id
            AND s.restaurant = NEW.restaurant
            AND s.day_of_week = NEW.day_of_week
            AND s.end_time > NEW.start_time
            AND s.start_time < NEW.end_time
    ) THEN
        RAISE EXCEPTION 'Les heures de services du jour se chevauchent!';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_check_services_overlaping ON services;
CREATE TRIGGER trg_check_services_overlaping
    BEFORE INSERT OR UPDATE
    ON services
    FOR EACH ROW
EXECUTE FUNCTION fn_check_services_overlaping();