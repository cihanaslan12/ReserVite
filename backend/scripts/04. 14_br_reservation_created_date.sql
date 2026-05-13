-- (BR-14) Une réservation ne peut pas être créée dans le passé
-- (ne doit être vérifié qu'au moment de la création).

CREATE OR REPLACE FUNCTION fn_check_reservation_created_date()
    RETURNS TRIGGER AS
$$
BEGIN
    IF NEW.datetime < (SELECT simulated_time FROM system_time)
       THEN
        RAISE EXCEPTION 'Une réservation ne peut pas être créée dans le passé';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_check_reservation_created_date ON reservations;
CREATE TRIGGER trg_check_reservation_created_date
    BEFORE INSERT
    ON reservations
    FOR EACH ROW
EXECUTE FUNCTION fn_check_reservation_created_date();

-- Test failed: command should have raised an exception