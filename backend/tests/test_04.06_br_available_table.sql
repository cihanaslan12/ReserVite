rollback;
set search_path to public;

begin;
do
$test$
    begin
        raise notice 'TEST: BR-06 - collision de tables';
        INSERT INTO reservations (id, client, restaurant, datetime, number_of_guests, status, special_requests)
        VALUES (50, 3, 1, '2026-05-20 19:00:00', 2, 'pending', null),
               (51, 4, 1, '2026-05-20 19:00:00', 2, 'pending', null);
        INSERT INTO reservation_tables (reservation, "table")
        VALUES (50, 1),
               (51, 1);
        UPDATE reservations SET status = 'confirmed' WHERE id = 50;
        perform should_fail($$
            UPDATE reservations SET status = 'confirmed' WHERE id = 51;
        $$, 'raise_exception');
        raise notice 'TEST BR-06 réussi: la table n''a pas été réservée 2x pour le même créneau';
end;
$test$;
rollback;