-- (BR-03) Les tables associées à une réservation doivent appartenir
-- au restaurant de la réservation.

CREATE OR REPLACE FUNCTION fn_check_table_of_restaurant()
    RETURNS TRIGGER AS
$$
BEGIN
    IF EXISTS(SELECT 1
              FROM tables t
                JOIN reservations r ON r.id = NEW.reservation
              WHERE t.id = NEW."table"
                AND t.restaurant != r.restaurant
              ) THEN
        RAISE EXCEPTION 'La table de cette réservation n''appartient pas à ce restaurant!';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_check_table_of_restaurant ON reservation_tables;
CREATE TRIGGER trg_check_table_of_restaurant
    BEFORE INSERT
    ON reservation_tables
    FOR EACH ROW
EXECUTE FUNCTION fn_check_table_of_restaurant();