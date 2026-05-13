-- (BR-12) Une réservation en attente ou annulée ne peut être associée à aucune une table.

CREATE OR REPLACE FUNCTION fn_check_no_table_reservations()
    RETURNS TRIGGER AS
$$
BEGIN
    IF EXISTS(
        SELECT 1
        FROM reservation_tables
        WHERE reservation IN (SELECT id
                              FROM reservations
                              WHERE status IN ('pending', 'cancelled'))
    ) THEN
        RAISE EXCEPTION 'Aucune table ne peut être attribuée à une réservation en attente ou annulée';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_check_no_table_reservations ON reservation_tables;
CREATE CONSTRAINT TRIGGER trg_check_no_table_reservations
    AFTER INSERT
    ON reservation_tables
    DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW
EXECUTE FUNCTION fn_check_no_table_reservations();

DROP TRIGGER IF EXISTS trg_check_no_table_reservations ON reservations;
CREATE CONSTRAINT TRIGGER trg_check_no_table_reservations
    AFTER UPDATE of status
    ON reservations
    DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW
EXECUTE FUNCTION fn_check_no_table_reservations();