-- (BR-06) Une table ne peut pas faire l'objet
-- de deux réservations terminées ou confirmées
-- pour une même date et un même service.

CREATE OR REPLACE FUNCTION fn_check_available_table()
    RETURNS TRIGGER AS
$$
BEGIN
    IF EXISTS(
        SELECT 1
        FROM reservation_tables rt2
            JOIN reservations r2 ON r2.id = rt2.reservation
            JOIN reservations r1 ON r1.id = NEW.reservation
        WHERE rt2."table" = NEW."table"
            AND rt2.reservation != NEW.reservation
            AND r2.datetime = r1.datetime
            AND r1.status IN ('confirmed', 'completed')
            AND r2.status IN ('confirmed', 'completed')
        ) THEN
            RAISE EXCEPTION 'Cette table est déjà réservée pour ce créneau';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_check_available_table ON reservation_tables;
CREATE CONSTRAINT TRIGGER trg_check_available_table
    AFTER INSERT OR UPDATE
    ON reservation_tables
    DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW
EXECUTE FUNCTION fn_check_available_table();

-- Test failed: command should have raised an exception (6)
-- Le créneau de la réservation ne correspond pas au service du restaurant!