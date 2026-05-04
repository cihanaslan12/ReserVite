-- (BR-10) Un restaurant doit avoir au moins un manager

CREATE OR REPLACE FUNCTION fn_check_min_1_manager()
    RETURNS TRIGGER AS
$$
    DECLARE
        _nb_managers int;
        _id_restaurant int;
BEGIN
    IF TG_OP = 'DELETE' THEN
        _id_restaurant = OLD.restaurant;
    ELSE
        _id_restaurant = NEW.restaurant;
    END IF;

    SELECT COUNT(*) INTO _nb_managers
    FROM restaurant_managers
    WHERE restaurant = _id_restaurant;

    IF _nb_managers = 0 THEN
        RAISE EXCEPTION 'Le restaurant doit avoir au moins 1 manager';
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_check_min_1_manager ON restaurant_managers;
CREATE CONSTRAINT TRIGGER trg_check_min_1_manager
    AFTER INSERT OR UPDATE OR DELETE
    ON restaurant_managers
    DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW
EXECUTE FUNCTION fn_check_min_1_manager();