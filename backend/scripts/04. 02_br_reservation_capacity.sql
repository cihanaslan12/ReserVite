-- (BR-02) Le nombre de convives d'une réservation confirmée ou terminée
-- ne peut pas dépasser la capacité totale des tables associées à la réservation.
-- Ceci implique qu'une réservation confirmée ou terminée doit avoir
-- au moins une table réservée appartenant au restaurant de la réservation.

CREATE OR REPLACE FUNCTION fn_check_reservation_capacity()
    RETURNS TRIGGER AS
$$
BEGIN
   IF EXISTS(
       SELECT r.id, r.number_of_guests, COALESCE(SUM(t.capacity), 0)
       FROM reservations r
            LEFT JOIN reservation_tables rt ON rt.reservations = r.id
            LEFT JOIN table t on t.id = rt."table"
            WHERE r.status IN ('confirmed'::status_type, 'completed'::status_type)
            GROUP BY r.id, r.id, r.number_of_guests
            HAVING r.number_of_guests > COALESCE(SUM(t.capacity), 0)) THEN
       RAISE EXCEPTION 'Le nombre de convives dépasse la capacité totale.';
   END IF;

   RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_validate_reservation_capacity ON reservations;
    CREATE TRIGGER trg_validate_reservation_capacity
    AFTER INSERT OR UPDATE OF number_of_guests, status
    ON reservations
    FOR EACH ROW
EXECUTE FUNCTION fn_check_reservation_capacity();

DROP TRIGGER IF EXISTS trg_validate_reservation_capacity ON reservation_tables;
    CREATE CONSTRAINT TRIGGER trg_validate_reservation_tables_capacity
    AFTER DELETE
    ON reservation_tables
    DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW
EXECUTE FUNCTION fn_check_reservation_capacity();

DROP TRIGGER IF EXISTS trg_validate_reservation_capacity ON tables;
    CREATE TRIGGER trg_validate_table_capacity
    AFTER UPDATE OF capacity OR DELETE
    ON tables
    FOR EACH ROW
EXECUTE FUNCTION fn_check_reservation_capacity();