CREATE OR REPLACE FUNCTION fn_check_valid_reservation()
    RETURNS TRIGGER AS
$$
BEGIN
--    max 3 vip par restaurant
--    (select count(*) from reservations res where res.restaurant = rest.id and res.status = 'pending')::int as in_pending,
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_check_valid_reservation ON reservations;
CREATE TRIGGER trg_check_valid_reservation
    BEFORE UPDATE
    ON reservations
    FOR EACH ROW
EXECUTE FUNCTION fn_check_valid_reservation();