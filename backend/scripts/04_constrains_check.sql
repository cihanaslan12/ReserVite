/* USERS  2 + 2 */

ALTER TABLE users
ADD CONSTRAINT check_full_name_length CHECK ( length(trim(full_name)) >= 3 );

ALTER TABLE users
ADD CONSTRAINT check_valid_password CHECK ( (trim(password)) ~ '^\$2[aby]\$\d{2}\$[./A-Za-z0-9]{53}$' );

/* RESTAURANTS 8 + 0 */

ALTER TABLE restaurants
ADD CONSTRAINT check_restaurant_name_length CHECK ( length(trim(name)) >= 5 );

ALTER TABLE restaurants
ADD CONSTRAINT check_restaurant_address_length CHECK ( length(trim(address)) >= 5 );

ALTER TABLE restaurants
ADD CONSTRAINT check_restaurant_city_length CHECK ( length(trim(city)) >= 3 );

ALTER TABLE restaurants
ADD CONSTRAINT check_restaurant_phone_valid CHECK ( trim(phone) ~ '^+32 [0-9]{1,3} [0-9]{2,3} [0-9]{2} [0-9]{2}$' );

ALTER TABLE restaurants
ADD CONSTRAINT check_restaurant_description_length CHECK ( length((description) >= 10) );

ALTER TABLE restaurants
ADD CONSTRAINT check_restaurant_rating_valid CHECK ( rating BETWEEN 0.0 AND 5.0 );

ALTER TABLE restaurants
ADD CONSTRAINT check_restaurant_price_range CHECK ( price_range BETWEEN 1 AND 4 );

ALTER TABLE restaurants
ADD CONSTRAINT check_restaurant_slot_duration CHECK ( slot_duration IN ( 10, 15, 20, 30, 60 ) );

/* RESERVATIONS 3 + 3 */

ALTER TABLE reservations
ADD CONSTRAINT check_reservations_status CHECK ( status = 'pending' OR status = 'confirmed' OR status = 'cancelled' OR status = 'completed' );

ALTER TABLE reservations
ADD CONSTRAINT check_reservations_number_of_guest CHECK ( number_of_guests > 0 );

ALTER TABLE reservations
ADD CONSTRAINT check_special_requests_length CHECK ( length(trim(special_requestst)) >= 10 );

/* TABLE 2 + 1 */

ALTER TABLE tables
ADD CONSTRAINT check_tables_number CHECK ( table_number > 0 );  -- AND unique au sein du resto

ALTER TABLE tables
ADD CONSTRAINT check_tables_capacity CHECK ( capacity > 0 );

/* SERVICES 2 + 1 */

ALTER TABLE services
ADD CONSTRAINT check_valid_day_of_week CHECK ( day_of_week BETWEEN 1 AND 7 );

ALTER TABLE services
ADD CONSTRAINT check_services_range CHECK ( start_time + interval '1 hour' <= end_time );