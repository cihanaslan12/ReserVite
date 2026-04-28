/* FOR ALL */

CREATE OR REPLACE FUNCTION check_id_modification()
    RETURNS TRIGGER AS
$$
BEGIN
    IF OLD.id != NEW.id THEN
        RAISE EXCEPTION 'Changing the ID is not allowed';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

/* USERS */

ALTER TABLE users
ADD CONSTRAINT check_full_name_length CHECK ( length(trim(full_name)) >= 3 );

ALTER TABLE users
ADD CONSTRAINT check_valid_password CHECK ( (trim(password)) ~ '^\$2[aby]\$\d{2}\$[./A-Za-z0-9]{53}$' );

CREATE OR REPLACE FUNCTION check_user_prohibited_changes()
    RETURNS TRIGGER AS
$$
BEGIN
    IF OLD.id != NEW.id THEN
        RAISE EXCEPTION 'Changing the ID is not allowed';
    END IF;
    IF OLD.full_name != NEW.full_name THEN
        RAISE EXCEPTION 'You can''t change the full_name';
    END IF;
    IF OLD.role != NEW.role THEN
        RAISE EXCEPTION 'You can''t change the user''s role';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_user_prohibited_changes
BEFORE UPDATE
    ON users
FOR EACH ROW
EXECUTE FUNCTION check_user_prohibited_changes();

/* RESTAURANTS */

CREATE TRIGGER trigger_restaurant_id_modification
BEFORE UPDATE
    ON restaurants
FOR EACH ROW
EXECUTE FUNCTION check_id_modification();

ALTER TABLE restaurants
ADD CONSTRAINT check_restaurant_name_length CHECK ( length(trim(name)) >= 5 );

ALTER TABLE restaurants
ADD CONSTRAINT check_restaurant_address_length CHECK ( length(trim(address)) >= 5 );

ALTER TABLE restaurants
ADD CONSTRAINT check_restaurant_city_length CHECK ( length(trim(city)) >= 3 );

ALTER TABLE restaurants
ADD CONSTRAINT check_restaurant_phone_valid CHECK ( trim(phone) LIKE '+32%' AND trim(phone) !~ ' [a-zA-Z] ');

ALTER TABLE restaurants
ADD CONSTRAINT check_restaurant_description_length CHECK ( description IS NULL OR length(trim(description)) >= 10 );

ALTER TABLE restaurants
ADD CONSTRAINT check_restaurant_rating_valid CHECK ( rating BETWEEN 0.0 AND 5.0 );

ALTER TABLE restaurants
ADD CONSTRAINT check_restaurant_price_range CHECK ( price_range BETWEEN 1 AND 4 );

ALTER TABLE restaurants
ADD CONSTRAINT check_restaurant_slot_duration CHECK ( slot_duration IN ( 10, 15, 20, 30, 60 ) );

/* RESERVATIONS 4 + 2 */

CREATE TRIGGER trigger_reservations_id_modification
BEFORE UPDATE
    ON reservations
FOR EACH ROW
EXECUTE FUNCTION check_id_modification();

ALTER TABLE reservations
ADD CONSTRAINT check_reservations_status CHECK ( status IN ( 'pending', 'confirmed', 'cancelled', 'completed' ) );

ALTER TABLE reservations
ADD CONSTRAINT check_reservations_number_of_guest CHECK ( number_of_guests > 0 );

ALTER TABLE reservations
ADD CONSTRAINT check_special_requests_length CHECK ( special_requests IS NULL OR length(trim(special_requests)) >= 10 );

CREATE OR REPLACE FUNCTION check_change_restaurant_or_client_for_reservation()
    RETURNS TRIGGER AS
$$
BEGIN
    IF OLD.restaurant != NEW.restaurant
        OR OLD.client != NEW.client THEN
        RAISE EXCEPTION 'You can''t change restaurant or client for this reservation';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_change_restaurant_or_client_for_reservation
BEFORE UPDATE
    ON reservations
FOR EACH ROW
EXECUTE FUNCTION check_change_restaurant_or_client_for_reservation();

/* TABLE */

-- UQ
CREATE UNIQUE INDEX unique_table_for_restaurant ON tables ( restaurant, table_number );

CREATE TRIGGER trigger_tables_id_modification
BEFORE UPDATE
    ON tables
FOR EACH ROW
EXECUTE FUNCTION check_id_modification();

ALTER TABLE tables
ADD CONSTRAINT check_tables_number CHECK ( table_number > 0 );

ALTER TABLE tables
ADD CONSTRAINT check_tables_capacity CHECK ( capacity > 0 );

CREATE OR REPLACE FUNCTION check_change_restaurant_for_table()
    RETURNS TRIGGER AS
$$
BEGIN
    IF OLD.restaurant != NEW.restaurant THEN
        RAISE EXCEPTION 'You can''t change the restaurant for this table';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_change_restaurant_for_table
BEFORE UPDATE
    ON tables
FOR EACH ROW
EXECUTE FUNCTION check_change_restaurant_for_table();

/* SERVICES */

-- UQ
CREATE UNIQUE INDEX unique_service ON services ( restaurant, day_of_week, start_time, end_time );

CREATE TRIGGER trigger_services_id_modification
BEFORE UPDATE
    ON services
FOR EACH ROW
EXECUTE FUNCTION check_id_modification();

ALTER TABLE services
ADD CONSTRAINT check_valid_day_of_week CHECK ( day_of_week BETWEEN 1 AND 7 );

ALTER TABLE services
ADD CONSTRAINT check_services_range CHECK ( start_time + interval '1 hour' <= end_time );

CREATE OR REPLACE FUNCTION check_change_restaurant_for_service()
    RETURNS TRIGGER AS
$$
BEGIN
    IF OLD.restaurant != NEW.restaurant THEN
        RAISE EXCEPTION 'You can''t change the restaurant for this service';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_change_restaurant_for_service
BEFORE UPDATE
    ON services
FOR EACH ROW
EXECUTE FUNCTION check_change_restaurant_for_service();

/* RESTAURANT MANAGERS */

CREATE OR REPLACE FUNCTION check_restaurant_managers_pks()
    RETURNS TRIGGER AS
$$
    BEGIN
        IF OLD.restaurant != NEW.restaurant
               OR OLD.manager != NEW.manager THEN
            RAISE EXCEPTION 'You can''t change PKs (restaurant-manager)';
        END IF;
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_restaurant_managers_pks
BEFORE UPDATE
    ON restaurant_managers
FOR EACH ROW
EXECUTE FUNCTION check_restaurant_managers_pks();

/* RESERVATION TABLES */

CREATE OR REPLACE FUNCTION check_reservation_tables_pks()
    RETURNS TRIGGER AS
$$
BEGIN
    IF OLD.reservation != NEW.reservation
        OR OLD.table != NEW.table THEN
        RAISE EXCEPTION 'You can''t change PKs (reservation-table)';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_reservation_tables_pks
    BEFORE UPDATE
    ON reservation_tables
    FOR EACH ROW
EXECUTE FUNCTION check_reservation_tables_pks();