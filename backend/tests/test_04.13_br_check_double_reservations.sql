rollback;
set search_path to public;
begin;
do
$test$
begin
    raise notice 'TEST: BR-13 - Un même client ne peut avoir deux réservations pour un même service';
    INSERT INTO reservations (client, restaurant, datetime, number_of_guests, status, special_requests)
    VALUES (3, 2, '2026-05-15 19:00:00', 2, 'confirmed', null);
    perform should_fail($$
        INSERT INTO reservations (client, restaurant, datetime, number_of_guests, status, special_requests)
        VALUES (3, 2, '2026-05-15 19:00:00', 2, 'pending', null)
        $$, 'raise_exception');
    raise notice 'TEST BR-13 réussi : Le client n''a pas pu réserver pour le même service';
end;
$test$;
rollback;

ROLLBACK;
BEGIN;
--
-- -- On nettoie tout
-- --SELECT reset_database();
--
-- DO $test$
--     BEGIN
--         -- 1. On crée un restaurant spécifique pour le test (ID 99)
--         INSERT INTO restaurants (id, name, address, city, phone, slot_duration)
--         VALUES (99, 'Resto Test Doublon', 'Rue Test', 'TestCity', '+32 2 222 22 22', 30);
--
--         -- 2. On lui met un manager (pour satisfaire la BR-10)
--         INSERT INTO restaurant_managers (restaurant, manager) VALUES (99, 1);
--
--         -- 3. On lui met une table GEANTE (pour satisfaire la BR-capacité)
--         INSERT INTO tables (restaurant, table_number, capacity) VALUES (99, 1, 100);
--
--         -- 4. On lui met un service (pour ton JOIN dans la BR-13)
--         -- Le 15 Mai 2026 est un Vendredi (day_of_week = 5)
--         INSERT INTO services (restaurant, day_of_week, start_time, end_time)
--         VALUES (99, 5, '18:00', '23:00');
--
--         RAISE NOTICE 'Lancement du test BR-13...';
--
--         -- PREMIÈRE RÉSERVATION : OK
--         INSERT INTO reservations (client, restaurant, datetime, number_of_guests, status)
--         VALUES (3, 99, '2026-05-15 19:00:00', 2, 'confirmed');
--
--         -- DEUXIÈME RÉSERVATION (Doublon) : DOIT ÉCHOUER
--         PERFORM should_fail($$
--         INSERT INTO reservations (client, restaurant, datetime, number_of_guests, status)
--         VALUES (3, 99, '2026-05-15 20:00:00', 2, 'pending');
--     $$, 'raise_exception');
--
--         RAISE NOTICE 'TEST BR-13 RÉUSSI !';
--     END;
-- $test$;
--
-- ROLLBACK;