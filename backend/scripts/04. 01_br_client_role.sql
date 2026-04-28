CREATE OR REPLACE FUNCTION fn_check_client_role()
    RETURNS TRIGGER AS
$$
DECLARE
    cl_role role_type;
BEGIN
    IF NOT EXISTS(
        SELECT 1
        FROM users
        WHERE id = NEW.client
            AND role = 'client')
        THEN
            RAISE EXCEPTION 'Seul un client peut effectuer une réservation!';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_check_client_role ON reservations;

CREATE TRIGGER trg_check_client_role
    BEFORE INSERT
    ON reservations
    FOR EACH ROW
EXECUTE FUNCTION fn_check_client_role();